{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Fortinet firewall monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: {
        name = "fortinet.firewall";
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
          { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
          { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
          { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
          { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
          { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
          { name = "serialNumber"; oid = "FORTINET-CORE-MIB::fnSysSerial.0"; }
          { name = "cpuUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0"; }
          { name = "memUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysMemUsage.0"; }
          { name = "lowMemUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0"; }
          { name = "lowMemCapacity"; oid = "FORTINET-FORTIGATE-MIB::fgSysLowMemCapacity.0"; }
          { name = "memCapacity"; oid = "FORTINET-FORTIGATE-MIB::fgSysMemCapacity.0"; }
          { name = "diskUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysDiskUsage.0"; }
          { name = "diskCapacity"; oid = "FORTINET-FORTIGATE-MIB::fgSysDiskCapacity.0"; }
          { name = "avVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionAv.0"; }
          { name = "ipsVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionIps.0"; }
          { name = "avEtVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionAvEt.0"; }
          { name = "ipsEtVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionIpsEt.0"; }
          { name = "userNumber"; oid = "FORTINET-FORTIGATE-MIB::fgFwUserNumber.0"; }
          { name = "haSystemMode"; oid = "FORTINET-FORTIGATE-MIB::fgHaSystemMode.0"; }
          { name = "haGroupId"; oid = "FORTINET-FORTIGATE-MIB::fgHaGroupId.0"; }
          { name = "haPriority"; oid = "FORTINET-FORTIGATE-MIB::fgHaPriority.0"; }
          { name = "haOverride"; oid = "FORTINET-FORTIGATE-MIB::fgHaOverride.0"; }
          { name = "haAutoSync"; oid = "FORTINET-FORTIGATE-MIB::fgHaAutoSync.0"; }
          { name = "haSchedule"; oid = "FORTINET-FORTIGATE-MIB::fgHaSchedule.0"; }
          { name = "haGroupName"; oid = "FORTINET-FORTIGATE-MIB::fgHaGroupName.0"; }
          { name = "configSerial"; oid = "FORTINET-FORTIGATE-MIB::fgConfigSerial.0"; }
          { name = "configChecksum"; oid = "FORTINET-FORTIGATE-MIB::fgConfigChecksum.0"; }
          { name = "configLastChange"; oid = "FORTINET-FORTIGATE-MIB::fgConfigLastChangeTime.0"; }
        ];
        table = [
          { name = "fortinet.firewall.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "fortinet.firewall.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
          { name = "fortinet.firewall.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
            { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
          ]; }
          { name = "fortinet.firewall.hwSensorTable"; oid = "FORTINET-FORTIGATE-MIB::fgHwSensorTable"; inherit_tags = [ "host" ]; field = [
            { oid = "FORTINET-FORTIGATE-MIB::fgHwSensorEntName"; is_tag = true; }
          ]; }
          { name = "fortinet.firewall.licContractTable"; oid = "FORTINET-FORTIGATE-MIB::fgLicContractTable"; inherit_tags = [ "host" ]; field = [
            { oid = "FORTINET-FORTIGATE-MIB::fgLicContractDesc"; is_tag = true; }
          ]; }
          { name = "fortinet.firewall.avStatsTable"; oid = "FORTINET-FORTIGATE-MIB::fgAvStatsTable"; inherit_tags = [ "host" ]; }
          { name = "fortinet.firewall.IpsStatsTable"; oid = "FORTINET-FORTIGATE-MIB::fgIpsStatsTable"; inherit_tags = [ "host" ]; }
          { name = "fortinet.firewall.haStatsTable"; oid = "FORTINET-FORTIGATE-MIB::fgHaStatsTable"; inherit_tags = [ "host" ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
