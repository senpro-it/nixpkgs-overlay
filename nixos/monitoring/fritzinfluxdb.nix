{ config, lib, pkgs, ... }:

with lib;

let
  /* FRITZ!Box monitoring config subtree. */
  fritzCfg = config.senpro.monitoring.fritzinfluxdb;

  /* Option schema for per-device inputs.
     @param name: Attribute name of the device.
     @return Submodule option set for each FRITZ!Box.
  */
  fritzinfluxdbOptions = {
    inputConfig = { name, ... }: {
      options = {
        name = mkOption {
          type = types.str;
          default = "${name}";
          example = "FRITZ1";
          description = ''
            Name of the FRITZ!Box (used as measurement tag in InfluxDB).
          '';
        };
        host = mkOption {
          type = types.str;
          example = "192.168.178.1";
          description = ''
            FQDN or IPv4 address of the FRITZ!Box.
          '';
        };
        user = mkOption {
          type = types.str;
          example = "admin";
          description = ''
            User to access the targeted FRITZ!Box via TR-064.
          '';
        };
        pass = mkOption {
          type = types.str;
          example = "your-secure-password";
          description = ''
            Password for the specified FRITZ!Box read-access user.
          '';
        };
      };
    };
  };

  /* Build a fritzinfluxdb container definition.
     @param opts: Per-device input configuration.
     @param name: Device attribute name.
     @return Container definition attribute set.
  */
  createFritzInfluxDBContainer = opts: name: {
    image = "docker.io/bbricardo/fritzinfluxdb:latest";
    autoStart = true;
    environment = {
      FRITZBOX_HOSTNAME = "${opts.host}";
      FRITZBOX_PORT = "49443";
      FRITZBOX_TLS_ENABLED = "true";
      FRITZBOX_USERNAME = "${opts.user}";
      FRITZBOX_PASSWORD = "${opts.pass}";
      FRITZBOX_BOX_TAG = "${opts.name}";
      INFLUXDB_VERSION = "2";
      INFLUXDB_HOSTNAME = "${fritzCfg.output.influxdb_v2.host}";
      INFLUXDB_PORT = "443";
      INFLUXDB_TLS_ENABLED = "true";
      INFLUXDB_ORGANISATION = "${fritzCfg.output.influxdb_v2.organization}";
      INFLUXDB_BUCKET = "${fritzCfg.output.influxdb_v2.bucket}";
      INFLUXDB_TOKEN = "${fritzCfg.output.influxdb_v2.token}";
      INFLUXDB_MEASUREMENT_NAME = "fritzbox";
    };
  };
in {
  /* fritzinfluxdb options. */
  options.senpro.monitoring.fritzinfluxdb = {
    enable = mkEnableOption ''
      Whether to enable fritzinfluxdb (FRITZ!Box monitoring agent).
    '';
    inputs = mkOption {
      default = {};
      type = with types; attrsOf (submodule fritzinfluxdbOptions.inputConfig);
      example = literalExpression ''
        {
          FRITZ1 = {
            host = "192.168.178.1";
            user = "fritz";
            pass = "your-secure-password";
          };
        }
      '';
      description = ''
        Per-host configuration for the FRITZ!Box devices which should be monitored.
      '';
    };
    output = {
      influxdb_v2 = {
        host = mkOption {
          type = types.str;
          example = "influxdb.example.com";
          description = ''
            FQDN of the targeted InfluxDB instance. Protocol is hardcoded to SSL over 443.
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
          default = "avm";
          example = "your-influxdb-bucket";
          description = ''
            InfluxDB bucket where the output should be delivered to.
          '';
        };
      };
    };
  };

  config = {
    /* Container definitions for each FRITZ!Box device. */
    virtualisation.oci-containers.containers =
      listToAttrs (
        (map (name: {
          name = "fritzinfluxdb-${name}";
          value = createFritzInfluxDBContainer (builtins.getAttr name fritzCfg.inputs) name;
        }) (builtins.attrNames fritzCfg.inputs))
      );
  };
}
