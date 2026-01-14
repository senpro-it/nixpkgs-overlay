{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway = lib.recursiveUpdate
    (telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Aruba Mobility Gateway monitoring via SNMP.
    '')
    {
      endpoints.accessPoints = {
        enable = mkEnableOption ''
          Whether to enable the Aruba AP monitoring (through Mobility Gateway) via SNMP.
        '';
        agents = telegrafOptions.agentConfig;
      };
    };

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable (
      lib.optionals deviceCfg.endpoints.self.enable (map (agent: telegrafOptions.sanitizeToml {
        name = "aruba.mobilityGateway";
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
          { name = "model"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtModelName.0"; }
          { name = "serialNumber"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtSerialNumber.0"; }
          { name = "cpuUsage"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtCpuUsedPercent.0"; }
          { name = "cpuModel"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtProcessorModel.0"; }
          { name = "memUsage"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryUsedPercent.0"; }
          { name = "firmwareVersion"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtSwVersion.0"; }
          { name = "hardwareVersion"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtHwVersion.0"; }
        ];
        table = [
          { name = "aruba.mobilityGateway.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifDescr"; is_tag = true; }
          ]; }
          { name = "aruba.mobilityGateway.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
            { oid = "IF-MIB::ifName"; is_tag = true; }
          ]; }
          { name = "aruba.mobilityGateway.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
        ];
      }) deviceCfg.endpoints.self.agents)
      ++ lib.optionals deviceCfg.endpoints.accessPoints.enable (map (agent: telegrafOptions.sanitizeToml {
        name = "aruba.mobilityGateway.accessPoints";
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
        table = [
          { name = "aruba.mobilityGateway.accessPoints.apTable"; oid = "WLSX-WLAN-MIB::wlsxWlanAPTable"; index_as_tag = true; field = [
            { oid = "WLSX-WLAN-MIB::wlanAPName"; is_tag = true; }
          ]; }
          { name = "aruba.mobilityGateway.accessPoints.essidTable"; oid = "WLSX-WLAN-MIB::wlsxWlanESSIDTable"; index_as_tag = true; }
          { name = "aruba.mobilityGateway.accessPoints.radioTable"; oid = "WLSX-WLAN-MIB::wlsxWlanRadioTable"; index_as_tag = true; }
          { name = "aruba.mobilityGateway.accessPoints.stationTable"; oid = "WLSX-WLAN-MIB::wlsxWlanStationTable"; index_as_tag = true; }
          { name = "aruba.mobilityGateway.accessPoints.apStatsTable"; oid = "WLSX-WLAN-MIB::wlsxWlanAPStatsTable"; index_as_tag = true; }
          { name = "aruba.mobilityGateway.accessPoints.essidStatsTable"; oid = "WLSX-WLAN-MIB::wlsxWlanAPESSIDStatsTable"; index_as_tag = true; }
          { name = "aruba.mobilityGateway.accessPoints.radioStatsTable"; oid = "WLSX-WLAN-MIB::wlsxWlanAPRadioStatsTable"; index_as_tag = true; }
          { name = "aruba.mobilityGateway.accessPoints.stationStatsTable"; oid = "WLSX-WLAN-MIB::wlsxWlanStationStatsTable"; index_as_tag = true; }
        ];
      }) deviceCfg.endpoints.accessPoints.agents)
    );
  };
}
