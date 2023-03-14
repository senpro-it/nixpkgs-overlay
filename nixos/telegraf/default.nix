{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.senpro;

  settingsFormat = pkgs.formats.toml {};

  telegrafOptions.agentConfig = mkOption {
    type = types.listOf types.str;
    default = [];
    example = literalExpression ''
      [ "udp://192.168.178.1:161" ]
    '';
    description = lib.mdDoc ''
      Endpoints which should be monitored. See the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for syntax reference.
    '';
  };

  telegrafOptions.authSNMPv3 = with types; {
    authentication = {
      protocol = mkOption {
        type = types.enum [ "MD5" "SHA" "SHA224" "SHA256" "SHA384" "SHA512" ];
        default = "MD5";
        example = "SHA";
        description = lib.mdDoc ''
          Authentication protocol used by SNMPv3 to authenticate at the agent.
        '';
      };
      password = mkOption {
        type = types.str;
        default = "yzL9sHgeYf5NJzaeAB73014M7XrY6Aagj8UhrHbePfCfxBa99uLzVrGC8ywhfW97";
        example = "VJQUpLCLGniEDVGK8Q0oPS9Yf0xObE7m8aCDK4FR7Kzzh47MD2ZQy0dVtTkDeKBd";
        description = lib.mdDoc ''
          Password used by SNMPv3 to authenticate at the agent.
        '';
      };
    };
    privacy = {
      protocol = mkOption {
        type = types.enum [ "DES" "AES" "AES192" "AES192C" "AES256" "AES256C" ];
        default = "MD5";
        example = "SHA";
        description = lib.mdDoc ''
          Privacy protocol used by SNMPv3 to authenticate at the agent.
        '';
      };
      password = mkOption {
        type = types.str;
          default = "qNMR7yeaIyQ8HKfRCZU8UW5AdKM6P56UALUeYATENOn4dX3nezXELwmLgpuMWKS2";
          example = "GO61HVwspXO514vbzZiV3IwGeBnSZsjHoBaHbJU4JgEaznJ4AdVTy0wzwpzgNffz";
          description = lib.mdDoc ''
            Password used by SNMPv3 to protect to connectiont to the agent.
          '';
        };
      };
    security = {
      level = mkOption {
        type = types.enum [ "noAuthNoPriv" "authNoPriv" "authPriv" ];
        default = "authPriv";
        example = "authPriv";
        description = lib.mdDoc ''
          Security level for SNMPv3. Look at the [documentation](https://snmp.com/snmpv3/snmpv3_intro.shtml) for further information.
        '';
      };
      username = mkOption {
        type = types.str;
        default = "monitor";
        example = "monitor";
        description = lib.mdDoc ''
          Username for SNMPv3. Also known as `Security Name`.
        '';
      };
    };
  };

in {

  options.senpro = {
    telegraf = {
      enable = mkEnableOption ''
        Whether to enable the telegraf monitoring agent.
      '';
      outputs = mkOption {
        default = {};
        description = lib.mdDoc "Output configuration for telegraf";
        type = settingsFormat.type;
        example = {
          influxdb_v2 = {
            urls = [ "https://influxdb.example.com/" ];
            token = "your-influxdb-token";
            organization = "ExampleOrg";
            bucket = "ExampleBucket";
          };
        };
      };
      inputs = {
        snmp = {
          enable = mkEnableOption ''
            Whether to enable SNMP monitoring.
          '';
          vendors = {
            aruba = {
              mobilityGateway = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the Aruba Mobility Gateway monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                  accessPoints = {
                    enable = mkEnableOption ''
                      Whether to enable the Aruba AP monitoring (through Mobility Gateway) via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            qnap = {
              nas = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the QNAP NAS monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            schneiderElectric = {
              apc = {
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
            };
            sonicWall = {
              fwTzNsa = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the SonicWall TZ & NSa monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            sophos = {
              sg = {
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
              xg = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the Sophos XG/XGS monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            synology = {
              nas = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the Synology NAS monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
          };
        };
      };
    };
  };

  config = {

    services.telegraf = lib.mkIf cfg.telegraf.enable {
      enable = true;
      extraConfig = {
        agent = {
          interval = "60s";
          snmp_translator = "gosmi";
        };
        inputs = {
          snmp = lib.mkIf cfg.telegraf.inputs.snmp.enable [
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.self.enable {
              name = "aruba.mobilityGateway.self";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "contact";
                  oid = "SNMPv2-MIB::sysContact.0";
                }
                {
                  name = "cpuModel";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtProcessorModel.0";
                }
                {
                  name = "cpuTotal";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtTotalCpu.0";
                }
                {
                  name = "cpuUsedPercent";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtCpuUsedPercent.0";
                }
                {
                  name = "description";
                  oid = "SNMPv2-MIB::sysDescr.0";
                }
                {
                  name = "fwVersion";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtSwVersion.0";
                }
                {
                  name = "host";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtHostname.0";
                  is_tag = true;
                }
                {
                  name = "hwVersion";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtHwVersion.0";
                }
                {
                  name = "memoryUsedPercent";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryUsedPercent.0";
                }
                {
                  name = "model";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtModelName.0";
                }
                {
                  name = "packetLossPercent";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryUsedPercent.0";
                }
                {
                  name = "serialNumber";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtSerialNumber.0";
                }
                {
                  name = "uptime";
                  oid = "SNMPv2-MIB::sysUpTime.0";
                }
              ];
              table = [
                {
                  name = "aruba.mobilityGateway.self.memory";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "aruba.mobilityGateway.self.processor";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtProcessorTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.accessPoints.enable {
              name = "aruba.mobilityGateway.accessPoints";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.accessPoints.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.password}";
              retries = 5;
              table = [
                {
                  name = "aruba.mobilityGateway.accessPoints";
                  oid = "WLSX-WLAN-MIB::wlsxWlanAPTable";
                  index_as_tag = true;
                  field = [
                    {
                      oid = "WLSX-WLAN-MIB::wlanAPName";
                      is_tag = true;
                    }
                  ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.qnap.nas.endpoints.self.enable {
              name = "qnap.nas";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.qnap.nas.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.qnap.nas.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.qnap.nas.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.qnap.nas.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.qnap.nas.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.qnap.nas.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.qnap.nas.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "cpuUsed";
                  oid = "QTS-MIB::systemCPU-Usage.0";
                }
                {
                  name = "cpuTemperature";
                  oid = "QTS-MIB::cpuTemperature.0";
                }
                {
                  name = "diskCount";
                  oid = "QTS-MIB::diskCount.0";
                }
                {
                  name = "host";
                  oid = "SNMPv2-MIB::sysName.0";
                  is_tag = true;
                }
                {
                  name = "memFree";
                  oid = "QTS-MIB::systemFreeMem.0";
                }
                {
                  name = "memUsed";
                  oid = "QTS-MIB::systemUsedMemory.0";
                }
                {
                  name = "memTotal";
                  oid = "QTS-MIB::systemTotalMem.0";
                }
                {
                  name = "raidCount";
                  oid = "QTS-MIB::raidCount.0";
                }
                {
                  name = "systemModel";
                  oid = "QTS-MIB::systemModel.0";
                }
                {
                  name = "systemTemperature";
                  oid = "QTS-MIB::systemTemperature.0";
                }
                {
                  name = "systemPower";
                  oid = "QTS-MIB::sysPowerStatus.0";
                }
                {
                  name = "systemUptime";
                  oid = "QTS-MIB::sysUptime.0";
                }
                {
                  name = "serialNumber";
                  oid = "QTS-MIB::serialNumber.0";
                }
                {
                  name = "firmwareVersion";
                  oid = "QTS-MIB::firmwareVersion.0";
                }
                {
                  name = "firmwareUpdateAvailable";
                  oid = "QTS-MIB::firmwareUpgradeAvailable.0";
                }
              ];
              table = [
                {
                  name = "qnap.nas.disk";
                  oid = "QTS-MIB::diskTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "qnap.nas.interface";
                  oid = "NAS-MIB::systemIfTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "qnap.nas.lun";
                  oid = "QTS-MIB::lunTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "qnap.nas.raid";
                  oid = "QTS-MIB::raidTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "qnap.nas.systemFan";
                  oid = "QTS-MIB::systemFanTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "qnap.nas.target";
                  oid = "QTS-MIB::targeTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "qnap.nas.volume";
                  oid = "QTS-MIB::volumeTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.endpoints.self.enable {
              name = "schneiderElectric.apc";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "batteryActualVoltage";
                  oid = "PowerNet-MIB::upsAdvBatteryActualVoltage.0";
                }
                {
                  name = "batteryCapacity";
                  oid = "PowerNet-MIB::upsAdvBatteryCapacity.0";
                }
                {
                  name = "batteryNumOfBattPacks";
                  oid = "PowerNet-MIB::upsAdvBatteryNumOfBattPacks.0";
                }
                {
                  name = "batteryRunTimeRemaining";
                  oid = "PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0";
                }
                {
                  name = "batteryReplaceDate";
                  oid = "PowerNet-MIB::upsBasicBatteryLastReplaceDate.0";
                }
                {
                  name = "batteryReplaceIndicator";
                  oid = "PowerNet-MIB::upsAdvBatteryReplaceIndicator.0";
                }
                {
                  name = "batteryStatus";
                  oid = "PowerNet-MIB::upsBasicBatteryStatus.0";
                }
                {
                  name = "batteryTemperature";
                  oid = "PowerNet-MIB::upsAdvBatteryTemperature.0";
                }
                {
                  name = "batteryTimeON";
                  oid = "PowerNet-MIB::upsBasicBatteryTimeOnBattery.0";
                }
                {
                  name = "configNumDevices";
                  oid = "PowerNet-MIB::upsBasicConfigNumDevices.0";
                }
                {
                  name = "firmwareRevision";
                  oid = "PowerNet-MIB::upsAdvIdentFirmwareRevision.0";
                }
                {
                  name = "host";
                  oid = "PowerNet-MIB::upsBasicIdentName.0";
                  is_tag = true;
                }
                {
                  name = "inputFrequency";
                  oid = "PowerNet-MIB::upsHighPrecInputFrequency.0";
                  conversion = "float(1)";
                }
                {
                  name = "inputLineFailCause";
                  oid = "PowerNet-MIB::upsAdvInputLineFailCause.0";
                }
                {
                  name = "inputLineVoltage";
                  oid = "PowerNet-MIB::upsHighPrecInputLineVoltage.0";
                  conversion = "float(1)";
                }
                {
                  name = "inputLineVoltageMin";
                  oid = "PowerNet-MIB::upsHighPrecInputMinLineVoltage.0";
                  conversion = "float(1)";
                }
                {
                  name = "inputLineVoltageMax";
                  oid = "PowerNet-MIB::upsHighPrecInputMaxLineVoltage.0";
                  conversion = "float(1)";
                }
                {
                  name = "model";
                  oid = "PowerNet-MIB::upsBasicIdentModel.0";
                }
                {
                  name = "outputStatus";
                  oid = "PowerNet-MIB::upsBasicOutputStatus.0";
                }
                {
                  name = "outputCurrent";
                  oid = "PowerNet-MIB::upsHighPrecOutputLoad.0";
                  conversion = "float(1)";
                }
                {
                  name = "outputFrequency";
                  oid = "PowerNet-MIB::upsHighPrecOutputFrequency.0";
                  conversion = "float(1)";
                }
                {
                  name = "outputLoad";
                  oid = "PowerNet-MIB::upsHighPrecOutputLoad.0";
                  conversion = "float(1)";
                }
                {
                  name = "outputVoltage";
                  oid = "PowerNet-MIB::upsHighPrecOutputVoltage.0";
                  conversion = "float(1)";
                }
                {
                  name = "serialNumber";
                  oid = "PowerNet-MIB::upsAdvIdentSerialNumber.0";
                }
                {
                  name = "testCalibrationLastRunning";
                  oid = "PowerNet-MIB::upsAdvTestCalibrationDate.0";
                }
                {
                  name = "testCalibrationLastSuccessful";
                  oid = "PowerNet-MIB::upsAdvTestCalibrationLastSuccessfulDate.0";
                }
                {
                  name = "testCalibrationResults";
                  oid = "PowerNet-MIB::upsAdvTestCalibrationResults.0";
                }
                {
                  name = "testDiagnosticsLastRunning";
                  oid = "PowerNet-MIB::upsAdvTestLastDiagnosticsDate.0";
                }
                {
                  name = "testDiagnosticsResults";
                  oid = "PowerNet-MIB::upsAdvTestDiagnosticsResults.0";
                }
                {
                  name = "testDiagnosticsSchedule";
                  oid = "PowerNet-MIB::upsAdvTestDiagnosticSchedule.0";
                }
              ];
              table = [
                {
                  name = "schneiderElectric.apc.configDevice";
                  oid = "PowerNet-MIB::upsBasicConfigDeviceTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.endpoints.self.enable {
              name = "sonicWall.fwTzNsa";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "contact";
                  oid = "SNMPv2-MIB::sysContact.0";
                }
                {
                  name = "description";
                  oid = "SNMPv2-MIB::sysDescr.0";
                }
                {
                  name = "host";
                  oid = "SNMPv2-MIB::sysName.0";
                  is_tag = true;
                }
                {
                  name = "firmwareVersion";
                  oid = "SNWL-COMMON-MIB::snwlSysFirmwareVersion.0";
                }
                {
                  name = "model";
                  oid = "SNWL-COMMON-MIB::snwlSysModel.0";
                }
                {
                  name = "romVersion";
                  oid = "SNWL-COMMON-MIB::snwlSysROMVersion.0";
                }
                {
                  name = "serialNumber";
                  oid = "SNWL-COMMON-MIB::snwlSysSerialNumber.0";
                }
                {
                  name = "uptime";
                  oid = "SNMPv2-MIB::sysUpTime.0";
                }
              ];
            table = [
                {
                  name = "sonicWall.interface";
                  oid = "IF-MIB::ifTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "sonicWall.ipAddresses";
                  oid = "IP-MIB::ipAddrTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.sophos.sg.endpoints.self.enable {
              name = "sophos.sg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.sophos.sg.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.sophos.sg.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.sophos.sg.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.sophos.sg.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.sophos.sg.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.sophos.sg.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.sophos.sg.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "contact";
                  oid = "SNMPv2-MIB::sysContact.0";
                }
                {
                  name = "description";
                  oid = "SNMPv2-MIB::sysDescr.0";
                }
                {
                  name = "host";
                  oid = "SNMPv2-MIB::sysName.0";
                  is_tag = true;
                }
                {
                  name = "uptime";
                  oid = "SNMPv2-MIB::sysUpTime.0";
                }
              ];
              table = [
                {
                  name = "sophos.sg.cpu";
                  oid = "HOST-RESOURCES-MIB::hrProcessorTable";
                  index_as_tag = true;
                  inherit_tags = [ "host" ];
                }
                {
                  name = "sophos.sg.interface";
                  oid = "IF-MIB::ifTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "sophos.sg.ipAddresses";
                  oid = "IP-MIB::ipAddrTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "sophos.sg.storage";
                  oid = "HOST-RESOURCES-MIB::hrStorageTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.sophos.xg.endpoints.self.enable {
              name = "sophos.xg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.sophos.sg.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.sophos.xg.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.sophos.xg.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.sophos.xg.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.sophos.xg.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.sophos.xg.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.sophos.xg.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "contact";
                  oid = "SNMPv2-MIB::sysContact.0";
                }
                {
                  name = "description";
                  oid = "SNMPv2-MIB::sysDescr.0";
                }
                {
                  name = "deviceType";
                  oid = "SFOS-FIREWALL-MIB::sfosDeviceType.0";
                }
                {
                  name = "diskCapacity";
                  oid = "SFOS-FIREWALL-MIB::sfosDiskCapacity.0";
                }
                {
                  name = "diskPercentUsage";
                  oid = "SFOS-FIREWALL-MIB::sfosDiskPercentUsage.0";
                }
                {
                  name = "fwVersion";
                  oid = "SFOS-FIREWALL-MIB::sfosDeviceFWVersion.0";
                }
                {
                  name = "host";
                  oid = "SFOS-FIREWALL-MIB::sfosDeviceName.0";
                  is_tag = true;
                }
                {
                  name = "licenseBaseFWStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosBaseFWLicRegStatus.0";
                }
                {
                  name = "licenseBaseFWExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosBaseFWLicExpiryDate.0";
                }
                {
                  name = "licenseNetProtectionStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosNetProtectionLicRegStatus.0";
                }
                {
                  name = "licenseNetProtectionExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosNetProtectionLicExpiryDate.0";
                }
                {
                  name = "licenseWebProtectionStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosWebProtectionLicRegStatus.0";
                }
                {
                  name = "licenseWebProtectionExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosWebProtectionLicExpiryDate.0";
                }
                {
                  name = "licenseMailProtectionStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosMailProtectionLicRegStatus.0";
                }
                {
                  name = "licenseMailProtectionExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosMailProtectionLicExpiryDate.0";
                }
                {
                  name = "licenseWebServerProtectionStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosWebServerProtectionLicRegStatus.0";
                }
                {
                  name = "licenseWebServerProtectionExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosWebServerProtectionLicExpiryDate.0";
                }
                {
                  name = "licenseSandstromProtectionStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosSandstromLicRegStatus.0";
                }
                {
                  name = "licenseSandstromProtectionExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosSandstromLicExpiryDate.0";
                }
                {
                  name = "licenseEnhancedSupportStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosEnhancedSupportLicRegStatus.0";
                }
                {
                  name = "licenseEnhancedSupportExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosEnhancedSupportLicExpiryDate.0";
                }
                {
                  name = "licenseEnhancedSupportPlusStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosEnhancedPlusLicRegStatus.0";
                }
                {
                  name = "licenseEnhancedSupportPlusExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosEnhancedPlusLicExpiryDate.0";
                }
                {
                  name = "licenseCentralOrchestrationStatus";
                  oid = "SFOS-FIREWALL-MIB::sfosCentralOrchestrationLicRegStatus.0";
                }
                {
                  name = "licenseCentralOrchestrationExpiry";
                  oid = "SFOS-FIREWALL-MIB::sfosCentralOrchestrationLicExpiryDate.0";
                }
                {
                  name = "memoryCapacity";
                  oid = "SFOS-FIREWALL-MIB::sfosMemoryCapacity.0";
                }
                {
                  name = "memoryPercentUsage";
                  oid = "SFOS-FIREWALL-MIB::sfosMemoryPercentUsage.0";
                }
                {
                  name = "serviceApache";
                  oid = "SFOS-FIREWALL-MIB::sfosApacheService.0";
                }
                {
                  name = "serviceAS";
                  oid = "SFOS-FIREWALL-MIB::sfosASService.0";
                }
                {
                  name = "serviceAV";
                  oid = "SFOS-FIREWALL-MIB::sfosAVService.0";
                }
                {
                  name = "serviceDatabase";
                  oid = "SFOS-FIREWALL-MIB::sfosDatabaseservice.0";
                }
                {
                  name = "serviceDGD";
                  oid = "SFOS-FIREWALL-MIB::sfosDgdService.0";
                }
                {
                  name = "serviceDNS";
                  oid = "SFOS-FIREWALL-MIB::sfosDNSService.0";
                }
                {
                  name = "serviceDRouting";
                  oid = "SFOS-FIREWALL-MIB::sfosDroutingService.0";
                }
                {
                  name = "serviceFTP";
                  oid = "SFOS-FIREWALL-MIB::sfosFtpService.0";
                }
                {
                  name = "serviceGarner";
                  oid = "SFOS-FIREWALL-MIB::sfosGarnerService.0";
                }
                {
                  name = "serviceHA";
                  oid = "SFOS-FIREWALL-MIB::sfosHAService.0";
                }
                {
                  name = "serviceHTTP";
                  oid = "SFOS-FIREWALL-MIB::sfosHttpService.0";
                }
                {
                  name = "serviceIMAP4";
                  oid = "SFOS-FIREWALL-MIB::sfosImap4Service.0";
                }
                {
                  name = "serviceIPS";
                  oid = "SFOS-FIREWALL-MIB::sfosIPSService.0";
                }
                {
                  name = "serviceIPSec";
                  oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnService.0";
                }
                {
                  name = "serviceNetwork";
                  oid = "SFOS-FIREWALL-MIB::sfosNetworkService.0";
                }
                {
                  name = "serviceNTP";
                  oid = "SFOS-FIREWALL-MIB::sfosNtpService.0";
                }
                {
                  name = "servicePOP3";
                  oid = "SFOS-FIREWALL-MIB::sfosPoP3Service.0";
                }
                {
                  name = "serviceSSHd";
                  oid = "SFOS-FIREWALL-MIB::sfosSSHdService.0";
                }
                {
                  name = "serviceSSLVPN";
                  oid = "SFOS-FIREWALL-MIB::sfosSSLVpnService.0";
                }
                {
                  name = "serviceTomcat";
                  oid = "SFOS-FIREWALL-MIB::sfosTomcatService.0";
                }
                {
                  name = "swapCapacity";
                  oid = "SFOS-FIREWALL-MIB::sfosSwapCapacity.0";
                }
                {
                  name = "swapPercentUsage";
                  oid = "SFOS-FIREWALL-MIB::sfosSwapPercentUsage.0";
                }
                {
                  name = "uptime";
                  oid = "SFOS-FIREWALL-MIB::sfosUpTime.0";
                }
              ];
              table = [
                {
                  name = "sophos.xg.interface";
                  oid = "IF-MIB::ifTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "sophos.xg.ipAddresses";
                  oid = "IP-MIB::ipAddrTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.synology.nas.endpoints.self.enable {
              name = "synology.nas";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.synology.nas.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.synology.nas.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.synology.nas.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.synology.nas.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.synology.nas.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.synology.nas.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.synology.nas.credentials.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "contact";
                  oid = "SNMPv2-MIB::sysContact.0";
                }
                {
                  name = "description";
                  oid = "SNMPv2-MIB::sysDescr.0";
                }
                {
                  name = "host";
                  oid = "SNMPv2-MIB::sysName.0";
                  is_tag = true;
                }
                {
                  name = "model";
                  oid = "SYNOLOGY-SYSTEM-MIB::modelName.0";
                }
                {
                  name = "uptime";
                  oid = "SNMPv2-MIB::sysUpTime.0";
                }
                {
                  name = "serialNumber";
                  oid = "SYNOLOGY-SYSTEM-MIB::serialNumber.0";
                }
                {
                  name = "firmwareVersion";
                  oid = "SYNOLOGY-SYSTEM-MIB::version.0";
                }
                {
                  name = "firmwareUpgradeAvailable";
                  oid = "SYNOLOGY-SYSTEM-MIB::upgradeAvailable.0";
                }
              ];
            table = [
                {
                  name = "synology.nas.cpu";
                  oid = "HOST-RESOURCES-MIB::hrProcessorTable";
                  index_as_tag = true;
                  inherit_tags = [ "host" ];
                }
                {
                  name = "synology.nas.disk";
                  oid = "SYNOLOGY-DISK-MIB::diskTable";
                  inherit_tags = [ "host" ];
                }
                {
                  name = "synology.nas.raid";
                  oid = "SYNOLOGY-RAID-MIB::raidTable";
                  inherit_tags = [ "host" ];
                }
              ];
            })
          ];
        };
        outputs = cfg.telegraf.outputs;
      };
    };
  };

}
