{ config, lib, telegrafOptions, ... }:

with lib;

let
  /* Ping input configuration subtree. */
  pingCfg = config.senpro.monitoring.telegraf.inputs.ping;
  /* Default Telegraf settings for the ping input. */
  pingDefaults = {
    name_override = "ping";
    method = "native";
  };
  /* Telegraf config for the ping input. */
  pingInputConfig = pingDefaults // pingCfg.settings // {
    urls = pingCfg.urls;
  };

in {
  /* Ping input options. */
  options.senpro.monitoring.telegraf.inputs.ping = {
    enable = mkEnableOption ''
      Whether to enable Ping.
    '';
    urls = mkOption {
      type = types.listOf types.str;
      example = literalExpression ''
        [ "192.168.0.1" ]
      '';
      description = ''
        Hosts to be pinged
      '';
    };
    settings = telegrafOptions.mkInputSettingsOption telegrafOptions.pingInput
      "Options for the ping input.";
  };

  config = {
    senpro.monitoring.telegraf.rawInputs.ping = lib.mkIf pingCfg.enable [
      pingInputConfig
    ];
  };
}
