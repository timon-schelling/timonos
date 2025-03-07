{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "contain";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "timon-schelling";
    repo = "contain";
    rev = "cd559cd41ad03bfe79687aa1a6025aaf536d3e66";
    hash = "sha256-7DzMTD4JtvD4c8vVM5GbLMK05Go2kkOrGmRlDqeuUU4=";
  };

  cargoHash = "sha256-3zun5AVP8mFJEtg3WmuyPumDmGyiz9/Hh5ekg60ciJc=";
}
