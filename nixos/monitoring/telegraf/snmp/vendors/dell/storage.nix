{ config, lib, pkgs, ... }:

with lib;

let
  /* Shared Telegraf option helpers. */
  telegrafOptions = import ../../../options.nix { inherit lib; };
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* Dell storage config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.dell.storage;

  /* Build the Telegraf SNMP input for one storage agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
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
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  /* Dell storage SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.dell.storage =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Dell storage monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
