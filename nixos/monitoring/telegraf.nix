{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ./telegraf/options.nix { inherit lib; };
  settingsFormat = pkgs.formats.toml {};
  outputsCfg = telegrafOptions.sanitizeToml cfg.monitoring.telegraf.outputs;

in {
  imports = [
    ./telegraf/api.nix
    ./telegraf/internet-speed.nix
    ./telegraf/local-pi.nix
    ./telegraf/ping.nix
    ./telegraf/snmp/default.nix
    ./telegraf/webhook.nix
  ];

  options.senpro.monitoring.telegraf = {
    enable = mkEnableOption ''
      Whether to enable the telegraf monitoring agent.
    '';
    outputs = mkOption {
      default = {};
      description = "Output configuration for telegraf";
      type = settingsFormat.type;
      example = {
        influxdb_v2 = {
          urls = [ "https://influxdb.example.com/" ];
          token = "your-influxdb-token";
          organization = "ExampleOrg";
          bucket = "ExampleBucket";
          namepass = [ "sophos" ];
        };
      };
    };
  };

  config = {
    services.telegraf = lib.mkIf cfg.monitoring.telegraf.enable {
      enable = true;
      extraConfig = {
        agent = {
          interval = "60s";
          snmp_translator = "gosmi";
        };
        outputs = outputsCfg;
      };
    };
  };
}
