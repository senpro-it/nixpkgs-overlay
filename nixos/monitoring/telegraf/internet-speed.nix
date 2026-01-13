{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  settingsFormat = pkgs.formats.toml {};
  internetSpeedCfg = cfg.monitoring.telegraf.inputs.internet_speed;

in {
  options.senpro.monitoring.telegraf.inputs.internet_speed = {
    enable = mkEnableOption ''
      Whether to enable internet speed monitoring.
    '';
    settings = mkOption {
      type = settingsFormat.type;
      default = {};
      description = "Options passed straight into [[inputs.internet_speed]].";
      example = {
        interval = "60m";
        collection_jitter = "60s";
        cache = false;
        memory_saving_mode = true;
        test_mode = "multi";
        connections = 4;
        # server_id_include = [ 54619 ];
        # server_id_exclude = [ 9999 ];
      };
    };
  };

  config = {
    services.telegraf.extraConfig.processors.converter = lib.mkIf internetSpeedCfg.enable [
      {
        namepass = [ "internet.speed" ];
        tags = { string = [ "source" "server_id" "test_mode" ]; };
      }
    ];

    services.telegraf.extraConfig.inputs.internet_speed = lib.mkIf internetSpeedCfg.enable [
      (let s = internetSpeedCfg.settings; in
        # merge user settings with defaults (only when not provided)
        s
        // { name_override = "internet.speed"; }
        // lib.optionalAttrs (!(s ? interval))              { interval = "60m"; }
        // lib.optionalAttrs (!(s ? collection_jitter))     { collection_jitter = "60s"; }
        // lib.optionalAttrs (!(s ? memory_saving_mode))    { memory_saving_mode = true; }
        // lib.optionalAttrs (!(s ? cache))                 { cache = false; }
        // lib.optionalAttrs (!(s ? test_mode))             { test_mode = "multi"; }
        // lib.optionalAttrs (!(s ? connections))           { connections = 4; }
      )
    ];
  };
}
