{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* Aruba switch config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.aruba.switch;
  /* Build the Telegraf SNMP input for one switch agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSwitchInput = agent: telegrafOptions.sanitizeToml {
    name = "aruba.switch";
    path = [ "${pkgs.mib-library}/opt/mib-library/" ];
    agents = [ agent ];
    timeout = "20s";
    version = 2;
    community = "${deviceCfg.credentials.community}";
    retries = 5;
    field = [
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
      { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
      { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
      { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
    ];
    table = [
      { name = "aruba.switch.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifDescr"; is_tag = true; }
      ]; }
      { name = "aruba.switch.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifName"; is_tag = true; }
      ]; }
    ];
  };
  /* Assemble all configured SNMP inputs for Aruba switches. */
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSwitchInput deviceCfg.endpoints.self.agents);

in {
  /* Aruba switch SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.aruba.switch =
    telegrafOptions.mkSnmpV2Options ''
      Whether to enable the Aruba switch monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
