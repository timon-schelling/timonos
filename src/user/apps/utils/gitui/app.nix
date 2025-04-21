{ pkgs, ... }:

{
  programs.gitui = {
    enable = true;
    theme = ''
      (
        selected_tab: Some("reset"),
        command_fg: Some("white"),
        selection_bg: Some("dark-gray"),
        selection_fg: Some("white"),
        use_selection_fg: false,
        cmdbar_bg: Some("black"),
        cmdbar_extra_lines_bg: Some("black"),
        disabled_fg: Some("dark-gray"),
        diff_line_add: Some("green"),
        diff_line_delete: Some("red"),
        diff_file_added: Some("light-green"),
        diff_file_removed: Some("light-red"),
        diff_file_moved: Some("light-magenta"),
        diff_file_modified: Some("yellow"),
        commit_hash: Some("magenta"),
        commit_time: Some("light-cyan"),
        commit_author: Some("green"),
        danger_fg: Some("red"),
        push_gauge_bg: Some("blue"),
        push_gauge_fg: Some("reset"),
        tag_fg: Some("light-magenta"),
        branch_fg: Some("light-yellow"),
        block_title_focused: Some("reset"),
        line_break: Some(""),
      )
    '';
  };
}
