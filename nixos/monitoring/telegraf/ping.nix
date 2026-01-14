{ config, lib, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ./options.nix { inherit lib; };
  pingCfg = cfg.monitoring.telegraf.inputs.ping;
  pingDefaults = {
    name_override = "ping";
    method = "native";
  };
  pingSettings = pingDefaults // pingCfg.settings;
  pingConfig = lib.filterAttrs (_: v: v != null) (pingSettings // {
    urls = pingCfg.urls;
  });

in {
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
    services.telegraf.extraConfig.inputs.ping = lib.mkIf pingCfg.enable [
      (telegrafOptions.sanitizeToml pingConfig)
    ];
  };
}
