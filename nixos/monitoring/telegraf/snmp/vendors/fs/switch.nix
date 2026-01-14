{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.fs.switch =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the FS switch monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: telegrafOptions.sanitizeToml {
        name = "fs.switch";
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
          { name = "model"; oid = "NMS-CHASSIS::nmscardDescr.0"; }
          { name = "serialNumber"; oid = "NMS-CHASSIS::nmscardSerial.0"; }
          { name = "fwVersion"; oid = "NMS-CHASSIS::nmscardSwVersion.0"; }
        ];
        table = [
          { name = "fs.switch.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "fs.switch.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
          { name = "fs.switch.ifExtStatisticsTable"; oid = "NMS-INTERFACE-EXT::ifExtStatisticsTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "NMS-INTERFACE-EXT::ifExtDesc"; is_tag = true; }
          ]; }
          { name = "fs.switch.ipAddrTable"; oid = "NMS-IP-ADDRESS-MIB::ipAddrTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "NMS-IP-ADDRESS-MIB::nmsIpEntAddr"; is_tag = true; }
          ]; }
          { name = "fs.switch.nmspmCPUTotalTable"; oid = "NMS-PROCESS-MIB::nmspmCPUTotalTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
