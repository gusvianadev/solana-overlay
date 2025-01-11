{ pkgs, rustStable, darwinPackages, rust-1_78 }:
let
  mkSolana = ({ rust ? rustStable, cargoOutputHashes ? { }, ... }@args:
    # este es el import de solana-packages.nix
    import ./solana-packages.nix {
      inherit pkgs rust darwinPackages cargoOutputHashes;
      inherit (args) version githubSha256;
      inherit (pkgs) lib;
      cargoLockFile = ./cargo/v${args.version}/Cargo.lock;
    });
in rec {
  solana-2_0_21 = mkSolana {
    version = "2.0.21";
    githubSha256 = "sha256-XmkWdJQXT8VFadfY675qs98MwlHjX8DkZLD9x6nrOWE=";
    cargoOutputHashes = {
      "curve25519-dalek-3.2.1" =
        "sha256-4MF/qaP+EhfYoRETqnwtaCKC1tnUJlBCxeOPCnKrTwQ=";
      "crossbeam-epoch-0.9.5" =
        "sha256-Jf0RarsgJiXiZ+ddy0vp4jQ59J9m0k3sgXhWhCdhgws=";
      "tokio-1.29.1" = "sha256-Z/kewMCqkPVTXdoBcSaFKG5GSQAdkdpj3mAzLLCjjGk=";
    };
  };
  solana-2_0 = solana-2_0_21;

  solana = solana-2_0;
}
