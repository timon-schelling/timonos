def follow [path] {
    let path_info = ls -al $path | get 0
    if ($path_info.type == "symlink") {
        return (follow $path_info.target)
    }
    return $path_info.name
}

def which-follow [cmd] {
    which $cmd | get path | get 0 | follow $in
}
