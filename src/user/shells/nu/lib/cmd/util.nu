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

def --env e [path?: path] {
    if ($path == null) {
        enter (tere)
    } else {
        enter $path
    }
}

def --env c [path?: path] {
    if ($path == null) {
        cd (tere)
    } else {
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
