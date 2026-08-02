{ lib, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover [
      (pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "in.kkkev.jj-idea";
        version = "0.8.1";
        src = pkgs.fetchzip {
          name = "jj-idea-${finalAttrs.version}";
          url = "https://downloads.marketplace.jetbrains.com/files/30576/1118793/jj-idea-${finalAttrs.version}.zip";
          hash = "sha256-6cMmyE0NPihqZvn2wzOIWsF2OIzb6/phCMn5aB7ThME=";
        };
        nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
        buildInputs = [ (lib.getLib pkgs.stdenv.cc.cc) ];
        buildPhase = ''
          runHook preBuild
          if [ -d bin ]; then
            chmod +x -R bin
          fi
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out && cp -r . $out
          runHook postInstall
        '';
      }))
    ])
  ];

  home-manager.users.user.opts.user.persist.state.folders = [
    ".config/JetBrains"
    ".local/share/JetBrains"
    ".cache/JetBrains"
    ".java"
  ];
}
