const PRIVATE = "origin"
const PUBLIC = "upstream"

const ARCHIVE_RE = '^archive/(?<date>\d{4}-\d{2}-\d{2})-(?:(?<pr>\d+)-)?(?<name>.+)$'
const ONELINE = 'change_id.shortest(8) ++ " " ++ if(description, description.first_line(), "(no description)") ++ " (" ++ committer.timestamp().format("%Y-%m-%d") ++ ")"'

def fail [msg: string] {
    print --stderr $"(ansi red_bold)error:(ansi reset) ($msg)"
    exit 1
}

def header [text: string] {
    print $"(ansi cyan_bold)($text)(ansi reset)"
}

def warn [msg: string] {
    print --stderr $"(ansi yellow)warning:(ansi reset) ($msg)"
}

def first-or-null []: list -> any {
    let items = $in
    if ($items | is-empty) { null } else { $items | first }
}

def confirm [prompt: string] {
    (input $"($prompt) [y/N] " | str trim) == "y"
}

def unquote []: string -> string {
    str replace -r '^"(.*)"$' '${1}'
}

def local-bookmarks []: nothing -> list<string> {
    jj bookmark list -T 'if(remote, "", name ++ "\n")' | lines | each { unquote }
}

def bookmarks-at [rev: string]: nothing -> list<string> {
    jj log -r $rev --no-graph --ignore-working-copy -T 'local_bookmarks.map(|b| b.name()).join("\n") ++ "\n"'
    | lines
    | where { ($in | str trim) != "" }
    | each { unquote }
}

def local-bookmark-positions [] {
    jj bookmark list -T 'if(remote, "", if(conflict, "", if(present, name ++ "\t" ++ normal_target.commit_id() ++ "\n", "")))'
    | lines
    | parse "{name}\t{commit}"
    | update name { unquote }
}

def resolve-name [--archive] {
    let filter = {|bookmarks|
        $bookmarks | where {|b|
            if $archive { $b starts-with "archive/" } else { not ($b starts-with "archive/") }
        }
    }
    mut found = (do $filter (bookmarks-at "@"))
    if ($found | is-empty) {
        $found = (do $filter (bookmarks-at "@-"))
    }
    if ($found | is-empty) {
        fail "no bookmark found on @ or @-; pass a name"
    }
    if ($found | length) > 1 {
        fail $"several bookmarks found: ($found | str join ', '); pass a name"
    }
    $found | first
}

def show-rev [rev: string] {
    let res = do { jj log -r $rev --no-graph --color always --ignore-working-copy -T $ONELINE } | complete
    if $res.exit_code == 0 {
        $res.stdout | str trim
    } else {
        $"(ansi dark_gray)\(absent\)(ansi reset)"
    }
}

def rev-exists [rev: string] {
    (do { jj log -r $rev --no-graph --ignore-working-copy -T '""' } | complete | get exit_code) == 0
}

def untrack-quiet [ref: string] {
    do { jj bookmark untrack $ref } | complete | ignore
}

def is-tracked [name: string, remote: string] {
    jj bookmark list --tracked $name -T 'if(remote, name ++ "\t" ++ remote ++ "\n", "")'
    | lines
    | parse "{name}\t{remote}"
    | update name { unquote }
    | update remote { unquote }
    | where {|t| $t.name == $name and $t.remote == $remote }
    | is-not-empty
}

def trunk-name []: nothing -> any {
    jj log -r 'trunk()' --no-graph --ignore-working-copy -T 'local_bookmarks.map(|b| b.name()).join("\n")'
    | lines
    | each { str trim }
    | where { $in != "" }
    | each { unquote }
    | first-or-null
}

def tracked-bookmarks [remote: string]: nothing -> list<string> {
    jj bookmark list --tracked --remote $remote -T 'name ++ "\n"'
    | lines
    | each { unquote }
    | uniq
}

def bookmark-commit [name: string, remote: string]: nothing -> any {
    jj bookmark list --all-remotes $name -T 'if(present, if(conflict, "", name ++ "\t" ++ remote ++ "\t" ++ normal_target.commit_id() ++ "\n"), "")'
    | lines
    | parse "{name}\t{remote}\t{commit}"
    | update name { unquote }
    | update remote { unquote }
    | where {|r| $r.name == $name and $r.remote == $remote }
    | get commit
    | first-or-null
}

def main [] {
    print "jjf — fork workflow for jj"
    print ""
    print "usage:"
    print "  jjf setup <origin-url> <upstream-url> [dir] [--trunk <name>]"
    print "  jjf sync [-y] [--dry-run] [--no-fetch] [--allow-trunk]"
    print "  jjf pub [name]"
    print "  jjf unpub [name] [--keep-remote]"
    print "  jjf arc [name] [--pr <number>]"
    print "  jjf unarc [name]"
    print "  jjf arcs [--pr <number>] [--name <text>] [--log]"
}

def "main setup" [
    origin_url: string
    upstream_url: string
    dir?: string
    --trunk: string = "main"
] {
    let dir = $dir | default ($origin_url | path basename | str replace -r '\.git$' '')
    if ($dir | path exists) {
        fail $"'($dir)' already exists"
    }
    jj git clone --remote $PRIVATE $origin_url $dir
    cd $dir
    jj git remote add $PUBLIC $upstream_url
    jj config set --repo git.push $PRIVATE
    jj config set --repo git.fetch $"[\"($PUBLIC)\", \"($PRIVATE)\"]"
    jj config set --repo 'revset-aliases."trunk()"' $"($trunk)@($PUBLIC)"
    jj config set --repo revsets.log "@ | ancestors(immutable_heads().., 2) | trunk() | (bookmarks() ~ bookmarks(glob:'archive/*'))"
    jj git fetch --remote $PUBLIC --remote $PRIVATE
    jj bookmark track $"($trunk)@($PUBLIC)"
    print $"Ready. cd ($dir)"
}

def "main sync" [
    --yes (-y)
    --dry-run
    --no-fetch
    --allow-trunk
] {
    let recorded = local-bookmark-positions
    if not $no_fetch {
        header "fetch"
        jj git fetch --remote $PUBLIC --remote $PRIVATE
    }

    let conflicted = (
        jj bookmark list --conflicted -T 'if(remote, "", name ++ "\n")'
        | lines
        | each { unquote }
    )
    if ($conflicted | is-empty) {
        print "no conflicted bookmarks"
    }
    mut skipped = []
    for name in $conflicted {
        let rec = $recorded | where name == $name
        let local_pos = if ($rec | is-empty) { null } else { ($rec | first).commit }
        print ""
        header $"conflicted bookmark: ($name)"
        let local_line = if $local_pos == null {
            $"(ansi dark_gray)\(not recorded; choose u or o\)(ansi reset)"
        } else {
            show-rev $local_pos
        }
        print $"  local \(l\):    ($local_line)"
        print $"  upstream \(u\): (show-rev $'($name)@($PUBLIC)')"
        print $"  origin \(o\):   (show-rev $'($name)@($PRIVATE)')"
        let choice = input "  [l]ocal / [u]pstream / [o]rigin / [s]kip > " | str trim
        let target = match $choice {
            "l" => $local_pos
            "u" => $"($name)@($PUBLIC)"
            "o" => $"($name)@($PRIVATE)"
            _ => null
        }
        if $target == null {
            if $choice == "l" {
                print $"  no local position was recorded for ($name); skipping"
            } else {
                print $"  skipping ($name)"
            }
            $skipped = ($skipped | append $name)
        } else {
            jj bookmark set $name -r $target --allow-backwards
        }
    }
    if not ($skipped | is-empty) {
        fail $"skipped: ($skipped | str join ', '); nothing was pushed"
    }

    let tracked_private = tracked-bookmarks $PRIVATE
    let to_track = local-bookmarks | where {|b| $b not-in $tracked_private }
    if not ($to_track | is-empty) {
        jj bookmark track ...$to_track --remote $PRIVATE
    }

    print ""
    header $PRIVATE
    let private_plan = do { jj git push --remote $PRIVATE --tracked --deleted --dry-run --color always } | complete
    print --no-newline $private_plan.stdout
    print --no-newline --stderr $private_plan.stderr
    if $private_plan.exit_code != 0 { exit $private_plan.exit_code }

    print ""
    header $PUBLIC
    let public_plan = do { jj git push --remote $PUBLIC --tracked --deleted --dry-run --color always } | complete
    print --no-newline $public_plan.stdout
    print --no-newline --stderr $public_plan.stderr
    if $public_plan.exit_code != 0 { exit $public_plan.exit_code }

    let trunk = trunk-name
    if $trunk == null {
        warn $"no local bookmark points at trunk\(\); skipping the trunk check"
    } else if (not $allow_trunk) and ((bookmark-commit $trunk "") != (bookmark-commit $trunk $PUBLIC)) {
        fail $"'($trunk)' and ($trunk)@($PUBLIC) point at different commits; rerun with --allow-trunk if intended"
    }

    if $dry_run { return }
    print ""
    if (not $yes) and (not (confirm "Push?")) {
        fail "aborted; nothing was pushed"
    }
    jj git push --remote $PRIVATE --tracked --deleted
    jj git push --remote $PUBLIC --tracked --deleted
}

def "main pub" [name?: string] {
    let name = if $name != null { $name } else { resolve-name }
    header $"publish ($name) to ($PUBLIC)"
    let was_tracked = is-tracked $name $PUBLIC
    if not $was_tracked {
        jj bookmark track $"($name)@($PUBLIC)"
    }
    let plan = do { jj git push --remote $PUBLIC --bookmark $name --dry-run --color always } | complete
    print --no-newline $plan.stdout
    print --no-newline --stderr $plan.stderr
    if $plan.exit_code != 0 {
        if not $was_tracked { untrack-quiet $"($name)@($PUBLIC)" }
        exit $plan.exit_code
    }
    if not (confirm "Push?") {
        if not $was_tracked { untrack-quiet $"($name)@($PUBLIC)" }
        fail "aborted; nothing was pushed"
    }
    jj git push --remote $PUBLIC --bookmark $name
}

def "main unpub" [
    name?: string
    --keep-remote
] {
    let name = if $name != null { $name } else { resolve-name }
    if not (is-tracked $name $PUBLIC) {
        fail $"($name)@($PUBLIC) is not tracked"
    }
    jj bookmark untrack $"($name)@($PUBLIC)"
    if $keep_remote {
        print "Unpublished. Branch kept on upstream."
        return
    }
    let git_dir = $"(jj root | str trim)/.jj/repo/store/git"
    git --git-dir $git_dir push $PUBLIC --delete $name --dry-run
    if not (confirm "Delete?") {
        fail "aborted; branch kept on upstream, bookmark stays untracked"
    }
    git --git-dir $git_dir push $PUBLIC --delete $name
    jj git fetch --remote $PUBLIC
    print "Unpublished."
}

def "main arc" [
    name?: string
    --pr: int
] {
    let name = if $name != null { $name } else { resolve-name }
    if $name not-in (local-bookmarks) {
        if not (rev-exists $"($name)@($PRIVATE)") {
            fail $"bookmark '($name)' exists neither locally nor on ($PRIVATE)"
        }
        jj bookmark create $name -r $"($name)@($PRIVATE)"
    }
    let date = jj log -r $name --no-graph --ignore-working-copy -T 'committer.timestamp().format("%Y-%m-%d")' | str trim
    let target = if $pr == null {
        $"archive/($date)-($name)"
    } else {
        $"archive/($date)-($pr)-($name)"
    }
    jj bookmark rename $name $target
    untrack-quiet $"($target)@($PUBLIC)"
    print $"Archived as ($target). Run 'jj sync'."
}

def "main unarc" [name?: string] {
    let archive = if $name == null {
        resolve-name --archive
    } else if ($name starts-with "archive/") {
        $name
    } else {
        fail $"'($name)' is not an archive bookmark; pass the full archive/<date>[-<pr>]-<name> name \(see 'jjf arcs'\)"
    }
    let parsed = $archive | parse -r $ARCHIVE_RE
    if ($parsed | is-empty) {
        fail $"'($archive)' does not match archive/<date>[-<pr>]-<name>"
    }
    let p = $parsed | first
    let target = if ($p.pr | is-empty) { $p.name } else { $"($p.pr)-($p.name)" }
    if $target in (local-bookmarks) {
        fail $"bookmark '($target)' already exists"
    }
    jj bookmark rename $archive $target
    untrack-quiet $"($target)@($PUBLIC)"
    print $"Restored as ($target) \(private\). Run 'jj sync'."
}

def "main arcs" [
    --pr: int
    --name: string
    --log
] {
    let archives = (
        jj bookmark list 'glob:archive/*' -T 'if(remote, "", if(present, name ++ "\n", ""))'
        | lines
        | each { unquote }
    )
    mut rows = []
    for b in $archives {
        let parsed = $b | parse -r $ARCHIVE_RE
        if ($parsed | is-empty) {
            warn $"skipping '($b)': does not match archive/<date>[-<pr>]-<name>"
            continue
        }
        let p = $parsed | first
        $rows = ($rows | append {
            date: $p.date
            pr: (if ($p.pr | is-empty) { null } else { $p.pr | into int })
            name: $p.name
            bookmark: $b
        })
    }
    let filtered = (
        $rows
        | where {|r| $pr == null or $r.pr == $pr }
        | where {|r| $name == null or ($r.name | str contains $name) }
        | sort-by date --reverse
    )
    if ($filtered | is-empty) {
        print --stderr "no matching archives"
        return
    }
    if $log {
        let revset = $filtered | get bookmark | each {|b| $"bookmarks\(exact:\"($b)\"\)" } | str join " | "
        jj log -r $"trunk\(\)..\(($revset)\)"
    } else {
        let descriptions = (
            jj log -r 'bookmarks(glob:"archive/*")' --no-graph --ignore-working-copy -T 'local_bookmarks.map(|b| b.name()).join(",") ++ "\t" ++ description.first_line() ++ "\n"'
            | lines
            | parse "{names}\t{description}"
            | each {|row|
                $row.names
                | split row ","
                | each { unquote }
                | each {|n| { bookmark: $n, description: $row.description } }
            }
            | flatten
        )
        $filtered
        | insert description {|r|
            let d = $descriptions | where bookmark == $r.bookmark
            if ($d | is-empty) { "" } else { ($d | first).description }
        }
        | select date pr name bookmark description
    }
}
