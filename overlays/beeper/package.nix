{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
  writeShellApplication,
  curl,
  common-updater-scripts,
}:
let
  pname = "beeper";
  version = "4.0.604";
  src = fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}.AppImage";
    hash = "sha256-60PBTfbgYf73bCY2Qxqy8I2vMCziHf5Nuw78cpbVi/8=";
  };
  appimageContents = appimageTools.extractType2 {
    inherit version pname src;

    postExtract = ''
      # disable creating a desktop file and icon in the home folder during runtime
      linuxConfigFilename=$out/resources/app/build/main/linux-*.mjs
      echo "export function registerLinuxConfig() {}" > $linuxConfigFilename
      substituteInPlace $out/beepertexts.desktop --replace-fail "AppRun" "beeper"
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  extraPkgs = pkgs: [ pkgs.libsecret ];

  extraInstallCommands = ''
    install -Dm 644 ${appimageContents}/beepertexts.png $out/share/icons/hicolor/512x512/apps/beepertexts.png
    install -Dm 644 ${appimageContents}/beepertexts.desktop -t $out/share/applications/

    . ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/beeper \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update" \
      --set APPIMAGE beeper
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-beeper";
      runtimeInputs = [
        curl
        common-updater-scripts
      ];
      text = ''
        set -o errexit
        latestLinux="$(curl --silent --output /dev/null --write-out "%{redirect_url}\n" https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop)"
        version="$(echo "$latestLinux" |  grep --only-matching --extended-regexp '[0-9]+\.[0-9]+\.[0-9]+')"
        update-source-version beeper "$version" "" "https://beeper-desktop.download.beeper.com/builds/Beeper-$version.AppImage" --source-key=src.src
      '';
    });
  };

  meta = with lib; {
    description = "Universal chat app";
    longDescription = ''
      Beeper is a universal chat app. With Beeper, you can send
      and receive messages to friends, family and colleagues on
      many different chat networks.
    '';
    homepage = "https://beeper.com";
    license = licenses.unfree;
    maintainers = with maintainers; [
      jshcmpbll
      mjm
      edmundmiller
      zh4ngx
    ];
    platforms = [ "x86_64-linux" ];
  };
}
