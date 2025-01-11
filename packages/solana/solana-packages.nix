{ pkgs, lib, validatorOnly ? false, rust, darwinPackages, version, githubSha256
, cargoLockFile, cargoOutputHashes, }:
let
  mkSolana = args:
    (pkgs.callPackage ./solana.nix ({
      inherit (rust) rustPlatform;
      inherit (pkgs)
        lib pkg-config udev openssl zlib fetchFromGitHub stdenv protobuf rustfmt
        perl;
      inherit (pkgs.llvmPackages_12) clang llvm libclang;
      inherit darwinPackages;
      inherit version githubSha256 cargoLockFile cargoOutputHashes;
    } // args));
in {
  # This is the ideal package to use.
  # However, it does not build on Darwin.
  solana-full = mkSolana { };

  solana-basic = mkSolana {
    name = "solana-basic";
    solanaPkgs = [
      "agave-accounts-hash-cache-tool"
      "agave-cargo-registry"
      "agave-install"
      "agave-install-init"
      "agave-ledger-tool"
      "agave-store-tool"
      "agave-validator"
      "agave-watchtower"
      "cargo-build-bpf"
      "cargo-build-sbf"
      "cargo-test-bpf"
      "cargo-test-sbf"
      "gen-headers"
      "gen-syscall-list"
      "proto"
      "rbpf-cli"
      "solana"
      "solana-accounts-bench"
      "solana-accounts-cluster-bench"
      "solana-banking-bench"
      "solana-bench-streamer"
      "solana-bench-tps"
      "solana-dos"
      "solana-faucet"
      "solana-gossip"
      "solana-ip-address"
      "solana-ip-address-server"
      "solana-keygen"
      "solana-ledger-udev"
      "solana-log-analyzer"
      "solana-merkle-root-bench"
      "solana-net-shaper"
      "solana-poh-bench"
      "solana-stake-accounts"
      "solana-test-validator"
      "solana-tokens"
      "solana-transaction-dos"
      "solana-upload-perf"
      "solana-zk-keygen"
      # Speed up net.sh deploys by excluding unused binaries
    ] ++ [
      # XXX: Ensure `solana-genesis` is built LAST!
      # See https://github.com/solana-labs/solana/issues/5826
      "solana-genesis"
    ];
  };
}
