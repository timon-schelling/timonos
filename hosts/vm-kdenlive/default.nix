{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-persist
  ];

  config =
    let
      srt_equalizer = pkgs.python3Packages.buildPythonPackage rec {
        pname = "srt_equalizer";
        version = "0.1.10";
        pyproject = true;

        src = pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-X2sbLEixK7HKqxOCLX3dClSod3K4JKCqK6ZMAz03k1M=";
        };
        doCheck = false;
        nativeBuildInputs = [
          pkgs.python3Packages.poetry-core
        ];
        propagatedBuildInputs = [
          pkgs.python3Packages.srt
        ];
      };
    in
    {
      environment.systemPackages = with pkgs; [
        (kdePackages.kdenlive.overrideAttrs (old: {
          qtWrapperArgs = old.qtWrapperArgs ++ [
            "--suffix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name}"
          ];
        }))
        kdePackages.breeze
        (python3.withPackages (
          python-pkgs: with python-pkgs; [
            openai-whisper
            srt
            srt_equalizer
            numba
            numpy
            torch
            pip
          ]
        ))
      ];
    };
}
