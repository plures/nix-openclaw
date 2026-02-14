{ config, lib, pkgs, ... }:

let
  cfg = config.services.pluresdb;
in
{
  options.services.pluresdb = {
    enable = lib.mkEnableOption "PluresDB — P2P graph database";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pluresdb-cli;
      defaultText = lib.literalExpression "pkgs.pluresdb-cli";
      description = "The PluresDB package to use.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/pluresdb";
      description = "Directory for PluresDB data storage.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "HTTP/WebSocket port for PluresDB API.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Bind address for PluresDB.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for PluresDB.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "pluresdb";
      description = "User account under which PluresDB runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "pluresdb";
      description = "Group under which PluresDB runs.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional PluresDB configuration as an attribute set.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      description = "PluresDB service user";
    };

    users.groups.${cfg.group} = {};

    systemd.services.pluresdb = {
      description = "PluresDB — P2P Graph Database";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/pluresdb serve --host ${cfg.host} --port ${toString cfg.port} --data-dir ${cfg.dataDir}";
        Restart = "on-failure";
        RestartSec = 5;

        # Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        PrivateTmp = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
