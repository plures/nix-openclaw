{ pkgs, lib ? pkgs.lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "praxis";
  version = "1.2.17";

  src = pkgs.fetchFromGitHub {
    owner = "plures";
    repo = "praxis";
    rev = "v${version}";
    hash = lib.fakeHash;  # TODO: build once to get real hash
  };

  npmDepsHash = lib.fakeHash;  # TODO: build once to get real hash

  # The CLI entry point
  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/praxis \
      --add-flags "$out/lib/node_modules/@plures/praxis/dist/node/cli/index.js"
  '';

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  meta = with lib; {
    description = "Praxis — declarative logic engine for the Plures ecosystem";
    homepage = "https://github.com/plures/praxis";
    license = licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "praxis";
  };
}
