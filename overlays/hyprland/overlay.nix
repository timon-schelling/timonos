inputs: self: super: {
  hyprland = super.hyprland.overrideAttrs (oldAttrs: rec {
    version = "0.45.2";
    src = super.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprland";
      fetchSubmodules = true;
      tag = "v${version}";
      hash = "sha256-1pNsLGNStCFjXiBc2zMUxKzKk45CePTf+GwKlzTmrCY=";
    };
  });
  aquamarine = super.aquamarine.overrideAttrs (oldAttrs: rec {
    version = "0.4.4";
    src = super.fetchFromGitHub {
      owner = "hyprwm";
      repo = "aquamarine";
      rev = "v${version}";
      hash = "sha256-6DQM7jT2CzfxYceyrtcBQSL9BOEGfuin8GAyMjCpAzc=";
    };
  });
}
