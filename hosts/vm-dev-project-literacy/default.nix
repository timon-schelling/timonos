{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
    ../vm-base-lang-rust
    ../vm-dev-rust-leptos
  ];

  config = {
    environment.systemPackages = [
      pkgs.piper-tts
      pkgs.whisper-cpp
      pkgs.whisperx
      pkgs.ffmpeg
      (pkgs.callPackage
        ({ fetchFromGitHub, python3Packages }: python3Packages.buildPythonApplication {
          pname = "ctc-forced-aligner";
          version = "unstable-2025-04-06";
          src = fetchFromGitHub {
            owner = "MahmoudAshraf97";
            repo = "ctc-forced-aligner";
            rev = "201276a4ea2ddd3f5caead1ac4f211477ae3da6d";
            hash = "sha256-xReCGuOq3o/PawhFlkTW3BobMLR5tvucgUNY8crIOZQ=";
          };
          doCheck = false;
          pyproject = true;
          build-system = with python3Packages; [
            setuptools
          ];
          dependencies = with python3Packages; [
            nltk
            torch
            torchaudio
            transformers
            unidecode
          ];
        })
        {}
      )
      (pkgs.callPackage
        ({ fetchFromGitHub, python3Packages }: python3Packages.buildPythonApplication {
          pname = "uroman";
          version = "unstable-2025-04-06";
          src = fetchFromGitHub {
            owner = "isi-nlp";
            repo = "uroman";
            rev = "86a196e363e98df2ba0e86b4ea690676519817f2";
            hash = "sha256-fusCo25gc2UCExAhU/UR+veoAw8y4UKza3l35FqPsnI=";
          };
          doCheck = false;
          pyproject = true;
          build-system = with python3Packages; [
            setuptools
          ];
          dependencies = with python3Packages; [
            regex
            hatchling
          ];
        })
        {}
      )
      (pkgs.python3.withPackages (p: with p; [
        numpy
        torch
        safetensors
      ]))
    ];
  };
}
