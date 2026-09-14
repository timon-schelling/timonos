inputs: self: super: {
  cage = super.cage.overrideAttrs {
    src = self.fetchFromGitHub {
      owner = "cage-kiosk";
      repo = "cage";
      rev = "ef6ef6a54b646db1dd468e69f3948765838a3c5b";
      hash = "sha256-3/7MeLKPFVa2BMs7kQe1PlvT24sAoDGTDgy52tFVR+g=";
    };
  };
}
