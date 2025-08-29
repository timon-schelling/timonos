{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook3,
  atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  pango,
  wayland,
  gtk-layer-shell,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "anyrun";
  version = "0-unstable-2025-08-29";

  src = fetchFromGitHub {
    owner = "timon-schelling";
    repo = "anyrun";
    rev = "097020ea7e04e7f4323bc7bee3d658a7ef9e2409";
    hash = "sha256-AFzRNrcR6pVi4wIjz8GpJb7V4TTiIKW82AnG7IHY8b0=";
  };

  cargoHash = "sha256-KpAnfytTtCJunhpk9exv8LYtF8mKDGFUUbsPP47M+Kk=";

  strictDeps = true;
  enableParallelBuilding = true;
  doCheck = true;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    gtk-layer-shell
    pango
    wayland
  ];

  preFixup = ''
    gappsWrapperArgs+=(
     --prefix ANYRUN_PLUGINS : $out/lib
    )
  '';

  postInstall = ''
    install -Dm444 anyrun/res/style.css examples/config.ron -t $out/share/doc/anyrun/examples/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Wayland-native, highly customizable runner";
    homepage = "https://github.com/anyrun-org/anyrun";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      khaneliman
      NotAShelf
    ];
    mainProgram = "anyrun";
    platforms = lib.platforms.linux;
  };
}
