{
  stdenv,
  config,
  wrapGAppsHook3,
  autoPatchelfHook,
  patchelfUnstable,
  adwaita-icon-theme,
  dbus-glib,
  libXtst,
  curl,
  gtk3,
  alsa-lib,
  libva,
  pciutils,
  pipewire,
  writeText,
  fetchurl,
  ...
}:
let
  policies = {
    DisableAppUpdate = true;
  } // config.zen.policies or { };

  policiesJson = writeText "firefox-policies.json" (builtins.toJSON { inherit policies; });
in
stdenv.mkDerivation (finalAttrs: {
  version = "1.12.8b";
  pname = "zen-browser-unwrapped";
  applicationName = "Zen Browser";

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${finalAttrs.version}/zen.linux-x86_64.tar.xz";
    hash = "sha256-HOrFsHneMCb9fOGV15HWVTNiyYtEIqO/mGV+NNqjV8c=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = [
    gtk3
    alsa-lib
    adwaita-icon-theme
    dbus-glib
    libXtst
  ];

  runtimeDependencies = [
    curl
    libva.out
    pciutils
  ];

  appendRunpaths = [
    "${pipewire}/lib"
  ];

  installPhase = ''
    mkdir -p "$prefix/lib/zen-${finalAttrs.version}"
    cp -r * "$prefix/lib/zen-${finalAttrs.version}"

    mkdir -p $out/bin
    ln -s "$prefix/lib/zen-${finalAttrs.version}/zen" $out/bin/zen

    mkdir -p "$out/lib/zen-${finalAttrs.version}/distribution"
    ln -s ${policiesJson} "$out/lib/zen-${finalAttrs.version}/distribution/policies.json"
  '';

  patchelfFlags = [ "--no-clobber-old-sections" ];

  meta = {
    mainProgram = "zen";
    description = ''
      Zen is a privacy-focused browser that blocks trackers, ads, and other unwanted content while offering the best browsing experience!
    '';
  };

  passthru = {
    inherit gtk3;

    libName = "zen-${finalAttrs.version}";
    binaryName = finalAttrs.meta.mainProgram;
    gssSupport = true;
    ffmpegSupport = true;
  };
})
