let extra_completer = {|spans|
    print $spans
    carapace $spans.0 nushell $spans | from json
}

$env.config = {
    ls: {
        use_ls_colors: true # use the LS_COLORS environment variable to colorize output
        clickable_links: true # enable or disable clickable links. Your terminal has to support links.
    }
    rm: {
        always_trash: false # always act as if -t was given. Can be overridden with -p
    }
    table: {
        mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
        trim: {
            methodology: truncating # wrapping or truncating
            wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
            truncating_suffix: "…" # A suffix used by the 'truncating' methodology
        }
        padding: { left: 0, right: 0 }
        header_on_separator: true # show header on separator line
    }

    explore: {
        help_banner: true
        exit_esc: true

        # command_bar_text: '#C4C9C6'
        # command_bar: {fg: '#C4C9C6' bg: '#223311' }

        # status_bar_background: {fg: '#1D1F21' bg: '#C4C9C6' }
        # status_bar_text: {fg: '#C4C9C6' bg: '#223311' }

        # highlight: {bg: 'yellow' fg: 'black' }

        status: {
            # warn: {bg: 'yellow', fg: 'blue'}
            # error: {bg: 'yellow', fg: 'blue'}
            # info: {bg: 'yellow', fg: 'blue'}
        }

        try: {
            # border_color: 'red'
            # highlighted_color: 'blue'

            # reactive: false
        }

        table: {
            # split_line: '#404040'

            cursor: true

            line_index: true
            line_shift: true
            line_head_top: true
            line_head_bottom: true

            show_head: true
            show_index: true

            # selected_cell: {fg: 'white', bg: '#777777'}
            # selected_row: {fg: 'yellow', bg: '#C1C2A3'}
            # selected_column: blue

            # padding_column_right: 2
            # padding_column_left: 2

            # padding_index_left: 2
            # padding_index_right: 1
        }

        config: {
            # cursor_color: {bg: 'yellow' fg: 'black' }

            # border_color: white
            # list_color: green
        }
    }

    history: {
        max_size: 100000 # Session has to be reloaded for this to take effect
        sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
        file_format: "plaintext" # "sqlite" or "plaintext"
    }
    completions: {
        case_sensitive: false # set to true to enable case-sensitive completions
        quick: true  # set this to false to prevent auto-selecting completions when only one remains
        partial: true  # set this to false to prevent partial filling of the prompt
        algorithm: "prefix"  # prefix or fuzzy
        external: {
            enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
            max_results: 256 # setting it lower can improve completion performance at the cost of omitting some options
            completer: $extra_completer # check 'carapace_completer' above as an example
        }
    }
    filesize: {
        metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
        format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
    }
    color_config: {
        # separator: "#bbbbbb"
        # leading_trailing_space_bg: { attr: "n" }
        # header: { fg: "#8ce10b" attr: "b" }
        # empty: "#008df8"
        # bool: {|| if $in { "#67fff0" } else { "light_gray" } }
        # int: "#bbbbbb"
        filesize: {|e|
            if $e == 0b {
                "text"
            } else if $e < 1kb {
                "cyan"
            } else if $e < 1mb {
                "green"
            } else if $e < 10mb {
                "yellow"
            } else if $e < 100mb {
                "red"
            } else {
                { fg: "magenta" }
            }
        }
        # duration: "#bbbbbb"
        date: {|| (date now) - $in |
            if $in < 1hr {
                "red"
            } else if $in < 6hr {
                "magenta"
            } else if $in < 1day {
                "yellow"
            } else if $in < 3day {
                "green"
            } else if $in < 1wk {
                "green"
            } else if $in < 6wk {
                "blue"
            } else if $in < 52wk {
                "cyan"
            } else { "text" }
        }
        # range: "#bbbbbb"
        # float: "#bbbbbb"
        # string: "#bbbbbb"
        # nothing: "#bbbbbb"
        # binary: "#bbbbbb"
        # cellpath: "#bbbbbb"
        # row_index: { fg: "#8ce10b" attr: "b" }
        # record: "#bbbbbb"
        # list: "#bbbbbb"
        # block: "#bbbbbb"
        hints: "black"
        # search_result: { fg: "#ff000f" bg: "#bbbbbb" }

        # shape_and: { fg: "#6d43a6" attr: "b" }
        # shape_binary: { fg: "#6d43a6" attr: "b" }
        # shape_block: { fg: "#008df8" attr: "b" }
        # shape_bool: "#67fff0"
        # shape_custom: "#8ce10b"
        # shape_datetime: { fg: "#00d8eb" attr: "b" }
        # shape_directory: "#00d8eb"
        # shape_external: "#00d8eb"
        # shape_externalarg: { fg: "#8ce10b" attr: "b" }
        # shape_filepath: "#00d8eb"
        # shape_flag: { fg: "#008df8" attr: "b" }
        # shape_float: { fg: "#6d43a6" attr: "b" }
        # shape_garbage: { fg: "#bbbbbb" bg: "#FF0000" attr: "b" }
        # shape_globpattern: { fg: "#00d8eb" attr: "b" }
        # shape_int: { fg: "#6d43a6" attr: "b" }
        # shape_internalcall: { fg: "#00d8eb" attr: "b" }
        # shape_list: { fg: "#00d8eb" attr: "b" }
        # shape_literal: "#008df8"
        # shape_match_pattern: "#8ce10b"
        # shape_matching_brackets: { attr: "u" }
        # shape_nothing: "#67fff0"
        # shape_operator: "#ffb900"
        # shape_or: { fg: "#6d43a6" attr: "b" }
        # shape_pipe: { fg: "#6d43a6" attr: "b" }
        # shape_range: { fg: "#ffb900" attr: "b" }
        # shape_record: { fg: "#00d8eb" attr: "b" }
        # shape_redirection: { fg: "#6d43a6" attr: "b" }
        # shape_signature: { fg: "#8ce10b" attr: "b" }
        # shape_string: "#8ce10b"
        # shape_string_interpolation: { fg: "#00d8eb" attr: "b" }
        # shape_table: { fg: "#008df8" attr: "b" }
        # shape_variable: "#6d43a6"

        # background: "#0e1019"
        # foreground: "#bbbbbb"
        # cursor: "#bbbbbb"
    }
    footer_mode: "auto"
    float_precision: 2
    # buffer_editor: "emacs" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
    use_ansi_coloring: true
    edit_mode: emacs # emacs, vi
    show_banner: false # true or false to enable or disable the banner
    render_right_prompt_on_last_line: true # true or false to enable or disable right prompt to be rendered on last line of the prompt.

    hooks: {
        pre_prompt: [{ ||
            null  # replace with source code to run before the prompt is shown
        }]
        pre_execution: [{ ||
            null  # replace with source code to run before the repl input is run
        }]
        env_change: {
            PWD: []
        }
        display_output: { ||
            if (term size).columns >= 95 { table -e } else { table }
        }
    }
    menus: [
        # Configuration for default nushell menus
        # Note the lack of source parameter
        {
            name: completion_menu
            only_buffer_difference: false
            marker: ""
            type: {
                layout: columnar
                columns: 4
                col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        # Example of extra menus created using a nushell source
        # Use the source field to create a list of records that populates
        # the menu
        {
            name: commands_menu
            only_buffer_difference: false
            marker: "# "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                $nu.scope.commands
                | where name =~ $buffer
                | each { |it| {value: $it.name description: $it.usage} }
            }
        }
        {
            name: vars_menu
            only_buffer_difference: true
            marker: "# "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                $nu.scope.vars
                | where name =~ $buffer
                | sort-by name
                | each { |it| {value: $it.name description: $it.type} }
            }
        }
        {
            name: commands_with_description
            only_buffer_difference: true
            marker: "# "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                $nu.scope.commands
                | where name =~ $buffer
                | each { |it| {value: $it.name description: $it.usage} }
            }
        }
    ]
    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
        }
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
            event: { send: menuprevious }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: emacs
            event: { send: menu name: history_menu }
        }
        # Keybindings used to trigger the user defined menus
        {
            name: commands_menu
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: commands_menu }
        }
        {
            name: vars_menu
            modifier: alt
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: vars_menu }
        }
        {
            name: commands_with_description
            modifier: control
            keycode: char_s
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: commands_with_description }
        }
    ]
}
