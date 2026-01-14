{ config, lib, ... }:

with lib;

let
  /* Shared Telegraf option helpers. */
  telegrafOptions = import ./options.nix { inherit lib; };
  /* Internet speed input configuration subtree. */
  internetSpeedCfg = config.senpro.monitoring.telegraf.inputs.internet_speed;
  /* Default Telegraf settings for the internet_speed input. */
  speedDefaults = {
    name_override = "internet.speed";
    interval = "60m";
    collection_jitter = "60s";
    memory_saving_mode = true;
    cache = false;
    test_mode = "multi";
    connections = 4;
  };
  /* Merge defaults with user-specified overrides. */
  speedSettings = speedDefaults // internetSpeedCfg.settings;
  /* Strip null values before serializing to TOML. */
  speedConfig = lib.filterAttrs (_: v: v != null) speedSettings;
  /* Sanitized Telegraf config for the input. */
  speedInputConfig = telegrafOptions.sanitizeToml speedConfig;
  /* Converter processor to coerce tags into strings. */
  converterConfig = telegrafOptions.sanitizeToml {
    namepass = [ speedSettings.name_override ];
    tags = { string = [ "source" "server_id" "test_mode" ]; };
  };

in {
  /* Internet speed input options. */
  options.senpro.monitoring.telegraf.inputs.internet_speed = {
    enable = mkEnableOption ''
      Whether to enable internet speed monitoring.
    '';
    settings = telegrafOptions.mkInputSettingsOption telegrafOptions.internetSpeedInput
      "Options for the internet_speed input.";
  };

  config = {
    services.telegraf.extraConfig.processors.converter = lib.mkIf internetSpeedCfg.enable [
      converterConfig
    ];

    services.telegraf.extraConfig.inputs.internet_speed = lib.mkIf internetSpeedCfg.enable [
      speedInputConfig
    ];
  };
}
