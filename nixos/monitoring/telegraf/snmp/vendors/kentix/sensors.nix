{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  /* Kentix sensor helper functions. */
  kentixFuncs = import ../../kentix.nix;
  /* Global SNMP input toggle. */
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  /* Kentix sensors config subtree. */
  deviceCfg = snmpCfg.vendors.kentix.sensors;

  /* Build the Telegraf SNMP input for Kentix sensors.
     @param agent: SNMP agent address.
     @return Sanitized Telegraf input configuration.
  */
  mkSnmpInput = agent: {
    name = "kentix.sensors";
    path = [ "${pkgs.mib-library}/opt/mib-library/" ];
    agents = [ agent ];
    interval = "60s";
    timeout = "20s";
    version = 2;
    community = "${deviceCfg.credentials.community}";
    field = [
      /* Default SNMP fields. */
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
      { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
      { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }

      /* Kentix-specific fields. */
      { name = "serverstate"; oid = "KAM-PRO::serverstate.0"; }
      { name = "sensorcommunication"; oid = "KAM-PRO::sensorcommunication.0"; }
      { name = "extalarm"; oid = "KAM-PRO::extalarm.0"; }
      { name = "extarmed"; oid = "KAM-PRO::extarmed.0"; }
      { name = "extpower"; oid = "KAM-PRO::extpower.0"; }
      { name = "sabotage"; oid = "KAM-PRO::sabotage.0"; }
      { name = "gsmsignal"; oid = "KAM-PRO::gsmsignal.0"; }
      { name = "gsmok"; oid = "KAM-PRO::gsmok.0"; }
      { name = "systemarmed"; oid = "KAM-PRO::systemarmed.0"; }
      { name = "alarmtemp"; oid = "KAM-PRO::alarmtemp.0"; }
      { name = "alarmhum"; oid = "KAM-PRO::alarmhum.0"; }
      { name = "alarmdewpoint"; oid = "KAM-PRO::alarmdewpoint.0"; }
      { name = "alarmco"; oid = "KAM-PRO::alarmco.0"; }
    ]
    /* Sensor fields generated from configured counts. */
    ++ (kentixFuncs.mkMultisensor deviceCfg.endpoints.multisensors)
    ++ (kentixFuncs.mkTemperature deviceCfg.endpoints.temperatures)
    ++ (kentixFuncs.mkHumidity deviceCfg.endpoints.humiditys)
    ++ (kentixFuncs.mkDewpoint deviceCfg.endpoints.dewpoints)
    ++ (kentixFuncs.mkAlarm deviceCfg.endpoints.alarms)
    ++ (kentixFuncs.mkCo2 deviceCfg.endpoints.co2s)
    ++ (kentixFuncs.mkMotion deviceCfg.endpoints.motions)
    ++ (kentixFuncs.mkDigiIn1 deviceCfg.endpoints.digitalIn1s)
    ++ (kentixFuncs.mkDigiIn2 deviceCfg.endpoints.digitalIn2s)
    ++ (kentixFuncs.mkDigiOut2 deviceCfg.endpoints.digitalOut2s)
    ++ (kentixFuncs.mkInitErrors deviceCfg.endpoints.initErrors)
    ;
  };

  /* Assemble all configured SNMP inputs for Kentix sensors. */
  snmpInputs = telegrafOptions.mkSnmpInputs deviceCfg.endpoints.self mkSnmpInput;

in {
  /* Kentix sensors SNMP options. */
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors = lib.recursiveUpdate
    (telegrafOptions.mkSnmpV2Options ''
      Whether to enable the Kentix Sensor monitoring via SNMP.
    '')
    {
      endpoints = {
        multisensors = mkOption {
          default = 0;
          type = types.int;
          description = "How many Multisensors? (Max 9)";
        };
        temperatures = mkOption {
          default = 0;
          type = types.int;
          description = "How many temperature sensors? (Max 9)";
        };
        humiditys = mkOption {
          default = 0;
          type = types.int;
          description = "How many humidity sensors? (Max 9)";
        };
        dewpoints = mkOption {
          default = 0;
          type = types.int;
          description = "How many dewpoint? (Max 9)";
        };
        alarms = mkOption {
          default = 0;
          type = types.int;
          description = "How many alarms? (Max 2)";
        };
        co2s = mkOption {
          default = 0;
          type = types.int;
          description = "How many CO2 sensors? (Max 9)";
        };
        motions = mkOption {
          default = 0;
          type = types.int;
          description = "How many motion sensors? (Max 9)";
        };
        digitalIn1s = mkOption {
          default = 0;
          type = types.int;
          description = "How many Digital IN 1? (Max 9)";
        };
        digitalIn2s = mkOption {
          default = 0;
          type = types.int;
          description = "How many Digital IN 2? (Max 9)";
        };
        digitalOut2s = mkOption {
          default = 0;
          type = types.int;
          description = "How many Digital OUT 2? (Max 9)";
        };
        initErrors = mkOption {
          default = 0;
          type = types.int;
          description = "How many Initialization Errors? (Max 9)";
        };
      };
    };

  config = {
    senpro.monitoring.telegraf.rawInputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
