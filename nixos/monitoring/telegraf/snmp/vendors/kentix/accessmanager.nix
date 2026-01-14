{ config, lib, pkgs, ... }:

with lib;

let
  /* Shared Telegraf option helpers. */
  telegrafOptions = import ../../../options.nix { inherit lib; };
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* Kentix AccessManager config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager;

  /* Build the Telegraf SNMP input for one AccessManager agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
    name = "kentix.accessmanager";
    path = [ "${pkgs.mib-library}/opt/mib-library/" ];
    agents = [ agent ];
    interval = "60s";
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
      { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
      { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
      { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
      { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
    ];
    table = [
      { name = "kentix.accessmanager.generalTable"; oid = "KENTIXDEVICES::generalTable"; inherit_tags = [ "host" ]; field = [
        { oid = "KENTIXDEVICES::sensorName"; is_tag = true; }
      ]; }
      { name = "kentix.accessmanager.batteryTable"; oid = "KENTIXDEVICES::batteryTable"; inherit_tags = [ "host" ]; field = [
        { oid = "KENTIXDEVICES::batteryIndex"; is_tag = true; }
      ]; }
    ];
  };

  /* Assemble all configured SNMP inputs for AccessManager devices. */
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  /* Kentix AccessManager SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Kentix AccessManager monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
