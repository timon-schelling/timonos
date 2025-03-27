{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "docker-lock";
  version = "unstable-2025-03-18";

  src = fetchFromGitHub {
    owner = "michaelperel";
    repo = "docker-lock";
    rev = "b98399e9721bf66e63d21b28250c9eb9a0bc5c8f";
    hash = "sha256-hYJ/sZKB5T8wwd9sIxo01ZGbGbd7+KXY7GAkMzNrbvo=";
  };

  vendorHash = "sha256-2fE8Nzm7QheIihE0z0/N5zUJtC+G2B9IAKG63AWvyHc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  subPackages = [ "./cmd/docker-lock" ];

  tags = [ "release" ];

  installPhase = ''
    runHook preInstall
    install -D $GOPATH/bin/docker-lock $out/libexec/docker/cli-plugins/docker-lock
    mkdir -p $out/bin
    ln -s $out/libexec/docker/cli-plugins/docker-lock $out/bin/docker-lock
    runHook postInstall
  '';

  meta = {
    license = lib.licenses.asl20;
    mainProgram = "docker-lock";
  };
}
