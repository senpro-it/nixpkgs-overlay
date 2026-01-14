{ config, lib, pkgs, ... }:

with lib;

let
  /* Root config subtree for the Telegraf module. */
  telegrafCfg = config.senpro.monitoring.telegraf;
  /* Shared helpers for building Telegraf option schemas. */
  telegrafOptions = import ./telegraf/options.nix { inherit lib; };
  /* TOML format helper for output options. */
  settingsFormat = pkgs.formats.toml {};
  /* Sanitized Telegraf output configuration. */
  outputsCfg = telegrafOptions.sanitizeToml telegrafCfg.outputs;
  /* Sanitized Telegraf input configuration. */
  inputsCfg = telegrafOptions.sanitizeToml telegrafCfg.rawInputs;

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
    rawInputs = mkOption {
      default = {};
      internal = true;
      description = "Unsanitized Telegraf input fragments.";
      type = types.attrsOf types.anything;
    };
  };

  config = {
    _module.args = {
      inherit telegrafOptions;
    };

    services.telegraf = lib.mkIf telegrafCfg.enable {
      enable = true;
      extraConfig = {
        agent = {
          interval = "60s";
          snmp_translator = "gosmi";
        };
        outputs = outputsCfg;
        inputs = inputsCfg;
      };
    };
  };
}
