{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "chatgpt";
    publisher = "openai";
    version = "26.5422.71525";
    hash = "sha256-9Z2rx9RISjpwUnD4Zk6RUyBPkyf8MNEho8xA2Iv1E5s=";
  };
}
