{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* Sophos SG config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.sophos.sg;

  /* Build the Telegraf SNMP input for one Sophos SG agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
    name = "sophos.sg";
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
      { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
      { name = "memAvailReal"; oid = "UCD-SNMP-MIB::memAvailReal.0"; }
      { name = "memTotalReal"; oid = "UCD-SNMP-MIB::memTotalReal.0"; }
      { name = "memTotalFree"; oid = "UCD-SNMP-MIB::memTotalFree.0"; }
      { name = "memBuffer"; oid = "UCD-SNMP-MIB::memBuffer.0"; }
      { name = "memCached"; oid = "UCD-SNMP-MIB::memCached.0"; }
      { name = "memAvailSwap"; oid = "UCD-SNMP-MIB::memAvailSwap.0"; }
      { name = "memTotalSwap"; oid = "UCD-SNMP-MIB::memTotalSwap.0"; }
    ];
    table = [
      { name = "sophos.sg.dskTable"; oid = "UCD-SNMP-MIB::dskTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "UCD-SNMP-MIB::dskDevice"; is_tag = true; }
      ]; }
      { name = "sophos.sg.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifDescr"; is_tag = true; }
      ]; }
      { name = "sophos.sg.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifName"; is_tag = true; }
      ]; }
      { name = "sophos.sg.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
    ];
  };

  /* Assemble all configured SNMP inputs for Sophos SG devices. */
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  /* Sophos SG SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.sophos.sg =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Sophos SG monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
