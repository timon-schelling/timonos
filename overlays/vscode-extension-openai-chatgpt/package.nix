{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "chatgpt";
    publisher = "openai";
    version = "26.5721.30844";
    hash = "sha256-daZQ7nbGRhcCaHl3rtIEVrLSU+LKK3TpG9wK4twFkj0=";
  };
}
