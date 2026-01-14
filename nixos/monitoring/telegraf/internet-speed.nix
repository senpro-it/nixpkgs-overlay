{ config, lib, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ./options.nix { inherit lib; };
  internetSpeedCfg = cfg.monitoring.telegraf.inputs.internet_speed;
  speedDefaults = {
    name_override = "internet.speed";
    interval = "60m";
    collection_jitter = "60s";
    memory_saving_mode = true;
    cache = false;
    test_mode = "multi";
    connections = 4;
  };
  speedSettings = speedDefaults // internetSpeedCfg.settings;
  speedConfig = lib.filterAttrs (_: v: v != null) speedSettings;

in {
  options.senpro.monitoring.telegraf.inputs.internet_speed = {
    enable = mkEnableOption ''
      Whether to enable internet speed monitoring.
    '';
    settings = telegrafOptions.mkInputSettingsOption telegrafOptions.internetSpeedInput
      "Options for the internet_speed input.";
  };

  config = {
    services.telegraf.extraConfig.processors.converter = lib.mkIf internetSpeedCfg.enable [
      (telegrafOptions.sanitizeToml {
        namepass = [ speedSettings.name_override ];
        tags = { string = [ "source" "server_id" "test_mode" ]; };
      })
    ];

    services.telegraf.extraConfig.inputs.internet_speed = lib.mkIf internetSpeedCfg.enable [
      (telegrafOptions.sanitizeToml speedConfig)
    ];
  };
}
