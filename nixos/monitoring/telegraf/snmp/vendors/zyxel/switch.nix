{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch = {
    endpoints = {
      self = {
        enable = mkEnableOption ''
          Whether to enable the Zyxel switch monitoring via SNMP.
        '';
        agents = telegrafOptions.agentConfig;
      };
    };
    credentials = telegrafOptions.authSNMPv3;
  };

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: {
        name = "zyxel.switch";
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
          # Defaults
          { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
          { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
          { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
          { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
          { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
          # Generated:
          { name = "sysSwPlatform"; oid = "ZYXEL-ES-COMMON-INFO::sysSwPlatform.0"; }
          { name = "sysSwMajorVersion"; oid = "ZYXEL-ES-COMMON-INFO::sysSwMajorVersion.0"; }
          { name = "sysSwMinorVersion"; oid = "ZYXEL-ES-COMMON-INFO::sysSwMinorVersion.0"; }
          { name = "sysSwModel"; oid = "ZYXEL-ES-COMMON-INFO::sysSwModel.0"; }
          { name = "sysSwPatchNumber"; oid = "ZYXEL-ES-COMMON-INFO::sysSwPatchNumber.0"; }
          { name = "sysSwVersionString"; oid = "ZYXEL-ES-COMMON-INFO::sysSwVersionString.0"; }
          { name = "sysSwDay"; oid = "ZYXEL-ES-COMMON-INFO::sysSwDay.0"; }
          { name = "sysSwMonth"; oid = "ZYXEL-ES-COMMON-INFO::sysSwMonth.0"; }
          { name = "sysSwYear"; oid = "ZYXEL-ES-COMMON-INFO::sysSwYear.0"; }
          { name = "sysProductFamily"; oid = "ZYXEL-ES-COMMON-INFO::sysProductFamily.0"; }
          { name = "sysProductModel"; oid = "ZYXEL-ES-COMMON-INFO::sysProductModel.0"; }
          { name = "sysProductSerialNumber"; oid = "ZYXEL-ES-COMMON-INFO::sysProductSerialNumber.0"; }
          { name = "sysNebulaManaged"; oid = "ZYXEL-ES-COMMON-INFO::sysNebulaManaged.0"; }
          { name = "sysMgmtCPUUsage"; oid = "ZYXEL-ES-COMMON-MGMT::sysMgmtCPUUsage.0"; }
          { name = "sysMgmtMemUsage"; oid = "ZYXEL-ES-COMMON-MGMT::sysMgmtMemUsage.0"; }
          { name = "sysMgmtFlashUsage"; oid = "ZYXEL-ES-COMMON-MGMT::sysMgmtFlashUsage.0"; }
          { name = "sysMgmtCPU1MinUsage"; oid = "ZYXEL-ES-COMMON-MGMT::sysMgmtCPU1MinUsage.0"; }
        ];
        table = [
          { name = "zyxel.switch.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "zyxel.switch.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
          { name = "zyxel.switch.ifExtStatisticsTable"; oid = "NMS-INTERFACE-EXT::ifExtStatisticsTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "NMS-INTERFACE-EXT::ifExtDesc"; is_tag = true; }
          ]; }
          { name = "zyxel.switch.portTable"; oid = "ZYXEL-PORT-MIB::zyxelPortTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
          { name = "zyxel.switch.portInfoTable"; oid = "ZYXEL-PORT-MIB::zyxelPortInfoTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
          { name = "zyxel.switch.hwMonitorFan"; oid = "ZYXEL-HW-MONITOR-MIB::zyxelHwMonitorFanRpmTable"; inherit_tags = [ "host" ]; field = [
            { oid = "ZYXEL-HW-MONITOR-MIB::zyHwMonitorFanRpmDescription"; is_tag = true; }
          ]; }
          { name = "zyxel.switch.hwMonitorTemp"; oid = "ZYXEL-HW-MONITOR-MIB::zyxelHwMonitorTemperatureTable"; inherit_tags = [ "host" ]; field = [
            { oid = "ZYXEL-HW-MONITOR-MIB::zyHwMonitorTemperatureDescription"; is_tag = true; }
          ]; }
          { name = "zyxel.switch.hwMonitorVolt"; oid = "ZYXEL-HW-MONITOR-MIB::zyxelHwMonitorVoltageTable"; inherit_tags = [ "host" ]; field = [
            { oid = "ZYXEL-HW-MONITOR-MIB::zyHwMonitorVoltageDescription"; is_tag = true; }
          ]; }
          { name = "zyxel.switch.hwMonitorPower"; oid = "ZYXEL-HW-MONITOR-MIB::zyxelHwMonitorPowerSourceTable"; inherit_tags = [ "host" ]; field = [
            { oid = "ZYXEL-HW-MONITOR-MIB::zyHwMonitorPowerSourceDescription"; is_tag = true; }
          ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
