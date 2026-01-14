{ config, lib, pkgs, ... }:

with lib;

let
  telegrafOptions = import ../../../options.nix { inherit lib; };
  sophosCfg = config.senpro.monitoring.telegraf.inputs.api.vendors.sophos.central;
  execDefaults = {
    commands = [ "${pkgs.line-exporters}/bin/lxp-sophos-central '${sophosCfg.client.id}' '${sophosCfg.client.secret}'" ];
    timeout = "5m";
    interval = "900s";
    data_format = "influx";
  };
  execSettings = execDefaults // sophosCfg.exec;
  execConfig = lib.filterAttrs (_: v: v != null) execSettings;

in {
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
      (telegrafOptions.sanitizeToml execConfig)
    ];
  };
}
