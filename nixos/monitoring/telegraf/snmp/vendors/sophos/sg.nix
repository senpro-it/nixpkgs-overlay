{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.sophos.sg = {
    endpoints = {
      self = {
        enable = mkEnableOption ''
          Whether to enable the Sophos SG monitoring via SNMP.
        '';
        agents = telegrafOptions.agentConfig;
      };
    };
    credentials = telegrafOptions.authSNMPv3;
  };

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: {
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
      }) deviceCfg.endpoints.self.agents
    );
  };
}
