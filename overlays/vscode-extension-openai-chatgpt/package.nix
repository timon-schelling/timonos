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
    hash = "sha256-0h/aLANzmCA9EJCi5yhPEOjDw9FqKh5c38GVcPK3VAg=";
  };

  postInstall = ''
    rm -rf "$out/$installPrefix/bin"
    mkdir -p "$out/$installPrefix/bin/linux-x86_64"
    ln -s "${lib.getExe codex}" "$out/$installPrefix/bin/linux-x86_64/codex"
  '';
}
