{ config, lib, ... }:


{
  platform.user.persist.folders = [
      ".local/share/fonts"
  ];

  xdg.configFile."fontconfig/conf.d/99-local.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <dir>/home/${config.opts.username}/.local/share/fonts</dir>
    </fontconfig>
  '';
}
