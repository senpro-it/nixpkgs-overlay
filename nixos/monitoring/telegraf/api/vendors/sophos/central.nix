{ config, lib, mkInputConfig, telegrafOptions, pkgs, ... }:

with lib;

let
  /* Sophos Central API config subtree. */
  sophosCfg = config.senpro.monitoring.telegraf.inputs.api.vendors.sophos.central;
  /* Default exec input settings for the exporter wrapper. */
  execDefaults = {
    commands = [ "${pkgs.line-exporters}/bin/lxp-sophos-central '${sophosCfg.client.id}' '${sophosCfg.client.secret}'" ];
    timeout = "5m";
    interval = "900s";
    data_format = "influx";
  };
  /* Sanitized Telegraf exec input configuration. */
  execInputConfig = mkInputConfig (execDefaults // sophosCfg.exec);

in {
  /* Sophos Central API input options. */
  options.senpro.monitoring.telegraf.inputs.api.vendors.sophos.central = {
    enable = mkEnableOption ''
      Whether to enable the Sophos Central monitoring via API.
    '';
    client = {
      id = mkOption {
        type = types.str;
        example = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
        description = ''
          Client ID for the Sophos Central API (Tenant).
        '';
      };
      secret = mkOption {
        type = types.str;
        example = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
        description = ''
          Client Secret for the Sophos Central API (Tenant).
        '';
      };
    };
    exec = telegrafOptions.mkInputSettingsOption telegrafOptions.execInput
      "Options for the exec input.";
  };

  config = {
    services.telegraf.extraConfig.inputs.exec = lib.mkIf sophosCfg.enable [
      execInputConfig
    ];
  };
}
