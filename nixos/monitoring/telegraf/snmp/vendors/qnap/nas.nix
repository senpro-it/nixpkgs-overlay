{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* QNAP NAS config subtree. */
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.qnap.nas;

  /* Build the Telegraf SNMP input for one NAS agent.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
    name = "qnap.nas";
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
      { name = "cpuUsed"; oid = "QTS-MIB::systemCPU-Usage.0"; }
      { name = "cpuTemperature"; oid = "QTS-MIB::cpuTemperature.0"; }
      { name = "diskCount"; oid = "QTS-MIB::diskCount.0"; }
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
      { name = "memFree"; oid = "QTS-MIB::systemFreeMem.0"; }
      { name = "memUsed"; oid = "QTS-MIB::systemUsedMemory.0"; }
      { name = "memTotal"; oid = "QTS-MIB::systemTotalMem.0"; }
      { name = "raidCount"; oid = "QTS-MIB::raidCount.0"; }
      { name = "systemModel"; oid = "QTS-MIB::systemModel.0"; }
      { name = "systemTemperature"; oid = "QTS-MIB::systemTemperature.0"; }
      { name = "systemPower"; oid = "QTS-MIB::sysPowerStatus.0"; }
      { name = "systemUptime"; oid = "QTS-MIB::sysUptime.0"; }
      { name = "serialNumber"; oid = "QTS-MIB::serialNumber.0"; }
      { name = "firmwareVersion"; oid = "QTS-MIB::firmwareVersion.0"; }
      { name = "firmwareUpdateAvailable"; oid = "QTS-MIB::firmwareUpgradeAvailable.0"; }
    ];
    table = [
      { name = "qnap.nas.diskTable"; oid = "QTS-MIB::diskTable"; inherit_tags = [ "host" ]; }
      { name = "qnap.nas.interfaces"; oid = "NAS-MIB::systemIfTable"; inherit_tags = [ "host" ]; }
      { name = "qnap.nas.lun"; oid = "QTS-MIB::lunTable"; inherit_tags = [ "host" ]; }
      { name = "qnap.nas.raid"; oid = "QTS-MIB::raidTable"; inherit_tags = [ "host" ]; }
      { name = "qnap.nas.systemFan"; oid = "QTS-MIB::systemFanTable"; inherit_tags = [ "host" ]; }
      { name = "qnap.nas.target"; oid = "QTS-MIB::targeTable"; inherit_tags = [ "host" ]; }
      { name = "qnap.nas.volume"; oid = "QTS-MIB::volumeTable"; inherit_tags = [ "host" ]; }
    ];
  };

  /* Assemble all configured SNMP inputs for QNAP NAS devices. */
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  /* QNAP NAS SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.qnap.nas =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the QNAP NAS monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
