final: prev:
let
  mkRust = rust: {
    inherit rust;
    rustPlatform = prev.recurseIntoAttrs (prev.makeRustPlatform {
      rustc = rust;
      cargo = rust;
    });
  };
  rust-1_78 = mkRust prev.rust-bin.stable."1.78.0".minimal;
  rustStable = mkRust prev.rust-bin.stable."1.76.0".minimal;
  saberPackages = (import ./packages {
    inherit rustStable rust-1_78;
    pkgs = prev;
  });
in saberPackages // {
  saber = saberPackages // {
    default = import ./env.nix { pkgs = prev // saberPackages; };
  };
}
