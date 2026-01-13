{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;

in {
  options.senpro.monitoring.svci = {
    enable = mkEnableOption ''
      Whether to enable SVCi (Spectrum Virtualize Insights).
    '';
    input = {
      svc = {
        host = mkOption {
          type = types.str;
          example = "192.168.178.1";
          description = ''
            FQDN or IP address of an IBM SAN Volume Controller.
          '';
        };
        user = mkOption {
          type = types.str;
          example = "admin";
          description = ''
            User to access the targeted IBM SAN Volume Controller.
          '';
        };
        pass = mkOption {
          type = types.str;
          example = "your-secure-password";
          description = ''
            Password for the specified IBM SAN Volume Controller read-access monitoring user.
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
          default = "ibm";
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
      svci = lib.mkIf cfg.monitoring.svci.enable {
        image = "ghcr.io/senpro-it/svci:main";
        autoStart = true;
        volumes = [
          "svci:/config/svci"
        ];
        cmd = [ "--conf=/config/svci/svci.toml" ];
      };
    };

    systemd.services = {
      docker-svci-provisioner = lib.mkIf cfg.monitoring.svci.enable {
        enable = true;
        description = "Provisioner for SVCi docker container.";
        requiredBy = [ "docker-svci.service" ];
        restartIfChanged = true;
        preStart = ''
          ${pkgs.docker-client}/bin/docker volume create svci
          ${pkgs.coreutils-full}/bin/printf "%s\n" \
            "# SVCi Configuration" \
            "# Copy this file into /etc/svci.toml and customize it to your environment." \
            "" \
            "###" \
            "### Define one InfluxDB to save metrics into" \
            "### There must be only one and it should be named [influx]" \
            "###" \
            "" \
            "[influx]" \
            "url = \"${cfg.monitoring.svci.output.influxdb_v2.url}\"" \
            "org = \"${cfg.monitoring.svci.output.influxdb_v2.organization}\"" \
            "token = \"${cfg.monitoring.svci.output.influxdb_v2.token}\"" \
            "bucket = \"${cfg.monitoring.svci.output.influxdb_v2.bucket}\"" \
            "" \
            "[svc.ibm]" \
            "url = \"https://${cfg.monitoring.svci.input.svc.host}:7443\"" \
            "username = \"${cfg.monitoring.svci.input.svc.user}\"" \
            "password = \"${cfg.monitoring.svci.input.svc.pass}\"" \
            "refresh = 30   # How often to query SVC for data - in seconds" \
            "trust = true   # Ignore SSL cert. errors (due to default self-signed cert.)" > /var/lib/docker/volumes/svci/_data/svci.toml
        '';
        postStop = ''
          ${pkgs.coreutils-full}/bin/rm -f /var/lib/docker/volumes/svci/_data/svci.toml
          ${pkgs.docker-client}/bin/docker volume delete svci
        '';
        serviceConfig = { ExecStart = ''${pkgs.bashInteractive}/bin/bash -c "while true; do echo 'docker-svci-provisioner is up & running'; sleep 1d; done"''; };
      };
    };
  };
}
