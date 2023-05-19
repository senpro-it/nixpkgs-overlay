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
    context = {
      name = mkOption {
        type = types.str;
        example = "27652626525562";
        description = lib.mdDoc ''
          Context name for SNMPv3 to authenticate at the agent.
        '';
      };
    };
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
        api = {
          enable = mkEnableOption ''
            Whether to enable SNMP monitoring.
          '';
          vendors = {
            sophos = {
              central = {
                enable = mkEnableOption ''
                  Whether to enable the Aruba Mobility Gateway monitoring via SNMP.
                '';
                client = {
                  id = mkOption {
                    type = types.str;
                    example = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                    description = lib.mdDoc ''
                      Client ID for the Sophos Central API (Tenant).
                    '';
                  };
                  secret = mkOption {
                    type = types.str;
                    example = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
                    description = lib.mdDoc ''
                      Client Secret for the Sophos Central API (Tenant).
                    '';
                  }; };
              };
            };
            vmware = {
              vsphere = {
                enable = mkEnableOption ''
                  Whether to enable the vSphere monitoring.
                '';
                sdk = {
                  username = mkOption {
                    type = types.str;
                    example = "Administrator@vsphere.local";
                    default = "Administrator@vsphere.local";
                    description = lib.mdDoc ''
                      Username of the login user for vSphere.
                    '';
                  };
                  password = mkOption {
                    type = types.str;
                    example = "C8TK9UHEKLSv7BcJPKpEu5ij8de3HEHa";
                    description = lib.mdDoc ''
                      Password of the login user for vSphere.
                    '';
                  };
                  endpoints = mkOption {
                    type = types.listOf types.str;
                    default = [];
                    example = literalExpression ''
                      [ "https://vcenter.local/sdk" ]
                    '';
                    description = lib.mdDoc ''
                      vSphere instances which should be monitored. Note the `/sdk` at the end, which is essentially to connect to the right endpoint.
                    '';
                  }; };
              };
            };
          };
        };
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
                  }; };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            cisco = {
              switch = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the Cisco switch monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  }; };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            fs = {
              switch = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the FS switch monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  }; };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
            kentix = {
              doorlocks = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the Kentix doorlock monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  }; };
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
                  }; };
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
                  }; };
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
                  }; };
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
                  }; };
                credentials = telegrafOptions.authSNMPv3;
              };
              xg = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable the Sophos XG/XGS monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  }; };
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
                  }; };
                credentials = telegrafOptions.authSNMPv3;
              };
            };
          };
        };
      };
    };
    unifi-poller = {
      enable = mkEnableOption ''
        Whether to enable the UniFi poller (Ubiquiti monitoring agent).
      '';
      input = {
        unifi-controller = {
          url = mkOption {
            type = types.str;
            example = "https://unifictrl.example.com:8443/";
            description = lib.mdDoc ''
              URL of the targeted UniFi controller.
            '';
          };
          user = mkOption {
            type = types.str;
            example = "admin";
            description = lib.mdDoc ''
              User to access the targeted UniFi controller.
            '';
          };
          pass = mkOption {
            type = types.str;
            example = "your-secure-password";
            description = lib.mdDoc ''
              Password for the specified UniFi controller read-access user.
            '';
          };
        };
      };
      output = {
        influxdb_v2 = {
          url = mkOption {
            type = types.str;
            example = "https://influxdb.example.com/";
            description = lib.mdDoc ''
              URL of the targeted InfluxDB instance.
            '';
          };
          token = mkOption {
            type = types.str;
            example = "your-influxdb-token";
            description = lib.mdDoc ''
              Token for the the targeted InfluxDB instance.
            '';
          };
          organization = mkOption {
            type = types.str;
            example = "your-influxdb-org";
            description = lib.mdDoc ''
              InfluxDB organization where the targeted bucket resides.
            '';
          };
          bucket = mkOption {
            type = types.str;
            example = "your-influxdb-bucket";
            description = lib.mdDoc ''
              InfluxDB bucket where the output should be delivered to.
            '';
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
          exec = lib.mkIf cfg.telegraf.inputs.api.vendors.sophos.central.enable [
            (lib.mkIf cfg.telegraf.inputs.api.vendors.sophos.central.enable {
              commands = [ "${pkgs.line-exporters}/bin/lxp-sophos-central '${cfg.telegraf.inputs.api.vendors.sophos.central.client.id}' '${cfg.telegraf.inputs.api.vendors.sophos.central.client.secret}'" ];
              timeout = "5m";
              interval = "900s";
              data_format = "influx";
            })
          ];
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
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "cpuModel"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtProcessorModel.0"; }
                { name = "cpuTotal"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtTotalCpu.0"; }
                { name = "cpuUsedPercent"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtCpuUsedPercent.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "fwVersion"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtSwVersion.0"; }
                { name = "host"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtHostname.0"; is_tag = true; }
                { name = "hwVersion"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtHwVersion.0"; }
                { name = "memoryUsedPercent"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryUsedPercent.0"; }
                { name = "model"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtModelName.0"; }
                { name = "packetLossPercent"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryUsedPercent.0"; }
                { name = "serialNumber"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtSerialNumber.0"; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
              ];
              table = [
                { name = "aruba.mobilityGateway.self.memory"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryTable"; inherit_tags = [ "host" ]; }
                { name = "aruba.mobilityGateway.self.processor"; oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtProcessorTable"; inherit_tags = [ "host" ]; }
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
                  name = "aruba.mobilityGateway.accessPoints"; oid = "WLSX-WLAN-MIB::wlsxWlanAPTable"; index_as_tag = true;
                  field = [
                    { oid = "WLSX-WLAN-MIB::wlanAPName"; is_tag = true; }
                  ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.cisco.switch.endpoints.self.enable {
              name = "cisco.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.cisco.switch.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.cisco.switch.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.cisco.switch.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.cisco.switch.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.cisco.switch.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.cisco.switch.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.cisco.switch.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
              ];
              table = [
                { name = "cisco.switch.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "cisco.switch.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.fs.switch.endpoints.self.enable {
              name = "fs.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.fs.switch.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              context_name = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.context.name}";
              sec_level = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.security.level}";
              sec_name = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.security.username}";
              auth_protocol = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.authentication.protocol}";
              auth_password = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.authentication.password}";
              priv_protocol = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.privacy.protocol}";
              priv_password = "${cfg.telegraf.inputs.snmp.vendors.fs.switch.credentials.privacy.password}";
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
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.qnap.nas.endpoints.self.enable {
              name = "qnap.nas";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.qnap.nas.endpoints.self.agents;
              interval = "300s";
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
                { name = "batteryActualVoltage"; oid = "PowerNet-MIB::upsAdvBatteryActualVoltage.0"; }
                { name = "batteryCapacity"; oid = "PowerNet-MIB::upsAdvBatteryCapacity.0"; }
                { name = "batteryNumOfBattPacks"; oid = "PowerNet-MIB::upsAdvBatteryNumOfBattPacks.0"; }
                { name = "batteryRunTimeRemaining"; oid = "PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0"; }
                { name = "batteryReplaceDate"; oid = "PowerNet-MIB::upsBasicBatteryLastReplaceDate.0"; }
                { name = "batteryReplaceIndicator"; oid = "PowerNet-MIB::upsAdvBatteryReplaceIndicator.0"; }
                { name = "batteryStatus"; oid = "PowerNet-MIB::upsBasicBatteryStatus.0"; }
                { name = "batteryTemperature"; oid = "PowerNet-MIB::upsAdvBatteryTemperature.0"; }
                { name = "batteryTimeON"; oid = "PowerNet-MIB::upsBasicBatteryTimeOnBattery.0"; }
                { name = "configNumDevices"; oid = "PowerNet-MIB::upsBasicConfigNumDevices.0"; }
                { name = "firmwareRevision"; oid = "PowerNet-MIB::upsAdvIdentFirmwareRevision.0"; }
                { name = "host"; oid = "PowerNet-MIB::upsBasicIdentName.0"; is_tag = true; }
                { name = "inputFrequency"; oid = "PowerNet-MIB::upsHighPrecInputFrequency.0"; conversion = "float(1)"; }
                { name = "inputLineFailCause"; oid = "PowerNet-MIB::upsAdvInputLineFailCause.0"; }
                { name = "inputLineVoltage"; oid = "PowerNet-MIB::upsHighPrecInputLineVoltage.0"; conversion = "float(1)"; }
                { name = "inputLineVoltageMin"; oid = "PowerNet-MIB::upsHighPrecInputMinLineVoltage.0"; conversion = "float(1)"; }
                { name = "inputLineVoltageMax"; oid = "PowerNet-MIB::upsHighPrecInputMaxLineVoltage.0"; conversion = "float(1)"; }
                { name = "model"; oid = "PowerNet-MIB::upsBasicIdentModel.0"; }
                { name = "outputStatus"; oid = "PowerNet-MIB::upsBasicOutputStatus.0"; }
                { name = "outputCurrent"; oid = "PowerNet-MIB::upsHighPrecOutputLoad.0"; conversion = "float(1)"; }
                { name = "outputFrequency"; oid = "PowerNet-MIB::upsHighPrecOutputFrequency.0"; conversion = "float(1)"; }
                { name = "outputLoad"; oid = "PowerNet-MIB::upsHighPrecOutputLoad.0"; conversion = "float(1)"; }
                { name = "outputVoltage"; oid = "PowerNet-MIB::upsHighPrecOutputVoltage.0"; conversion = "float(1)"; }
                { name = "serialNumber"; oid = "PowerNet-MIB::upsAdvIdentSerialNumber.0"; }
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
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "firmwareVersion"; oid = "SNWL-COMMON-MIB::snwlSysFirmwareVersion.0"; }
                { name = "model"; oid = "SNWL-COMMON-MIB::snwlSysModel.0"; }
                { name = "romVersion"; oid = "SNWL-COMMON-MIB::snwlSysROMVersion.0"; }
                { name = "serialNumber"; oid = "SNWL-COMMON-MIB::snwlSysSerialNumber.0"; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
              ];
            table = [
                { name = "sonicwall.fwTzNsa.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "sonicwall.fwTzNsa.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "sonicWall.fwTzNsa.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
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
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
              ];
              table = [
                { name = "sophos.sg.cpu"; oid = "HOST-RESOURCES-MIB::hrProcessorTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
                { name = "sophos.sg.interface"; oid = "IF-MIB::ifTable"; inherit_tags = [ "host" ]; }
                { name = "sophos.sg.ipAddresses"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
                { name = "sophos.sg.storage"; oid = "HOST-RESOURCES-MIB::hrStorageTable"; inherit_tags = [ "host" ]; }
              ];
            })
            (lib.mkIf cfg.telegraf.inputs.snmp.vendors.sophos.xg.endpoints.self.enable {
              name = "sophos.xg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.inputs.snmp.vendors.sophos.xg.endpoints.self.agents;
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
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "deviceType"; oid = "SFOS-FIREWALL-MIB::sfosDeviceType.0"; }
                { name = "diskCapacity"; oid = "SFOS-FIREWALL-MIB::sfosDiskCapacity.0"; }
                { name = "diskPercentUsage"; oid = "SFOS-FIREWALL-MIB::sfosDiskPercentUsage.0"; }
                { name = "fwVersion"; oid = "SFOS-FIREWALL-MIB::sfosDeviceFWVersion.0"; }
                { name = "host"; oid = "SFOS-FIREWALL-MIB::sfosDeviceName.0"; is_tag = true; }
                { name = "licenseBaseFWStatus"; oid = "SFOS-FIREWALL-MIB::sfosBaseFWLicRegStatus.0"; }
                { name = "licenseBaseFWExpiry"; oid = "SFOS-FIREWALL-MIB::sfosBaseFWLicExpiryDate.0"; }
                { name = "licenseNetProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosNetProtectionLicRegStatus.0"; }
                { name = "licenseNetProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosNetProtectionLicExpiryDate.0"; }
                { name = "licenseWebProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosWebProtectionLicRegStatus.0"; }
                { name = "licenseWebProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosWebProtectionLicExpiryDate.0"; }
                { name = "licenseMailProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosMailProtectionLicRegStatus.0"; }
                { name = "licenseMailProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosMailProtectionLicExpiryDate.0"; }
                { name = "licenseWebServerProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosWebServerProtectionLicRegStatus.0"; }
                { name = "licenseWebServerProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosWebServerProtectionLicExpiryDate.0"; }
                { name = "licenseSandstromProtectionStatus"; oid = "SFOS-FIREWALL-MIB::sfosSandstromLicRegStatus.0"; }
                { name = "licenseSandstromProtectionExpiry"; oid = "SFOS-FIREWALL-MIB::sfosSandstromLicExpiryDate.0"; }
                { name = "licenseEnhancedSupportStatus"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedSupportLicRegStatus.0"; }
                { name = "licenseEnhancedSupportExpiry"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedSupportLicExpiryDate.0"; }
                { name = "licenseEnhancedSupportPlusStatus"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedPlusLicRegStatus.0"; }
                { name = "licenseEnhancedSupportPlusExpiry"; oid = "SFOS-FIREWALL-MIB::sfosEnhancedPlusLicExpiryDate.0"; }
                { name = "licenseCentralOrchestrationStatus"; oid = "SFOS-FIREWALL-MIB::sfosCentralOrchestrationLicRegStatus.0"; }
                { name = "licenseCentralOrchestrationExpiry"; oid = "SFOS-FIREWALL-MIB::sfosCentralOrchestrationLicExpiryDate.0"; }
                { name = "memoryCapacity"; oid = "SFOS-FIREWALL-MIB::sfosMemoryCapacity.0"; }
                { name = "memoryPercentUsage"; oid = "SFOS-FIREWALL-MIB::sfosMemoryPercentUsage.0"; }
                { name = "serviceApache"; oid = "SFOS-FIREWALL-MIB::sfosApacheService.0"; }
                { name = "serviceAS"; oid = "SFOS-FIREWALL-MIB::sfosASService.0"; }
                { name = "serviceAV"; oid = "SFOS-FIREWALL-MIB::sfosAVService.0"; }
                { name = "serviceDatabase"; oid = "SFOS-FIREWALL-MIB::sfosDatabaseservice.0"; }
                { name = "serviceDGD"; oid = "SFOS-FIREWALL-MIB::sfosDgdService.0"; }
                { name = "serviceDNS"; oid = "SFOS-FIREWALL-MIB::sfosDNSService.0"; }
                { name = "serviceDRouting"; oid = "SFOS-FIREWALL-MIB::sfosDroutingService.0"; }
                { name = "serviceFTP"; oid = "SFOS-FIREWALL-MIB::sfosFtpService.0"; }
                { name = "serviceGarner"; oid = "SFOS-FIREWALL-MIB::sfosGarnerService.0"; }
                { name = "serviceHA"; oid = "SFOS-FIREWALL-MIB::sfosHAService.0"; }
                { name = "serviceHTTP"; oid = "SFOS-FIREWALL-MIB::sfosHttpService.0"; }
                { name = "serviceIMAP4"; oid = "SFOS-FIREWALL-MIB::sfosImap4Service.0"; }
                { name = "serviceIPS"; oid = "SFOS-FIREWALL-MIB::sfosIPSService.0"; }
                { name = "serviceIPSec"; oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnService.0"; }
                { name = "serviceNetwork"; oid = "SFOS-FIREWALL-MIB::sfosNetworkService.0"; }
                { name = "serviceNTP"; oid = "SFOS-FIREWALL-MIB::sfosNtpService.0"; }
                { name = "servicePOP3"; oid = "SFOS-FIREWALL-MIB::sfosPoP3Service.0"; }
                { name = "serviceSSHd"; oid = "SFOS-FIREWALL-MIB::sfosSSHdService.0"; }
                { name = "serviceSSLVPN"; oid = "SFOS-FIREWALL-MIB::sfosSSLVpnService.0"; }
                { name = "serviceTomcat"; oid = "SFOS-FIREWALL-MIB::sfosTomcatService.0"; }
                { name = "swapCapacity"; oid = "SFOS-FIREWALL-MIB::sfosSwapCapacity.0"; }
                { name = "swapPercentUsage"; oid = "SFOS-FIREWALL-MIB::sfosSwapPercentUsage.0"; }
                { name = "uptime"; oid = "SFOS-FIREWALL-MIB::sfosUpTime.0"; }
              ];
              table = [
                { name = "sophos.xg.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "sophos.xg.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "sophos.xg.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
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
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "model"; oid = "SYNOLOGY-SYSTEM-MIB::modelName.0"; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "serialNumber"; oid = "SYNOLOGY-SYSTEM-MIB::serialNumber.0"; }
                { name = "firmwareVersion"; oid = "SYNOLOGY-SYSTEM-MIB::version.0"; }
                { name = "firmwareUpgradeAvailable"; oid = "SYNOLOGY-SYSTEM-MIB::upgradeAvailable.0"; }
                { name = "cpuFanStatus"; oid = "SYNOLOGY-SYSTEM-MIB::cpuFanStatus.0"; }
                { name = "cpuIdle"; oid = "UCD-SNMP-MIB::ssCpuIdle.0"; }
                { name = "powerStatus"; oid = "SYNOLOGY-SYSTEM-MIB::powerStatus.0"; }
                { name = "systemStatus"; oid = "SYNOLOGY-SYSTEM-MIB::systemStatus.0"; }
                { name = "systemFanStatus"; oid = "SYNOLOGY-SYSTEM-MIB::systemFanStatus.0"; }
                { name = "temperature"; oid = "SYNOLOGY-SYSTEM-MIB::temperature.0"; }
                { name = "memAvailReal"; oid = "UCD-SNMP-MIB::memAvailReal.0"; }
                { name = "memTotalReal"; oid = "UCD-SNMP-MIB::memTotalReal.0"; }
                { name = "memTotalFree"; oid = "UCD-SNMP-MIB::memTotalFree.0"; }
                { name = "memBuffer"; oid = "UCD-SNMP-MIB::memBuffer.0"; }
                { name = "memCached"; oid = "UCD-SNMP-MIB::memCached.0"; }
                { name = "memAvailSwap"; oid = "UCD-SNMP-MIB::memAvailSwap.0"; }
                { name = "memTotalSwap"; oid = "UCD-SNMP-MIB::memTotalSwap.0"; }
              ];
              table = [
                { name = "synology.nas.diskTable"; oid = "SYNOLOGY-DISK-MIB::diskTable"; inherit_tags = [ "host" ]; }
                { name = "synology.nas.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "synology.nas.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "synology.nas.raidTable"; oid = "SYNOLOGY-RAID-MIB::raidTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "SYNOLOGY-RAID-MIB::raidName"; is_tag = true; }
                ]; }
                { name = "synology.nas.serviceTable"; oid = "SYNOLOGY-SERVICES-MIB::serviceTable"; inherit_tags = [ "host" ]; }
              ];
            })
          ];
          vsphere = lib.mkIf cfg.telegraf.inputs.api.vendors.vmware.vsphere.enable [
            {
              interval = "60s";
              name_prefix = "vmware.";
              vcenters = cfg.telegraf.inputs.api.vendors.vmware.vsphere.sdk.endpoints;
              username = "${cfg.telegraf.inputs.api.vendors.vmware.vsphere.sdk.username}";
              password = "${cfg.telegraf.inputs.api.vendors.vmware.vsphere.sdk.password}";
              insecure_skip_verify = true;
              force_discover_on_init = true;
              host_metric_include = [
                "cpu.corecount.contention.average"
                "cpu.usage.average"
                "cpu.reservedCapacity.average"
                "cpu.usagemhz.minimum"
                "cpu.usagemhz.maximum"
                "cpu.usage.minimum"
                "cpu.usage.maximum"
                "cpu.capacity.provisioned.average"
                "cpu.capacity.usage.average"
                "cpu.capacity.demand.average"
                "cpu.capacity.contention.average"
                "cpu.corecount.provisioned.average"
                "cpu.corecount.usage.average"
                "cpu.usagemhz.average"
                "disk.throughput.contention.average"
                "disk.throughput.usage.average"
                "mem.decompressionRate.average"
                "mem.granted.average"
                "mem.active.average"
                "mem.shared.average"
                "mem.zero.average"
                "mem.swapused.average"
                "mem.vmmemctl.average"
                "mem.compressed.average"
                "mem.compressionRate.average"
                "mem.reservedCapacity.average"
                "mem.capacity.provisioned.average"
                "mem.capacity.usable.average"
                "mem.capacity.usage.average"
                "mem.capacity.entitlement.average"
                "mem.capacity.contention.average"
                "mem.usage.minimum"
                "mem.overhead.minimum"
                "mem.consumed.minimum"
                "mem.granted.minimum"
                "mem.active.minimum"
                "mem.shared.minimum"
                "mem.zero.minimum"
                "mem.swapused.minimum"
                "mem.consumed.average"
                "mem.usage.maximum"
                "mem.overhead.maximum"
                "mem.consumed.maximum"
                "mem.granted.maximum"
                "mem.overhead.average"
                "mem.shared.maximum"
                "mem.zero.maximum"
                "mem.swapused.maximum"
                "mem.vmmemctl.maximum"
                "mem.usage.average"
                "mem.active.maximum"
                "mem.vmmemctl.minimum"
                "net.throughput.contention.summation"
                "net.throughput.usage.average"
                "net.throughput.usable.average"
                "net.throughput.provisioned.average"
                "power.power.average"
                "power.powerCap.average"
                "power.energy.summation"
                "vmop.numShutdownGuest.latest"
                "vmop.numPoweroff.latest"
                "vmop.numSuspend.latest"
                "vmop.numReset.latest"
                "vmop.numRebootGuest.latest"
                "vmop.numStandbyGuest.latest"
                "vmop.numPoweron.latest"
                "vmop.numCreate.latest"
                "vmop.numDestroy.latest"
                "vmop.numRegister.latest"
                "vmop.numUnregister.latest"
                "vmop.numReconfigure.latest"
                "vmop.numClone.latest"
                "vmop.numDeploy.latest"
                "vmop.numChangeHost.latest"
                "vmop.numChangeDS.latest"
                "vmop.numChangeHostDS.latest"
                "vmop.numVMotion.latest"
                "vmop.numSVMotion.latest"
                "vmop.numXVMotion.latest"
              ];
              vm_metric_include = [
                "cpu.demandEntitlementRatio.latest"
                "cpu.usage.average"
                "cpu.ready.summation"
                "cpu.run.summation"
                "cpu.system.summation"
                "cpu.swapwait.summation"
                "cpu.costop.summation"
                "cpu.demand.average"
                "cpu.readiness.average"
                "cpu.maxlimited.summation"
                "cpu.wait.summation"
                "cpu.usagemhz.average"
                "cpu.latency.average"
                "cpu.used.summation"
                "cpu.overlap.summation"
                "cpu.idle.summation"
                "cpu.entitlement.latest"
                "datastore.maxTotalLatency.latest"
                "disk.usage.average"
                "disk.read.average"
                "disk.write.average"
                "disk.maxTotalLatency.latest"
                "mem.llSwapUsed.average"
                "mem.swapin.average"
                "mem.vmmemctltarget.average"
                "mem.activewrite.average"
                "mem.overhead.average"
                "mem.vmmemctl.average"
                "mem.zero.average"
                "mem.swapoutRate.average"
                "mem.active.average"
                "mem.llSwapOutRate.average"
                "mem.swapout.average"
                "mem.llSwapInRate.average"
                "mem.swapinRate.average"
                "mem.granted.average"
                "mem.latency.average"
                "mem.overheadMax.average"
                "mem.swapped.average"
                "mem.compressionRate.average"
                "mem.swaptarget.average"
                "mem.shared.average"
                "mem.zipSaved.latest"
                "mem.overheadTouched.average"
                "mem.zipped.latest"
                "mem.consumed.average"
                "mem.entitlement.average"
                "mem.usage.average"
                "mem.decompressionRate.average"
                "mem.compressed.average"
                "net.multicastRx.summation"
                "net.transmitted.average"
                "net.received.average"
                "net.usage.average"
                "net.broadcastTx.summation"
                "net.broadcastRx.summation"
                "net.packetsRx.summation"
                "net.pnicBytesRx.average"
                "net.multicastTx.summation"
                "net.bytesTx.average"
                "net.bytesRx.average"
                "net.droppedRx.summation"
                "net.pnicBytesTx.average"
                "net.droppedTx.summation"
                "net.packetsTx.summation"
                "power.power.average"
                "power.energy.summation"
                "rescpu.runpk1.latest"
                "rescpu.runpk15.latest"
                "rescpu.maxLimited5.latest"
                "rescpu.actpk5.latest"
                "rescpu.samplePeriod.latest"
                "rescpu.runav1.latest"
                "rescpu.runav15.latest"
                "rescpu.sampleCount.latest"
                "rescpu.actpk1.latest"
                "rescpu.runpk5.latest"
                "rescpu.runav5.latest"
                "rescpu.actav15.latest"
                "rescpu.actav1.latest"
                "rescpu.actpk15.latest"
                "rescpu.actav5.latest"
                "rescpu.maxLimited1.latest"
                "rescpu.maxLimited15.latest"
                "sys.osUptime.latest"
                "sys.uptime.latest"
                "sys.heartbeat.latest"
                "virtualDisk.write.average"
                "virtualDisk.read.average"
              ];
              datastore_metric_exclude = [ "*" ];
              cluster_metric_exclude = [ "*" ];
              datacenter_metric_exclude = [ "*" ];
              collect_concurrency = 4;
              discover_concurrency = 4;
            }
            {
              interval = "300s";
              name_prefix = "vmware.";
              vcenters = cfg.telegraf.inputs.api.vendors.vmware.vsphere.sdk.endpoints;
              username = "${cfg.telegraf.inputs.api.vendors.vmware.vsphere.sdk.username}";
              password = "${cfg.telegraf.inputs.api.vendors.vmware.vsphere.sdk.password}";
              insecure_skip_verify = true;
              force_discover_on_init = true;
              datastore_metric_include = [
                "datastore.numberReadAveraged.average"
                "datastore.throughput.contention.average"
                "datastore.throughput.usage.average"
                "datastore.write.average"
                "datastore.read.average"
                "datastore.numberWriteAveraged.average"
                "disk.used.latest"
                "disk.provisioned.latest"
                "disk.capacity.latest"
                "disk.capacity.contention.average"
                "disk.capacity.provisioned.average"
                "disk.capacity.usage.average"
              ];
              cluster_metric_include = [
                "cpu.corecount.contention.average"
                "cpu.usage.average"
                "cpu.reservedCapacity.average"
                "cpu.usagemhz.minimum"
                "cpu.usagemhz.maximum"
                "cpu.usage.minimum"
                "cpu.usage.maximum"
                "cpu.capacity.provisioned.average"
                "cpu.capacity.usage.average"
                "cpu.capacity.demand.average"
                "cpu.capacity.contention.average"
                "cpu.corecount.provisioned.average"
                "cpu.corecount.usage.average"
                "cpu.usagemhz.average"
                "disk.throughput.contention.average"
                "disk.throughput.usage.average"
                "mem.decompressionRate.average"
                "mem.granted.average"
                "mem.active.average"
                "mem.shared.average"
                "mem.zero.average"
                "mem.swapused.average"
                "mem.vmmemctl.average"
                "mem.compressed.average"
                "mem.compressionRate.average"
                "mem.reservedCapacity.average"
                "mem.capacity.provisioned.average"
                "mem.capacity.usable.average"
                "mem.capacity.usage.average"
                "mem.capacity.entitlement.average"
                "mem.capacity.contention.average"
                "mem.usage.minimum"
                "mem.overhead.minimum"
                "mem.consumed.minimum"
                "mem.granted.minimum"
                "mem.active.minimum"
                "mem.shared.minimum"
                "mem.zero.minimum"
                "mem.swapused.minimum"
                "mem.consumed.average"
                "mem.usage.maximum"
                "mem.overhead.maximum"
                "mem.consumed.maximum"
                "mem.granted.maximum"
                "mem.overhead.average"
                "mem.shared.maximum"
                "mem.zero.maximum"
                "mem.swapused.maximum"
                "mem.vmmemctl.maximum"
                "mem.usage.average"
                "mem.active.maximum"
                "mem.vmmemctl.minimum"
                "net.throughput.contention.summation"
                "net.throughput.usage.average"
                "net.throughput.usable.average"
                "net.throughput.provisioned.average"
                "power.power.average"
                "power.powerCap.average"
                "power.energy.summation"
                "vmop.numShutdownGuest.latest"
                "vmop.numPoweroff.latest"
                "vmop.numSuspend.latest"
                "vmop.numReset.latest"
                "vmop.numRebootGuest.latest"
                "vmop.numStandbyGuest.latest"
                "vmop.numPoweron.latest"
                "vmop.numCreate.latest"
                "vmop.numDestroy.latest"
                "vmop.numRegister.latest"
                "vmop.numUnregister.latest"
                "vmop.numReconfigure.latest"
                "vmop.numClone.latest"
                "vmop.numDeploy.latest"
                "vmop.numChangeHost.latest"
                "vmop.numChangeDS.latest"
                "vmop.numChangeHostDS.latest"
                "vmop.numVMotion.latest"
                "vmop.numSVMotion.latest"
                "vmop.numXVMotion.latest"
              ];
              host_metric_exclude = [ "*" ];
              vm_metric_exclude = [ "*" ];
              collect_concurrency = 4;
              discover_concurrency = 4;
            }
          ];

        };
        outputs = cfg.telegraf.outputs;
      };
    };

    virtualisation.oci-containers = {
      containers = {
        unifi-poller = lib.mkIf cfg.unifi-poller.enable {
          image = "ghcr.io/unpoller/unpoller:latest-arm64v8";
          autoStart = true;
          environment = {
            UP_INFLUXDB_URL = "${cfg.unifi-poller.output.influxdb_v2.url}";
            UP_INFLUXDB_ORG = "${cfg.unifi-poller.output.influxdb_v2.organization}";
            UP_INFLUXDB_BUCKET = "${cfg.unifi-poller.output.influxdb_v2.bucket}";
            UP_INFLUXDB_AUTH_TOKEN = "${cfg.unifi-poller.output.influxdb_v2.token}";
            UP_UNIFI_DEFAULT_USER = "${cfg.unifi-poller.input.unifi-controller.user}";
            UP_UNIFI_DEFAULT_PASS = "${cfg.unifi-poller.input.unifi-controller.pass}";
            UP_UNIFI_DEFAULT_URL = "${cfg.unifi-poller.input.unifi-controller.url}";
            UP_POLLER_DEBUG = "true";
          };
        };
      };
    };

  };

}
