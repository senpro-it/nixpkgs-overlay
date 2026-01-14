{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* Dell storage config subtree. */
  deviceCfg = snmpCfg.vendors.dell.storage;

  /* Build the Telegraf SNMP input for one storage agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: {
    name = "dell.storage";
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
    ];
    table = [
      { name = "dell.storage.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifDescr"; is_tag = true; }
      ]; }
      { name = "dell.storage.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifName"; is_tag = true; }
      ]; }
      { name = "dell.storage.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
        { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
      ]; }
      { name = "dell.storage.connUnitTable"; oid = "FCMGMT-MIB::connUnitTable"; inherit_tags = [ "host" ]; field = [
        { oid = "FCMGMT-MIB::connUnitName"; is_tag = true; }
      ]; }
      { name = "dell.storage.connUnitSensorTable"; oid = "FCMGMT-MIB::connUnitSensorTable"; inherit_tags = [ "host" ]; field = [
        { oid = "FCMGMT-MIB::connUnitSensorName"; is_tag = true; }
      ]; }
      { name = "dell.storage.connUnitPortTable"; oid = "FCMGMT-MIB::connUnitPortTable"; inherit_tags = [ "host" ]; field = [
        { oid = "FCMGMT-MIB::connUnitPortName"; is_tag = true; }
      ]; }
    ];
  };

  /* Assemble all configured SNMP inputs for Dell storage. */
  snmpInputs = telegrafOptions.mkSnmpInputs deviceCfg.endpoints.self mkSnmpInput;

in {
  /* Dell storage SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.dell.storage =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Dell storage monitoring via SNMP.
    '';

  config = {
    senpro.monitoring.telegraf.rawInputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
