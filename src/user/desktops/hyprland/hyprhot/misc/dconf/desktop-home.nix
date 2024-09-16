{ ... }:

{
  dconf = {
    enable = true;
    settings = {
      # TODO: move this to a more suitable place
      "org/gtk/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
      };
    };
  };
}
