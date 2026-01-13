{ lib, ... }:

with lib;

{
  options.senpro.monitoring.telegraf.inputs.snmp = {
    enable = mkEnableOption ''
      Whether to enable SNMP monitoring.
    '';
  };

  imports = [
    ./vendors/aruba/mobility-gateway.nix
    ./vendors/aruba/switch.nix
    ./vendors/cisco/switch.nix
    ./vendors/dell/storage.nix
    ./vendors/fortinet/firewall.nix
    ./vendors/fs/switch.nix
    ./vendors/kentix/accessmanager.nix
    ./vendors/kentix/sensors.nix
    ./vendors/lancom/router.nix
    ./vendors/lenovo/storage.nix
    ./vendors/qnap/nas.nix
    ./vendors/reddoxx/appliance.nix
    ./vendors/schneider-electric/apc.nix
    ./vendors/sonicwall/fw-tznsa.nix
    ./vendors/sophos/sg.nix
    ./vendors/sophos/xg.nix
    ./vendors/synology/dsm.nix
    ./vendors/vmware/esxi.nix
    ./vendors/zyxel/switch.nix
  ];
}
