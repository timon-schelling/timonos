{ ... }:

{
  users.groups."input-local" = {};

  environment.etc."keyd/default.conf" = {
    group = "input-local";
    mode = "0664";
  };

  # TODO: make settings overriteable by user

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      extraConfig = ''
        [main]
        esc = clear()

        delete = overload(special, delete)

        rightalt = layer(german)

        capslock = overload(control, esc)

        space = overloadt(shift, space, 300)

        f = overloadt(nav, f, 300)
        d = overloadt(edit, d, 300)
        g = overloadt(visual, g, 300)

        s = overloadt(app, s, 300)
        a = overloadt(app_nav, a, 300)

        v = overloadt(view, v, 300)

        c = overloadt(window_edit, c, 300)
        x = overloadt(window_resize, x, 300)

        r = overloadt(run_app, r, 300)

        e = overloadt(desktop, e, 300)

        [visual]
        esc = clear()

        i = S-up
        k = S-down
        j = S-left
        l = S-right

        u = S-C-left
        o = S-C-right

        y = macro(S-up S-up S-up S-up S-up)
        h = macro(S-down S-down S-down S-down S-down)

        n = S-C-A-left
        m = S-C-A-right

        , = S-home
        . = S-end


        [nav]
        esc = clear()

        i = up
        k = down
        j = left
        l = right

        u = C-left
        o = C-right

        y = macro(up up up up up)
        h = macro(down down down down down)

        n = C-A-left
        m = C-A-right

        , = home
        . = end


        [edit]
        esc = clear()

        j = enter
        h = tab
        k = backspace
        i = delete
        l = macro(end enter)
        o = esc

        u = C-c
        ; = C-v
        y = M-v
        b = C-x

        n = C-z
        m = C-S-z


        [view]
        esc = clear()

        i = M-up
        k = M-down
        j = M-left
        l = M-right

        u = M-pageup
        o = M-pagedown

        n = C-pageup
        m = C-pagedown

        h = C-+
        y = C--


        [app]
        esc = clear()

        h = C-t
        b = C-w

        n = C-e
        m = C-S-o

        j = C-s
        u = C-S-s

        i = A-up
        k = A-down

        o = C-S-up
        l = C-S-down

        y = C-k


        [app_nav]
        esc = clear()

        u = C-pageup
        o = C-pagedown

        n = back
        m = forward


        [window_edit]
        esc = clear()

        i = S-M-up
        k = S-M-down
        j = S-M-left
        l = S-M-right

        u = S-M-pageup
        o = S-M-pagedown

        h = M-g
        y = M-s
        n = M-o
        m = M-m
        ; = M-f
        b = M-q

        [window_resize]
        esc = clear()

        i = C-S-M-up
        k = C-S-M-down
        j = C-S-M-left
        l = C-S-M-right

        [run_app]
        esc = clear()

        j = M-1
        h = M-2
        k = M-3
        l = M-4
        i = M-5
        n = M-6
        u = M-7
        m = M-8
        ; = M-9

        [desktop]
        esc = clear()

        h = M-b
        u = volumeup
        j = volumedown
        i = brightnessup
        k = brightnessdown

        # compose key macros compose key is set to 'scrolllock'
        # compose table of special characters https://help.ubuntu.com/community/GtkComposeTable
        # s = ß
        # a = ä
        # o = ö
        # u = ü
        # e = €
        # p = £
        # c = ©
        # t = ™
        # r = ®
        # A = Ä
        # O = Ö
        # U = Ü
        [german]
        esc = clear()

        s = macro(scrolllock s s)
        a = macro(scrolllock a ")
        o = macro(scrolllock o ")
        u = macro(scrolllock u ")
        e = macro(scrolllock e =)
        p = macro(scrolllock 0 s)
        c = macro(scrolllock o c)
        t = macro(scrolllock T M)
        r = macro(scrolllock O R)

        [german+shift]
        a = macro(scrolllock S S)
        a = macro(scrolllock A ")
        o = macro(scrolllock O ")
        u = macro(scrolllock U ")



        [special]
        esc = toggle(normal)
        ` = command(keyd reload)


        [normal]
        esc = overload(normal_esc, esc)
        space = space
        ' = '
        , = ,
        - = -
        . = .
        / = /
        1 = 1
        2 = 2
        3 = 3
        4 = 4
        5 = 5
        6 = 6
        7 = 7
        8 = 8
        9 = 9
        ; = ;
        = = =
        [ = [
        \ = \
        ] = ]
        a = a
        b = b
        c = c
        d = d
        e = e
        f = f
        g = g
        h = h
        i = i
        j = j
        k = k
        l = l
        m = m
        n = n
        o = o
        p = p
        q = q
        r = r
        s = s
        t = t
        u = u
        v = v
        w = w
        x = x
        y = y
        z = z

        [normal_esc]
        delete = clear()

        [normal+special]
        esc = noop
      '';
    };
  };
}
