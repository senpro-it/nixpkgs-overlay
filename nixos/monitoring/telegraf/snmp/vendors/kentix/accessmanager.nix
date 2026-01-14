{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Kentix AccessManager monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: telegrafOptions.sanitizeToml {
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
      }) deviceCfg.endpoints.self.agents
    );
  };
}
