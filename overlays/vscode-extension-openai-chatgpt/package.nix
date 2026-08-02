{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "chatgpt";
    publisher = "openai";
    version = "26.5721.30844";
    hash = "sha256-iT4v/aZ+3U1m0ykrZI2/mWUHV3ezbnhA8IiUfbgu73c=";
  };
}
