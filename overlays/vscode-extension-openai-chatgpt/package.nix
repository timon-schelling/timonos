{
  lib,
  codex,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "chatgpt";
    publisher = "openai";
    version = "26.5908.31748";
    hash = "sha256-9KtSVNm2LsrZrQu5B4XGt3W33nDJQEJKK4ATa1vluL8=";
  };

  postInstall = ''
    mkdir -p $out/bin/linux-x86_64
    ln -sf "${lib.getExe codex}" "$out/bin/linux-x86_64/codex"
  '';
}
