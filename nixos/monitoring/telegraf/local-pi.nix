{ config, lib, mkInputConfig, telegrafOptions, ... }:

with lib;

let
  /* Local Pi input configuration subtree. */
  localPiCfg = config.senpro.monitoring.telegraf.inputs.local_pi;
  /* Default CPU input configuration for the local host. */
  cpuDefaults = {
    name_override = "${localPiCfg.name_override}.cpu";
    percpu = true;
    totalcpu = true;
    collect_cpu_time = false;
    report_active = false;
    core_tags = true;
  };
  /* Default disk input configuration for the local host. */
  diskDefaults = {
    name_override = "${localPiCfg.name_override}.disk";
    mount_points = [ "/" ];
  };
  /* Default memory input configuration for the local host. */
  memDefaults = {
    name_override = "${localPiCfg.name_override}.mem";
  };
  /* Default kernel input configuration for the local host. */
  kernelDefaults = {
    name_override = "${localPiCfg.name_override}.kernel";
    collect = [ "*" ];
  };
  /* Default processes input configuration for the local host. */
  processesDefaults = {
    name_override = "${localPiCfg.name_override}.proc";
  };
  /* Default system input configuration for the local host. */
  systemDefaults = {
    name_override = "${localPiCfg.name_override}.sys";
  };

in {
  /* Local Pi input options. */
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
        settings = telegrafOptions.mkInputSettingsOption telegrafOptions.cpuInput
          "Options for the CPU input.";
      };
      disk = {
        enable = mkEnableOption ''
          Monitor the Pi's internal storage?
        '';
        settings = telegrafOptions.mkInputSettingsOption telegrafOptions.diskInput
          "Options for the disk input.";
      };
      mem = {
        enable = mkEnableOption ''
          Monitor the Pi's RAM and SWAP?
        '';
        settings = telegrafOptions.mkInputSettingsOption telegrafOptions.memInput
          "Options for the memory input.";
      };
      kernel = {
        enable = mkEnableOption ''
          Monitor the Pi's Linux Kernel information?
        '';
        settings = telegrafOptions.mkInputSettingsOption telegrafOptions.kernelInput
          "Options for the kernel input.";
      };
      processes = {
        enable = mkEnableOption ''
          Monitor the Pi's running processes?
        '';
        settings = telegrafOptions.mkInputSettingsOption telegrafOptions.processesInput
          "Options for the processes input.";
      };
      system = {
        enable = mkEnableOption ''
          Monitor the Pi's system information?
        '';
        settings = telegrafOptions.mkInputSettingsOption telegrafOptions.systemInput
          "Options for the system input.";
      };
    };
  };

  config = {
    services.telegraf.extraConfig.inputs.cpu = lib.mkIf localPiCfg.stats.cpu.enable [
      (mkInputConfig (cpuDefaults // localPiCfg.stats.cpu.settings))
    ];
    services.telegraf.extraConfig.inputs.disk = lib.mkIf localPiCfg.stats.disk.enable [
      (mkInputConfig (diskDefaults // localPiCfg.stats.disk.settings))
    ];
    services.telegraf.extraConfig.inputs.mem = lib.mkIf localPiCfg.stats.mem.enable [
      (mkInputConfig (memDefaults // localPiCfg.stats.mem.settings))
    ];
    services.telegraf.extraConfig.inputs.kernel = lib.mkIf localPiCfg.stats.kernel.enable [
      (mkInputConfig (kernelDefaults // localPiCfg.stats.kernel.settings))
    ];
    services.telegraf.extraConfig.inputs.processes = lib.mkIf localPiCfg.stats.processes.enable [
      (mkInputConfig (processesDefaults // localPiCfg.stats.processes.settings))
    ];
    services.telegraf.extraConfig.inputs.system = lib.mkIf localPiCfg.stats.system.enable [
      (mkInputConfig (systemDefaults // localPiCfg.stats.system.settings))
    ];
  };
}
