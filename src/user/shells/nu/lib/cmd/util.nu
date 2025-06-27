def l [] {
    ls -al | select name size mode user group modified type
}

alias goto = g
def --env g [shell?: int] {
    try {
        if ($shell == null) {
            let shell = goto | get path | str replace $"($env.HOME)" '~' | input list -i -f
            if ($shell != null) {
                goto $shell
            }
        } else {
            goto $shell
        }
    }
}

def --env goto-equivalent-shell [path: path]: nothing -> bool {
    let equivalent_shells = goto
        | enumerate
        | insert id { $in.index }
        | flatten item
        | where { $in.path == $path }
    let shell = if ($equivalent_shells | length) > 0 {
        ($equivalent_shells | first | get id)
    } else {
        null
    }
    if ($shell != null) {
        goto $shell
        true
    } else {
        false
    }
}

def --env e [path?: path] {
    mut path = $path
    if ($path == null) {
        $path = ^tere
    }
    if not (goto-equivalent-shell $path) {
        enter $path
    }
}

alias "input path" = ^tere
def "path_exists" [path?: path] {
    if ($path != null and ($path | path exists)) {
        $path
    } else {
        input path
    }
}

def --env c [path?: path] {
    mut path = $path
    if ($path == null) {
        $path = ^tere
    }
    if not (goto-equivalent-shell $path) {
        cd $path
    }
}

# TODO: Add fuzzy finding capabilities
# def fuzzy-path-finder [] {
#     ([ (rg --files | sk --preview="bat {} --color=always") ] | path expand).0
# }

# def fuzzy-finder [] {
#     let input = sk -i -c "rg --line-number '{}'" -d ":" --preview="bat -n -H {2} --color=always {1}"
#     let path = ([ (input) ] | path expand).0
#     ( | split list ":").0
# }

# def ff [] {
#     let file = (fuzzy-finder)
#     if ($file != null) {
#         cat $file
#     }
# }

# def f [] {
#     let file = (fuzzy-path-finder)
#     cat $file
# }

# def --env ef [] {
#     let file = (fuzzy-path-finder)
#     if ($file != null) {
#         try {
#             enter $file
#         } catch {
#             enter ($file | path dirname)
#         }
#         cat $file
#     }
# }

# def --env cf [] {
#     let file = (fuzzy-path-finder)
#     if ($file != null) {
#         try {
#             cd $file
#         } catch {
#             cd ($file | path dirname)
#         }
#         cat $file
#     }
# }

# def hf [] {
#     let file = (fuzzy-finder)
#     if ($file != null) {
#         code $file
#     }
# }

# def --env dotfiles [] {
#     enter ~/.dotfiles
#     code .
# }
