{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* LANCOM router config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.lancom.router;

  /* Build the Telegraf SNMP input for one router agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
    name = "lancom.router";
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
      { name = "wanBackupActive"; oid = "LCOS-MIB::lcsStatusWanBackupActive.0"; }
      { name = "hardwareInfoCpuType"; oid = "LCOS-MIB::lcsStatusHardwareInfoCpuType.0"; }
      { name = "hardwareInfoCpuClockMhz"; oid = "LCOS-MIB::lcsStatusHardwareInfoCpuClockMhz.0"; }
      { name = "hardwareInfoCpuLoadPercent"; oid = "LCOS-MIB::lcsStatusHardwareInfoCpuLoadPercent.0"; }
      { name = "hardwareInfoModelNumber"; oid = "LCOS-MIB::lcsStatusHardwareInfoModelNumber.0"; }
      { name = "hardwareInfoTotalMemoryKbytes"; oid = "LCOS-MIB::lcsStatusHardwareInfoTotalMemoryKbytes.0"; }
      { name = "hardwareInfoFreeMemoryKbytes"; oid = "LCOS-MIB::lcsStatusHardwareInfoFreeMemoryKbytes.0"; }
      { name = "hardwareInfoSerialNumber"; oid = "LCOS-MIB::lcsStatusHardwareInfoSerialNumber.0"; }
      { name = "hardwareInfoSwVersion"; oid = "LCOS-MIB::lcsStatusHardwareInfoSwVersion.0"; }
      { name = "hardwareInfoTemperature"; oid = "LCOS-MIB::lcsStatusHardwareInfoTemperatureDegrees.0"; }
      { name = "hardwareInfoProductionDate"; oid = "LCOS-MIB::lcsStatusHardwareInfoProductionDate.0"; }
      { name = "vdslLineState"; oid = "LCOS-MIB::lcsStatusVdslLineState.0"; }
      { name = "vdslLineType"; oid = "LCOS-MIB::lcsStatusVdslLineType.0"; }
      { name = "vdslStandard"; oid = "LCOS-MIB::lcsStatusVdslStandard.0"; }
      { name = "vdslDataRateUpstreamKbps"; oid = "LCOS-MIB::lcsStatusVdslDataRateUpstreamKbps.0"; }
      { name = "vdslDataRateDownstreamKbps"; oid = "LCOS-MIB::lcsStatusVdslDataRateDownstreamKbps.0"; }
      { name = "vdslDslamChipsetManufacturer"; oid = "LCOS-MIB::lcsStatusVdslDslamChipsetManufacturer.0"; }
      { name = "vdslModemType"; oid = "LCOS-MIB::lcsStatusVdslModemType.0"; }
      { name = "vdslAttenuationUpstreamDb"; oid = "LCOS-MIB::lcsStatusVdslAttenuationUpstreamDb.0"; }
      { name = "vdslAttenuationDownstreamDb"; oid = "LCOS-MIB::lcsStatusVdslAttenuationDownstreamDb.0"; }
      { name = "vdslConnectionDuration"; oid = "LCOS-MIB::lcsStatusVdslConnectionDuration.0"; }
    ];
    table = [
      { name = "lancom.router.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifDescr"; is_tag = true; }
      ]; }
      { name = "lancom.router.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifName"; is_tag = true; }
      ]; }
      { name = "lancom.router.wanIpAddressTable"; oid = "LCOS-MIB::lcsStatusWanIpAddressesIpv4Table"; inherit_tags = [ "host" ]; field = [
        { oid = "LCOS-MIB::lcsStatusWanIpAddressesIpv4EntryPeer"; is_tag = true; }
      ]; }
      { name = "lancom.router.wanVlanTable"; oid = "LCOS-MIB::lcsStatusWanIpAddressesIpv4Table"; inherit_tags = [ "host" ]; field = [
        { oid = "LCOS-MIB::lcsStatusWanVlansVlansEntryPeer"; is_tag = true; }
      ]; }
      { name = "lancom.router.lanInterfaceTable"; oid = "LCOS-MIB::lcsStatusLanInterfacesTable"; inherit_tags = [ "host" ]; field = [
        { oid = "LCOS-MIB::lcsStatusLanInterfacesEntryIfc"; is_tag = true; }
      ]; }
    ];
  };

  /* Assemble all configured SNMP inputs for LANCOM routers. */
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  /* LANCOM router SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.lancom.router =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the LANCOM router monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
