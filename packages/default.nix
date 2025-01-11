{ pkgs, rustStable, rust-1_78 }:
let
  darwinPackages = pkgs.lib.optionals pkgs.stdenv.isDarwin
    (with pkgs.darwin.apple_sdk.frameworks;
      ([ IOKit Security CoreFoundation AppKit ]
        ++ (pkgs.lib.optionals pkgs.stdenv.isAarch64 [ System ])));
  anchorPackages = import ./anchor {
    inherit rustStable;
    inherit (pkgs) lib pkg-config openssl stdenv udev fetchFromGitHub;
    inherit darwinPackages;
  };
  solanaPackages =
    (import ./solana { inherit pkgs rustStable darwinPackages rust-1_78; });

  solanaFlattened = with solanaPackages; {
    solana-2_0-basic = solana-2_0.solana-basic;
    solana-2_0-full = solana-2_0.solana-full;

    solana-basic = solana.solana-basic;
    solana-full = solana.solana-full;
  };
in anchorPackages // solanaFlattened // rec {
  spl-token-cli = pkgs.callPackage ./spl-token-cli.nix {
    inherit (rustStable) rustPlatform;
    inherit (pkgs.llvmPackages) libclang;
    inherit darwinPackages;
  };

  rust-stable = rustStable.rust;

  saber-dev-utilities = with pkgs;
    buildEnv {
      name = "saber-dev-utilities";
      meta.description = "Various CLI tools commonly used in development.";

      paths = [
        cargo-workspaces
        cargo-expand
        # cargo-deps
        cargo-readme

        curl
        gh
        gnused
        jq
        nixfmt
        rustup
        yj
      ];
    };

  saber-devenv = import ./saber-devenv.nix {
    inherit pkgs;
    inherit (anchorPackages) anchor;
    inherit (solanaPackages.solana) solana-basic;
    inherit saber-dev-utilities saber-rust-build-common;
  };

  saber-rust-build-common = with pkgs;
    buildEnv {
      name = "saber-rust-build-common";
      meta.description = "Common utilities for building Rust packages.";

      paths = [ pkg-config openssl zlib libiconv ]
        ++ (lib.optionals stdenv.isLinux ([ udev ]))
        ++ (lib.optionals stdenv.isDarwin
          (with darwin.apple_sdk.frameworks; [ AppKit IOKit Foundation ]));
    };
}
