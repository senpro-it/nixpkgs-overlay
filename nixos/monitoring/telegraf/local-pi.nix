{ config, lib, ... }:

with lib;

let
  /* Shared Telegraf option helpers. */
  telegrafOptions = import ./options.nix { inherit lib; };
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
  /* Merge defaults with per-input overrides. */
  cpuSettings = cpuDefaults // localPiCfg.stats.cpu.settings;
  diskSettings = diskDefaults // localPiCfg.stats.disk.settings;
  memSettings = memDefaults // localPiCfg.stats.mem.settings;
  kernelSettings = kernelDefaults // localPiCfg.stats.kernel.settings;
  processesSettings = processesDefaults // localPiCfg.stats.processes.settings;
  systemSettings = systemDefaults // localPiCfg.stats.system.settings;
  /* Strip null values before serializing. */
  cpuConfig = lib.filterAttrs (_: v: v != null) cpuSettings;
  diskConfig = lib.filterAttrs (_: v: v != null) diskSettings;
  memConfig = lib.filterAttrs (_: v: v != null) memSettings;
  kernelConfig = lib.filterAttrs (_: v: v != null) kernelSettings;
  processesConfig = lib.filterAttrs (_: v: v != null) processesSettings;
  systemConfig = lib.filterAttrs (_: v: v != null) systemSettings;
  /* Sanitized Telegraf configs for each input. */
  cpuInputConfig = telegrafOptions.sanitizeToml cpuConfig;
  diskInputConfig = telegrafOptions.sanitizeToml diskConfig;
  memInputConfig = telegrafOptions.sanitizeToml memConfig;
  kernelInputConfig = telegrafOptions.sanitizeToml kernelConfig;
  processesInputConfig = telegrafOptions.sanitizeToml processesConfig;
  systemInputConfig = telegrafOptions.sanitizeToml systemConfig;

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
      cpuInputConfig
    ];
    services.telegraf.extraConfig.inputs.disk = lib.mkIf localPiCfg.stats.disk.enable [
      diskInputConfig
    ];
    services.telegraf.extraConfig.inputs.mem = lib.mkIf localPiCfg.stats.mem.enable [
      memInputConfig
    ];
    services.telegraf.extraConfig.inputs.kernel = lib.mkIf localPiCfg.stats.kernel.enable [
      kernelInputConfig
    ];
    services.telegraf.extraConfig.inputs.processes = lib.mkIf localPiCfg.stats.processes.enable [
      processesInputConfig
    ];
    services.telegraf.extraConfig.inputs.system = lib.mkIf localPiCfg.stats.system.enable [
      systemInputConfig
    ];
  };
}
