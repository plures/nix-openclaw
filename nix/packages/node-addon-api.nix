{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "node-addon-api";
  version = "8.5.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/node-addon-api/-/node-addon-api-8.5.0.tgz";
    hash = "sha256-0S8HyBYig7YhNVGFXx2o2sFiMxN0YpgwteZA8TDweRA=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = "${../scripts/node-addon-api-install.sh}";
}
