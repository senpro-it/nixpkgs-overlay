{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* SonicWall TZ/NSa config subtree. */
  deviceCfg = snmpCfg.vendors.sonicWall.fwTzNsa;

  /* Build the Telegraf SNMP input for the firewall itself.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkFirewallInput = agent: {
    name = "sonicWall.fwTzNsa";
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
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "firmwareVersion"; oid = "SNWL-COMMON-MIB::snwlSysFirmwareVersion.0"; }
      { name = "model"; oid = "SNWL-COMMON-MIB::snwlSysModel.0"; }
      { name = "romVersion"; oid = "SNWL-COMMON-MIB::snwlSysROMVersion.0"; }
      { name = "serialNumber"; oid = "SNWL-COMMON-MIB::snwlSysSerialNumber.0"; }
      { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
      { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
      { name = "cpuUsage"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentCPUUtil.0"; }
      { name = "cpuUsageMgmt"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentManagementCPUUtil.0"; }
      { name = "cpuUsageInspect"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentFwdAndInspectCPUUtil.0"; }
      { name = "memUsage"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentRAMUtil.0"; }
      { name = "contentFilter"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCFS.0"; }
      { name = "currentConnections"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentConnCacheEntries.0"; }
    ];
    table = [
      { name = "sonicWall.fwTzNsa.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifDescr"; is_tag = true; }
      ]; }
      { name = "sonicWall.fwTzNsa.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifName"; is_tag = true; }
      ]; }
      { name = "sonicWall.fwTzNsa.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
        { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
      ]; }
      { name = "sonicWall.fwTzNsa.vpnIpsecStats"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicSAStatTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
      { name = "sonicWall.fwTzNsa.zoneStats"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicwallFwZoneTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
    ];
  };

  /* Build the Telegraf SNMP input for access points.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkAccessPointInput = agent: {
    name = "sonicWall.fwTzNsa.accessPoints";
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
      { name = "apHost"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "apNumber"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessApNumber.0"; }
    ];
    table = [
      { name = "sonicWall.fwTzNsa.accessPoints.apTable"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessApTable"; index_as_tag = true; inherit_tags = [ "apHost" ]; field = [
        { oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicApName"; is_tag = true; }
      ]; }
      { name = "sonicWall.fwTzNsa.accessPoints.vapTable"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessVapTable"; index_as_tag = true; inherit_tags = [ "apHost" ]; field = [
        { oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessVapSsid"; is_tag = true; }
      ]; }
      { name = "sonicWall.fwTzNsa.accessPoints.statTable"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessStaTable"; index_as_tag = true; inherit_tags = [ "apHost" ]; field = [
        { oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicStaIpAddress"; is_tag = true; }
      ]; }
    ];
  };

  /* Assemble SNMP inputs based on enabled endpoints. */
  snmpInputs = telegrafOptions.mkSnmpInputs deviceCfg.endpoints.self mkFirewallInput
    ++ telegrafOptions.mkSnmpInputs deviceCfg.endpoints.accessPoints mkAccessPointInput;

in {
  /* SonicWall TZ/NSa SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa = lib.recursiveUpdate
    (telegrafOptions.mkSnmpV3Options ''
      Whether to enable the SonicWall TZ & NSa monitoring via SNMP.
    '')
    {
      endpoints.accessPoints = {
        enable = mkEnableOption ''
          Whether to enable the SonicWall AP monitoring (through Firewall) via SNMP.
        '';
        agents = telegrafOptions.agentConfig;
      };
    };

  config = {
    senpro.monitoring.telegraf.rawInputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
