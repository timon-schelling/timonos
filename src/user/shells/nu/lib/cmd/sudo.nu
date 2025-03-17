def --wrapped sudo [...rest] {
  let escaped_args = $rest
    | each { || $in }
    | str join ' '
  ^sudo -E env XDG_RUNTIME_DIR=/run/user/0 nu --commands $'($escaped_args)'
}
