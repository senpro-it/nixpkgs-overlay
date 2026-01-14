{ config, lib, ... }:

with lib;

let
  /* Shared Telegraf option helpers. */
  telegrafOptions = import ./options.nix { inherit lib; };
  /* Ping input configuration subtree. */
  pingCfg = config.senpro.monitoring.telegraf.inputs.ping;
  /* Default Telegraf settings for the ping input. */
  pingDefaults = {
    name_override = "ping";
    method = "native";
  };
  /* Merge defaults with user overrides. */
  pingSettings = pingDefaults // pingCfg.settings;
  /* Attach URLs to the settings payload. */
  pingSettingsWithUrls = pingSettings // {
    urls = pingCfg.urls;
  };
  /* Strip null values before serializing. */
  pingConfig = lib.filterAttrs (_: v: v != null) pingSettingsWithUrls;
  /* Sanitized Telegraf config for the ping input. */
  pingInputConfig = telegrafOptions.sanitizeToml pingConfig;

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
    services.telegraf.extraConfig.inputs.ping = lib.mkIf pingCfg.enable [
      pingInputConfig
    ];
  };
}
