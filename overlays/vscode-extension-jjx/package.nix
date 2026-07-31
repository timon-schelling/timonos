{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "jjx";
    publisher = "jjx";
    version = "1.10.0";
    hash = "sha256-/4We4t8qUtRU1LR7KG9hjwRYmiQqqYAaWB1gdWRlHfg=";
  };
}
