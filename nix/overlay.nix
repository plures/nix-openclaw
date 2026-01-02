self: super:
let
  sourceInfo = import ./sources/clawdis-source.nix;
  clawdisGateway = super.callPackage ./packages/clawdis-gateway.nix {
    inherit sourceInfo;
  };
in {
  clawdis-gateway = clawdisGateway;
}
