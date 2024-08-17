if $env.PWD == $env.HOME {
    try {
        enter ~/tmp
        enter ~/dev
        enter ~/data
    }
    try {
        goto 0
    }
}
