{
  description = "Nix overlay for StableSwap projects.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-20.09";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlay (import ./default.nix) ];
        };
        env = import ./env.nix { inherit pkgs; };
      in {
        packages =
          flake-utils.lib.flattenTree { stableswap = pkgs.stableswap; };
        devShell = import ./shell.nix { inherit pkgs; };
        defaultPackage = env;
      });
}
