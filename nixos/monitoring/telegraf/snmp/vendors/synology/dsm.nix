{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.synology.dsm =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Synology DSM monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: telegrafOptions.sanitizeToml {
        name = "synology.dsm";
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
          { name = "model"; oid = "SYNOLOGY-SYSTEM-MIB::modelName.0"; }
          { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
          { name = "serialNumber"; oid = "SYNOLOGY-SYSTEM-MIB::serialNumber.0"; }
          { name = "firmwareVersion"; oid = "SYNOLOGY-SYSTEM-MIB::version.0"; }
          { name = "firmwareUpgradeAvailable"; oid = "SYNOLOGY-SYSTEM-MIB::upgradeAvailable.0"; }
          { name = "cpuFanStatus"; oid = "SYNOLOGY-SYSTEM-MIB::cpuFanStatus.0"; }
          { name = "cpuIdle"; oid = "UCD-SNMP-MIB::ssCpuIdle.0"; }
          { name = "powerStatus"; oid = "SYNOLOGY-SYSTEM-MIB::powerStatus.0"; }
          { name = "systemStatus"; oid = "SYNOLOGY-SYSTEM-MIB::systemStatus.0"; }
          { name = "systemFanStatus"; oid = "SYNOLOGY-SYSTEM-MIB::systemFanStatus.0"; }
          { name = "temperature"; oid = "SYNOLOGY-SYSTEM-MIB::temperature.0"; }
          { name = "memAvailReal"; oid = "UCD-SNMP-MIB::memAvailReal.0"; }
          { name = "memTotalReal"; oid = "UCD-SNMP-MIB::memTotalReal.0"; }
          { name = "memTotalFree"; oid = "UCD-SNMP-MIB::memTotalFree.0"; }
          { name = "memBuffer"; oid = "UCD-SNMP-MIB::memBuffer.0"; }
          { name = "memCached"; oid = "UCD-SNMP-MIB::memCached.0"; }
          { name = "memAvailSwap"; oid = "UCD-SNMP-MIB::memAvailSwap.0"; }
          { name = "memTotalSwap"; oid = "UCD-SNMP-MIB::memTotalSwap.0"; }
          { name = "highAvailActiveNode"; oid = "SYNOLOGY-SHA-MIB::activeNodeName.0"; }
          { name = "highAvailPassiveNode"; oid = "SYNOLOGY-SHA-MIB::passiveNodeName.0"; }
          { name = "highAvailClusterName"; oid = "SYNOLOGY-SHA-MIB::clusterName.0"; }
          { name = "highAvailClusterStatus"; oid = "SYNOLOGY-SHA-MIB::clusterStatus.0"; }
          { name = "highAvailClusterAutoFailover"; oid = "SYNOLOGY-SHA-MIB::clusterAutoFailover.0"; }
          { name = "highAvailHeartbeatStatus"; oid = "SYNOLOGY-SHA-MIB::heartbeatStatus.0"; }
          { name = "highAvailHeartbeatTxRate"; oid = "SYNOLOGY-SHA-MIB::heartbeatTxRate.0"; }
          { name = "highAvailHeartbeatLatency"; oid = "SYNOLOGY-SHA-MIB::heartbeatLatency.0"; }
        ];
        table = [
          { name = "synology.dsm.diskTable"; oid = "SYNOLOGY-DISK-MIB::diskTable"; inherit_tags = [ "host" ]; }
          { name = "synology.dsm.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "synology.dsm.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
          { name = "synology.dsm.raidTable"; oid = "SYNOLOGY-RAID-MIB::raidTable"; inherit_tags = [ "host" ]; field = [
            { oid = "SYNOLOGY-RAID-MIB::raidName"; is_tag = true; }
          ]; }
          { name = "synology.dsm.serviceTable"; oid = "SYNOLOGY-SERVICES-MIB::serviceTable"; inherit_tags = [ "host" ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
