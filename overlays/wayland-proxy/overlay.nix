inputs: self: super: rec {
  wayland-proxy = super.wayland-proxy-virtwl.overrideAttrs (old: {
      version = "0-unstable-2025-01-07";
      src = self.fetchFromGitHub {
        owner = "talex5";
        repo = "wayland-proxy-virtwl";
        rev = "a49bb541a7b008e13be226b3aaf0c4bda795af26";
        sha256 = "sha256-lX/ccHV1E7iAuGqTig+fvcY22qyk4ZJui17nLotaWjw=";
      };
  });
  wayland-proxy-virtwl = wayland-proxy;
}
