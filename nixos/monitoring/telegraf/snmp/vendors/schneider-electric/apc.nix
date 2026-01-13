{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ../../../options.nix { inherit lib; };
  deviceCfg = cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc;
  snmpCfg = cfg.monitoring.telegraf.inputs.snmp;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc = {
    endpoints = {
      self = {
        enable = mkEnableOption ''
          Whether to enable the Schneider Electric APC monitoring via SNMP.
        '';
        agents = telegrafOptions.agentConfig;
      };
    };
    credentials = telegrafOptions.authSNMPv3;
  };

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf (snmpCfg.enable && deviceCfg.endpoints.self.enable) (
      map (agent: {
        name = "schneiderElectric.apc";
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
          { name = "serialNumber"; oid = "PowerNet-MIB::upsAdvIdentSerialNumber.0"; }
          { name = "firmwareRevision"; oid = "PowerNet-MIB::upsAdvIdentFirmwareRevision.0"; }
          { name = "host"; oid = "PowerNet-MIB::upsBasicIdentName.0"; is_tag = true; }
          { name = "model"; oid = "PowerNet-MIB::upsBasicIdentModel.0"; }
          { name = "manufacturingDate"; oid = "PowerNet-MIB::upsAdvIdentDateOfManufacture.0"; }
          { name = "upsSku"; oid = "PowerNet-MIB::upsAdvIdentSkuNumber.0"; }
          { name = "batteryInternalSku"; oid = "PowerNet-MIB::upsAdvBatteryInternalSKU.0"; }
          { name = "batteryExternalSku"; oid = "PowerNet-MIB::upsAdvBatteryExternalSKU.0"; }
          { name = "batteryActualVoltage"; oid = "PowerNet-MIB::upsAdvBatteryActualVoltage.0"; }
          { name = "batteryCapacity"; oid = "PowerNet-MIB::upsAdvBatteryCapacity.0"; }
          { name = "batteryNumOfBattPacks"; oid = "PowerNet-MIB::upsAdvBatteryNumOfBattPacks.0"; }
          { name = "batteryRunTimeRemaining"; oid = "PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0"; }
          { name = "batteryReplaceDate"; oid = "PowerNet-MIB::upsBasicBatteryLastReplaceDate.0"; }
          { name = "batteryReplaceIndicator"; oid = "PowerNet-MIB::upsAdvBatteryReplaceIndicator.0"; }
          { name = "batteryReplaceRecommendedDate"; oid = "PowerNet-MIB::upsAdvBatteryRecommendedReplaceDate.0"; }
          { name = "batteryStatus"; oid = "PowerNet-MIB::upsBasicBatteryStatus.0"; }
          { name = "batteryTemperature"; oid = "PowerNet-MIB::upsAdvBatteryTemperature.0"; }
          { name = "batteryTimeON"; oid = "PowerNet-MIB::upsBasicBatteryTimeOnBattery.0"; }
          { name = "configNumDevices"; oid = "PowerNet-MIB::upsBasicConfigNumDevices.0"; }
          { name = "inputFrequency"; oid = "PowerNet-MIB::upsHighPrecInputFrequency.0"; conversion = "float(1)"; }
          { name = "inputLineFailCause"; oid = "PowerNet-MIB::upsAdvInputLineFailCause.0"; }
          { name = "inputLineVoltage"; oid = "PowerNet-MIB::upsHighPrecInputLineVoltage.0"; conversion = "float(1)"; }
          { name = "inputLineVoltageMin"; oid = "PowerNet-MIB::upsHighPrecInputMinLineVoltage.0"; conversion = "float(1)"; }
          { name = "inputLineVoltageMax"; oid = "PowerNet-MIB::upsHighPrecInputMaxLineVoltage.0"; conversion = "float(1)"; }
          { name = "outputStatus"; oid = "PowerNet-MIB::upsBasicOutputStatus.0"; }
          { name = "outputActivePower"; oid = "PowerNet-MIB::upsAdvOutputActivePower.0"; }
          { name = "outputApparentPower"; oid = "PowerNet-MIB::upsAdvOutputApparentPower.0"; }
          { name = "outputCurrent"; oid = "PowerNet-MIB::upsHighPrecOutputCurrent.0"; conversion = "float(1)"; }
          { name = "outputFrequency"; oid = "PowerNet-MIB::upsHighPrecOutputFrequency.0"; conversion = "float(1)"; }
          { name = "outputLoad"; oid = "PowerNet-MIB::upsHighPrecOutputLoad.0"; conversion = "float(1)"; }
          { name = "outputVoltage"; oid = "PowerNet-MIB::upsHighPrecOutputVoltage.0"; conversion = "float(1)"; }
          { name = "testCalibrationLastRunning"; oid = "PowerNet-MIB::upsAdvTestCalibrationDate.0"; }
          { name = "testCalibrationLastSuccessful"; oid = "PowerNet-MIB::upsAdvTestCalibrationLastSuccessfulDate.0"; }
          { name = "testCalibrationResults"; oid = "PowerNet-MIB::upsAdvTestCalibrationResults.0"; }
          { name = "testDiagnosticsLastRunning"; oid = "PowerNet-MIB::upsAdvTestLastDiagnosticsDate.0"; }
          { name = "testDiagnosticsResults"; oid = "PowerNet-MIB::upsAdvTestDiagnosticsResults.0"; }
          { name = "testDiagnosticsSchedule"; oid = "PowerNet-MIB::upsAdvTestDiagnosticSchedule.0"; }
        ];
        table = [
          { name = "schneiderElectric.apc.configDevice"; oid = "PowerNet-MIB::upsBasicConfigDeviceTable"; inherit_tags = [ "host" ]; }
        ];
      }) deviceCfg.endpoints.self.agents
    );
  };
}
