{ config, lib, ... }:

with lib;

let
  cfg = config.senpro;
  localPiCfg = cfg.monitoring.telegraf.inputs.local_pi;

in {
  options.senpro.monitoring.telegraf.inputs.local_pi = {
    enable = mkEnableOption ''
        Monitor the local Raspberry Pi monitoring agent as well.
    '';
    name_override = mkOption {
      type = types.str;
      default = "local_pi";
      example = literalExpression ''
        "linux" or "unix"
      '';
      description = mkDoc ''
        Changes the name_override value being used.
        Especially useful to re-use this option set for other Linux
        instances that are not Raspberry Pi Monitoring Agents.
      '';
    };
    stats = {
      cpu = {
        enable = mkEnableOption ''
            Monitor the Pi's CPU?
        '';
      };
      disk = {
        enable = mkEnableOption ''
            Monitor the Pi's internal storage?
        '';
      };
      mem = {
        enable = mkEnableOption ''
            Monitor the Pi's RAM and SWAP?
        '';
      };
      kernel = {
        enable = mkEnableOption ''
            Monitor the Pi's Linux Kernel information?
        '';
      };
      processes = {
        enable = mkEnableOption ''
            Monitor the Pi's running processes?
        '';
      };
      system = {
        enable = mkEnableOption ''
            Monitor the Pi's system information?
        '';
      };
    };
  };

  config = {
    services.telegraf.extraConfig.inputs.cpu = lib.mkIf localPiCfg.stats.cpu.enable [{
      name_override = "${localPiCfg.name_override}.cpu";
      percpu = true;
      totalcpu = true;
      collect_cpu_time = false;
      report_active = false;
      core_tags = true;
    }];
    services.telegraf.extraConfig.inputs.disk = lib.mkIf localPiCfg.stats.disk.enable [{
      name_override = "${localPiCfg.name_override}.disk";
      # NixOS verwendet btrfs; und das spammt die aktiven Mounts leider.
      # Daher wird nur Bezug auf die MicroSD (rootFS bei einem Pi) verwendet.
      # Die Boot Partition (/boot) wird komplett ignoriert - sind ca 200mb weil EFI GPT
      mount_points = [ "/" ];
    }];
    services.telegraf.extraConfig.inputs.mem = lib.mkIf localPiCfg.stats.mem.enable [{
      name_override = "${localPiCfg.name_override}.mem";
      # Keine Konfiguration nötig.
    }];
    services.telegraf.extraConfig.inputs.kernel = lib.mkIf localPiCfg.stats.kernel.enable [{
      name_override = "${localPiCfg.name_override}.kernel";
      collect = [ "*" ];
    }];
    services.telegraf.extraConfig.inputs.processes = lib.mkIf localPiCfg.stats.processes.enable [{
      name_override = "${localPiCfg.name_override}.proc";
      # Keine Konfiguration nötig.
    }];
    services.telegraf.extraConfig.inputs.system = lib.mkIf localPiCfg.stats.system.enable [{
      name_override = "${localPiCfg.name_override}.sys";
      # Keine Konfiguration nötig.
    }];
  };
}
