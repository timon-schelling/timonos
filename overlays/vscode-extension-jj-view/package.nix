{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "jj-view";
    publisher = "jj-view";
    version = "2.5.1";
    hash = "sha256-TBDHprGNQ28/31az5VXt0NCGu0zFMMNwL0Tm+GskHwo=";
  };
}
