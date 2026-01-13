{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;

in {
  options.senpro.monitoring.unifi-poller = {
    enable = mkEnableOption ''
      Whether to enable the UniFi poller (Ubiquiti monitoring agent).
    '';
    input = {
      unifi-controller = {
        url = mkOption {
          type = types.str;
          example = "https://unifictrl.example.com:8443/";
          description = ''
            URL of the targeted UniFi controller.
          '';
        };
        user = mkOption {
          type = types.str;
          example = "admin";
          description = ''
            User to access the targeted UniFi controller.
          '';
        };
        pass = mkOption {
          type = types.str;
          example = "your-secure-password";
          description = ''
            Password for the specified UniFi controller read-access user.
          '';
        };
      };
    };
    output = {
      influxdb_v2 = {
        url = mkOption {
          type = types.str;
          example = "https://influxdb.example.com/";
          description = ''
            URL of the targeted InfluxDB instance.
          '';
        };
        token = mkOption {
          type = types.str;
          example = "your-influxdb-token";
          description = ''
            Token for the the targeted InfluxDB instance.
          '';
        };
        organization = mkOption {
          type = types.str;
          example = "your-influxdb-org";
          description = ''
            InfluxDB organization where the targeted bucket resides.
          '';
        };
        bucket = mkOption {
          type = types.str;
          default = "ubiquiti";
          example = "your-influxdb-bucket";
          description = ''
            InfluxDB bucket where the output should be delivered to.
          '';
        };
      };
    };
  };

  config = {
    virtualisation.oci-containers.containers = {
      unifi-poller = lib.mkIf cfg.monitoring.unifi-poller.enable {
        image = "ghcr.io/unpoller/unpoller:latest-arm64v8";
        autoStart = true;
        environment = {
          UP_INFLUXDB_URL = "${cfg.monitoring.unifi-poller.output.influxdb_v2.url}";
          UP_INFLUXDB_ORG = "${cfg.monitoring.unifi-poller.output.influxdb_v2.organization}";
          UP_INFLUXDB_BUCKET = "${cfg.monitoring.unifi-poller.output.influxdb_v2.bucket}";
          UP_INFLUXDB_AUTH_TOKEN = "${cfg.monitoring.unifi-poller.output.influxdb_v2.token}";
          UP_UNIFI_DEFAULT_USER = "${cfg.monitoring.unifi-poller.input.unifi-controller.user}";
          UP_UNIFI_DEFAULT_PASS = "${cfg.monitoring.unifi-poller.input.unifi-controller.pass}";
          UP_UNIFI_DEFAULT_URL = "${cfg.monitoring.unifi-poller.input.unifi-controller.url}";
          UP_POLLER_DEBUG = "true";
        };
      };
    };
  };
}
