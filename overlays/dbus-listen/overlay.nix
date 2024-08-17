inputs: self: super:

let
  src = super.fetchFromGitHub {
    owner = "timon-schelling";
    repo = "dbus-listen-haskell";
    rev = "180dfb4290c2587b16e18906cce481c87fda1dbd";
    hash = "sha256-WU3e7F0iNrxiS7WXzNbxnBp4oIru2pLihKbVIR236J4=";
  };
in
{
  dbus-listen = super.haskellPackages.callCabal2nix "dbus-listen" src {};
}
