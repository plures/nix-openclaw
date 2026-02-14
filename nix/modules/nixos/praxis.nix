{ config, lib, pkgs, ... }:

let
  cfg = config.services.praxis;
in
{
  options.services.praxis = {
    enable = lib.mkEnableOption "Praxis — declarative logic engine";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.praxis;
      defaultText = lib.literalExpression "pkgs.praxis";
      description = "The Praxis package to use.";
    };

    database = lib.mkOption {
      type = lib.types.str;
      default = "localhost:${toString config.services.pluresdb.port}";
      description = "PluresDB connection string (host:port).";
    };

    rulesDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Directory containing Praxis rule files (.praxis).";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "List of Praxis plugin packages to load.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra command-line arguments for Praxis.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "praxis";
      description = "User account under which Praxis runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "praxis";
      description = "Group under which Praxis runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Praxis typically needs PluresDB
    assertions = [
      {
        assertion = config.services.pluresdb.enable || cfg.database != "localhost:${toString config.services.pluresdb.port}";
        message = "services.praxis requires services.pluresdb.enable or an explicit database connection string.";
      }
    ];

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "Praxis service user";
    };

    users.groups.${cfg.group} = {};

    systemd.services.praxis = {
      description = "Praxis — Declarative Logic Engine";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ] ++ lib.optional config.services.pluresdb.enable "pluresdb.service";
      requires = lib.optional config.services.pluresdb.enable "pluresdb.service";

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = lib.concatStringsSep " " ([
          "${cfg.package}/bin/praxis"
          "serve"
          "--database" cfg.database
        ] ++ lib.optional (cfg.rulesDir != null) "--rules ${cfg.rulesDir}"
          ++ cfg.extraArgs
        );
        Restart = "on-failure";
        RestartSec = 5;

        # Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
      };
    };
  };
}
