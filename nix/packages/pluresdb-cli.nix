{ pkgs, lib ? pkgs.lib, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "pluresdb-cli";
  version = "1.6.11";

  src = pkgs.fetchFromGitHub {
    owner = "plures";
    repo = "pluresdb";
    rev = "v${version}";
    hash = lib.fakeHash;  # TODO: build once to get real hash
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    # If there are git dependencies, add outputHashes here:
    # outputHashes = {
    #   "some-dep-0.1.0" = lib.fakeHash;
    # };
  };

  # Build only the CLI crate from the workspace
  cargoBuildFlags = [ "-p" "pluresdb-cli" ];
  cargoTestFlags = [ "-p" "pluresdb-cli" ];

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
    sqlite
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = with lib; {
    description = "PluresDB CLI — P2P graph database with SQLite compatibility";
    homepage = "https://github.com/plures/pluresdb";
    license = licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "pluresdb";
  };
}
