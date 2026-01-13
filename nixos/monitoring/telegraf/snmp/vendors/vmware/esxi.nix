{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi = {
    endpoints = {
      self = {
        enable = mkEnableOption ''
          Whether to enable the VMware ESXi monitoring via SNMP.
        '';
        agents = telegrafOptions.agentConfig;
      };
    };
    credentials = telegrafOptions.authSNMPv3;
  };

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: {
        name = "vmware.esxi";
        path = [ "${pkgs.mib-library}/opt/mib-library/" ];
        agents = [ agent ];
        timeout = "20s";
        version = 3;
        sec_level = "${deviceCfg.credentials.security.level}";
        sec_name = "${deviceCfg.credentials.security.username}";
        auth_protocol = "${deviceCfg.credentials.authentication.protocol}";
        auth_password = "${deviceCfg.credentials.authentication.password}";
        priv_protocol = "${deviceCfg.credentials.privacy.protocol}";
        priv_password = "${deviceCfg.credentials.privacy.password}";
        retries = 5;
        field = [
          { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
          { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
          { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
          { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
          { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
          { name = "model"; oid = "VMWARE-SYSTEM-MIB::vmwProdName.0"; }
          { name = "firmwareVersion"; oid = "VMWARE-SYSTEM-MIB::vmwProdVersion.0"; }
          { name = "firmwareBuild"; oid = "VMWARE-SYSTEM-MIB::vmwProdBuild.0"; }
          { name = "firmwareUpdateLevel"; oid = "VMWARE-SYSTEM-MIB::vmwProdUpdate.0"; }
          { name = "firmwarePatchLevel"; oid = "VMWARE-SYSTEM-MIB::vmwProdPatch.0"; }
          { name = "memorySize"; oid = "HOST-RESOURCES-MIB::hrMemorySize.0"; }
        ];
        table = [
          { name = "vmware.esxi.vmTable"; oid = "VMWARE-VMINFO-MIB::vmwVmTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "VMWARE-VMINFO-MIB::vmwVmDisplayName"; is_tag = true; }
          ]; }
          { name = "vmware.esxi.storageTable"; oid = "HOST-RESOURCES-MIB::hrStorageTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "HOST-RESOURCES-MIB::hrStorageDescr"; is_tag = true; }
          ]; }
          { name = "vmware.esxi.deviceTable"; oid = "HOST-RESOURCES-MIB::hrDeviceTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
          { name = "vmware.esxi.processorTable"; oid = "HOST-RESOURCES-MIB::hrProcessorTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
          { name = "vmware.esxi.diskStorageTable"; oid = "HOST-RESOURCES-MIB::hrDiskStorageTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
          { name = "vmware.esxi.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "vmware.esxi.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
