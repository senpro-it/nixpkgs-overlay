{ lib, ... }:

with lib;

{
  options.senpro.monitoring.telegraf.inputs.api = {
    enable = mkEnableOption ''
      Whether to enable API monitoring.
    '';
  };

  imports = [
    ./api/vendors/sophos/central.nix
    ./api/vendors/vmware/vsphere.nix
  ];
}
