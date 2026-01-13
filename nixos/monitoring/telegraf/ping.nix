{ config, lib, ... }:

with lib;

let
  cfg = config.senpro;
  pingCfg = cfg.monitoring.telegraf.inputs.ping;

in {
  options.senpro.monitoring.telegraf.inputs.ping = {
    enable = mkEnableOption ''
      Whether to enable Ping.
    '';
    #urls = [ "example.org" ];
    urls = mkOption {
      type = types.listOf types.str;
      default = [];
      example = literalExpression ''
        [ "192.168.0.1" ]
      '';
      description = ''
        Hosts to be pinged
      '';
    };
    # count = 1 types.str (ping -n)
    # ping_interval = 1.0 types.str (sec)
    # timeout = 1.0 (sec)
    # deadline = 10 (sec)
    # interface = "" types.str
    # percentiles = [50, 95, 99] list (if method == "native")
    # ipv6 = false types.bool
    # size = 56 (ICMP size)
  };

  config = {
    services.telegraf.extraConfig.inputs.ping = lib.mkIf pingCfg.enable [{
      name_override = "ping";
      urls = pingCfg.urls;
      method = "native";
    }];
  };
}
