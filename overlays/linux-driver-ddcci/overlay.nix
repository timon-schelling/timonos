inputs: self: super: {
  linuxPackages_latest = super.linuxPackages_latest.extend (_: _:{
    ddcci-driver = super.linuxPackages_latest.ddcci-driver.overrideAttrs (oldAttrs: {
      version = super.linuxPackages_latest.ddcci-driver.version + "-fixed";
      src = self.fetchFromGitLab {
        owner = "ddcci-driver-linux";
        repo = "ddcci-driver-linux";
        rev = "e0605c9cdff7bf3fe9587434614473ba8b7e5f63";
        hash = "sha256-ic6qmWqj7+Ga5SGgMOckDwa5ouyvpW1LlZhY1OBr9Gk=";
      };
      patches = [ ];
    });
  });
}
