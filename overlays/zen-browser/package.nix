{
  lib,
  stdenv,
  makeWrapper,
  wrapGAppsHook,
  copyDesktopItems,
  libGL,
  fontconfig,
  libxkbcommon,
  zlib,
  freetype,
  gtk3,
  libxml2,
  dbus,
  xcb-util-cursor,
  alsa-lib,
  pango,
  atk,
  cairo,
  gdk-pixbuf,
  glib,
  xorg,
}:

let
  version = "1.0.2-b.5";
  src = builtins.fetchTarball {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.bz2";
    sha256 = "sha256:1xp0z86l7z661cwckgr623gwwjsy3h66900xqjq6dvgx5a3njbxi";
  };
  runtimeLibs = [
        libGL stdenv.cc.cc fontconfig libxkbcommon zlib freetype
        gtk3 libxml2 dbus xcb-util-cursor alsa-lib pango atk cairo gdk-pixbuf glib
  ] ++ (with xorg; [
    libxcb libX11 libXcursor libXrandr libXi libXext libXcomposite libXdamage libXfixes libpciaccess
  ]);
in
stdenv.mkDerivation {
  pname = "zen";
  inherit version;
  inherit src;

  phases = [ "installPhase" "fixupPhase" ];

  nativeBuildInputs = [ makeWrapper copyDesktopItems wrapGAppsHook ] ;

  installPhase = ''
    mkdir -p $out/bin && cp -r $src/* $out/bin
    install -D $src/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/zen.png
  '';

  fixupPhase = ''
    chmod 755 $out/bin/*
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/zen
    wrapProgram $out/bin/zen --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/zen-bin
    wrapProgram $out/bin/zen-bin --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/glxtest
    wrapProgram $out/bin/glxtest --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/updater
    wrapProgram $out/bin/updater --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/vaapitest
    wrapProgram $out/bin/vaapitest --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
  '';

  passthru = {
    inherit gtk3; # needed in the wrapper
    libName = "zen";
    requireSigning = false;
    allowAddonSideload = true;
  };

  meta = {
    description = " Zen Browser, Your browser, your way!";
    mainProgram = "zen";
    homepage = "https://www.zen-browser.app/";
  };
}
