{ lib, ... }:

with lib;

{
  /* Enable/disable Telegraf API-based input modules. */
  options.senpro.monitoring.telegraf.inputs.api = {
    enable = mkEnableOption ''
      Whether to enable API monitoring.
    '';
  };

  /* Vendor-specific API modules. */
  imports = [
    ./api/vendors/sophos/central.nix
    ./api/vendors/vmware/vsphere.nix
  ];
}
