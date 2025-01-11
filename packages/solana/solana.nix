# Some of this file is taken from https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/blockchains/solana/default.nix
{ name ? "solana", lib, validatorOnly ? false, rustPlatform, clang, llvm
, pkg-config, udev, openssl, zlib, libclang, fetchFromGitHub, stdenv
, darwinPackages, darwin, libcxx, protobuf, rustfmt, cargoLockFile, version
, githubSha256, perl, cargoOutputHashes, rocksdb
, # Taken from https://github.com/solana-labs/solana/blob/master/scripts/cargo-install-all.sh#L84
solanaPkgs ? [
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
] }:

let
  inherit (darwin.apple_sdk_11_0) Libsystem;
  inherit (darwin.apple_sdk_11_0.frameworks) System IOKit AppKit Security;
in rustPlatform.buildRustPackage rec {
  pname = name;
  inherit version;

  src = fetchFromGitHub {
    owner = "anza-xyz";
    repo = "agave";
    rev = "v${version}";
    sha256 = githubSha256;
  };

  # partly inspired by https://github.com/obsidiansystems/solana-bridges/blob/develop/default.nix#L29
  cargoLock = {
    lockFile = cargoLockFile;
    outputHashes = cargoOutputHashes;
  };

  cargoBuildFlags = builtins.map (n: "--bin=${n}") solanaPkgs;

  nativeBuildInputs = [ clang llvm pkg-config protobuf rustfmt perl ];
  buildInputs = [ openssl rustPlatform.bindgenHook zlib libclang rocksdb ]
    ++ lib.optionals stdenv.isLinux [ udev ] ++ lib.optionals stdenv.isDarwin [
      libcxx
      IOKit
      Security
      AppKit
      System
      Libsystem
    ];
  strictDeps = true;

  postInstall = ''
    mkdir -p $out/bin/sdk/bpf
    cp -a ./sdk/sbf/* $out/bin/sdk/bpf/

    mkdir -p $out/bin/sdk/sbf
    cp -a ./sdk/sbf/* $out/bin/sdk/sbf/
  '';

  # this is too slow
  doCheck = false;

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # Require this on darwin otherwise the compiler starts rambling about missing
  # cmath functions
  CPPFLAGS = lib.optionals stdenv.isDarwin
    "-isystem ${lib.getDev libcxx}/include/c++/v1";
  LDFLAGS = lib.optionals stdenv.isDarwin "-L${lib.getLib libcxx}/lib";

  # If set, always finds OpenSSL in the system, even if the vendored feature is enabled.
  OPENSSL_NO_VENDOR = 1;
}
