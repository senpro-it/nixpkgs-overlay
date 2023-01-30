{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    telegraf = {
      config = {
        output = {
          influxdb_v2 = {
            urls = mkOption {
              type = types.listOf types.str;
              default = [];
              example = literalExpression ''
                [ "https://influxdb.example.com" ]
              '';
              description = lib.mdDoc ''
                List of InfluxDB instances where the output should be written to. Please be aware that this module uses InfluxDB v2 for connection to the database.
              '';
            };
            token = mkOption {
              type = types.str;
              example = "PXA06C0lATm3Uf/1wI10/C6MyAXj9KTo3dpcE5s3W4w=";
              description = lib.mdDoc ''
                API token from your InfluxDB instance. Be aware that currently only one output is possible, this will be reworked in the near future.
              '';
            };
            organization = mkOption {
              type = types.str;
              example = "ExampleOrg";
              description = lib.mdDoc ''
                Name of your InfluxDB organization where the destination bucket is located.
              '';
            };
            bucket = mkOption {
              type = types.str;
              example = "Default";
              description = lib.mdDoc ''
                Name of the bucket where your telegraf metrics should be put in.
              '';
            };
          };
        };
      };
      devices = {
        aruba = {
          switch = {
            enable = mkEnableOption ''
              Whether to enable the Aruba switch monitoring via SNMP.
            '';
            agents = mkOption {
              type = types.listOf types.str;
              default = [];
              example = literalExpression ''
                [ "udp://192.168.178.1:161" ]
              '';
              description = lib.mdDoc ''
                List of agents to monitor. Please look at the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for further information about formatting.
              '';
            };
            community = mkOption {
              type = types.str;
              default = "public";
              example = "public";
              description = lib.mdDoc ''
                Community string used SNMPv2c. Actually SNMPv2 and so community string is mandatory.
              '';
            };
          };
        };
        qnap = {
          enable = mkEnableOption ''
            Whether to enable the QNAP monitoring via SNMP.
          '';
          agents = mkOption {
            type = types.listOf types.str;
            default = [];
            example = literalExpression ''
              [ "udp://192.168.178.1:161" ]
            '';
            description = lib.mdDoc ''
              List of agents to monitor. Please look at the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for further information about formatting.
            '';
          };
          community = mkOption {
            type = types.str;
            default = "public";
            example = "public";
            description = lib.mdDoc ''
              Community string used SNMPv2c. Actually SNMPv2 and so community string is mandatory.
            '';
          };
        };
        sophos = {
          sg = {
            enable = mkEnableOption ''
              Whether to enable the Sophos SG (UTM) monitoring via SNMP.
            '';
            agents = mkOption {
              type = types.listOf types.str;
              default = [];
              example = literalExpression ''
                [ "udp://192.168.178.1:161" ]
              '';
              description = lib.mdDoc ''
                List of agents to monitor. Please look at the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for further information about formatting.
              '';
            };
            community = mkOption {
              type = types.str;
              default = "public";
              example = "public";
              description = lib.mdDoc ''
                Community string used SNMPv2c. Actually SNMPv2 and so community string is mandatory.
              '';
            };
          };
        };
      };
    };
  };

  config = {

    services.telegraf = {
      enable = true;
      extraConfig = {
        agent = {
          interval = "60s";
          snmp_translator = "gosmi";
        };
        inputs = {
          snmp = [
            (lib.mkIf cfg.telegraf.devices.aruba.switch.enable {
              name = "aruba.switch";
              path = [ "/srv/snmp/mibs" ];
              agents = cfg.telegraf.devices.aruba.switch.agents;
              timeout = "20s";
              version = 2;
              community = "${cfg.telegraf.devices.aruba.switch.community}";
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
                  name = "hostname";
                  oid = "SNMPv2-MIB::sysName.0";
                }
                {
                  name = "uptime";
                  oid = "SNMPv2-MIB::sysUpTime.0";
                }
              ];
              table = [
                {
                  name = "aruba.switch.interfaces";
                  oid = "IF-MIB::ifTable";
                }
                {
                  name = "aruba.switch.ip_addresses";
                  oid = "IP-MIB::ipAddrTable";
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.qnap.enable {
              name = "qnap";
              path = [ "/srv/snmp/mibs" ];
              agents = cfg.telegraf.devices.qnap.agents;
              timeout = "20s";
              version = 2;
              community = "${cfg.telegraf.devices.qnap.community}";
              retries = 5;
              field = [
                {
                  name = "hostname";
                  oid = "QTS-MIB::hostname.0";
                }
                {
                  name = "cpu_used";
                  oid = "QTS-MIB::systemCPU-Usage.0";
                }
                {
                  name = "cpu_temp";
                  oid = "QTS-MIB::cpuTemperature.0";
                }
                {
                  name = "disk_count";
                  oid = "QTS-MIB::diskCount.0";
                }
                {
                  name = "mem_free";
                  oid = "QTS-MIB::systemFreeMem.0";
                }
                {
                  name = "mem_used";
                  oid = "QTS-MIB::systemUsedMemory.0";
                }
                {
                  name = "mem_total";
                  oid = "QTS-MIB::systemTotalMem.0";
                }
                {
                  name = "raid_count";
                  oid = "QTS-MIB::raidCount.0";
                }
                {
                  name = "system_model";
                  oid = "QTS-MIB::systemModel.0";
                }
                {
                  name = "system_temp";
                  oid = "QTS-MIB::systemTemperature.0";
                }
                {
                  name = "system_power";
                  oid = "QTS-MIB::sysPowerStatus.0";
                }
                {
                  name = "system_uptime";
                  oid = "QTS-MIB::sysUptime.0";
                }
                {
                  name = "serial_number";
                  oid = "QTS-MIB::serialNumber.0";
                }
                {
                  name = "fw_version";
                  oid = "QTS-MIB::firmwareVersion.0";
                }
                {
                  name = "fw_up_available";
                  oid = "QTS-MIB::firmwareUpgradeAvailable.0";
                }
              ];
              table = [
                {
                  name = "qnap.disk";
                  oid = "QTS-MIB::diskTable";
                }
                {
                  name = "qnap.interfaces";
                  oid = "NAS-MIB::systemIfTable";
                }
                {
                  name = "qnap.lun";
                  oid = "QTS-MIB::lunTable";
                }
                {
                  name = "qnap.raid";
                  oid = "QTS-MIB::raidTable";
                }
                {
                  name = "qnap.system_fan";
                  oid = "QTS-MIB::systemFanTable";
                }
                {
                  name = "qnap.target";
                  oid = "QTS-MIB::targeTable";
                }
                {
                  name = "qnap.volume";
                  oid = "QTS-MIB::volumeTable";
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.sophos.sg.enable {
              name = "sophos.sg";
              path = [ "/srv/snmp/mibs" ];
              agents = cfg.telegraf.devices.sophos.sg.agents;
              timeout = "20s";
              version = 2;
              community = "${cfg.telegraf.devices.sophos.sg.community}";
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
                  name = "hostname";
                  oid = "SNMPv2-MIB::sysName.0";
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
                }
                {
                  name = "sophos.sg.interfaces";
                  oid = "IF-MIB::ifTable";
                }
                {
                  name = "sophos.sg.ip_addresses";
                  oid = "IP-MIB::ipAddrTable";
                }
                {
                  name = "sophos.sg.storage";
                  oid = "HOST-RESOURCES-MIB::hrStorageTable";
                }
              ];
            })
          ];
        };
        outputs = {
          influxdb_v2 = {
            urls = cfg.telegraf.config.output.influxdb_v2.urls;
            token = "${cfg.telegraf.config.output.influxdb_v2.token}";
            organization = "${cfg.telegraf.config.output.influxdb_v2.organization}";
            bucket = "${cfg.telegraf.config.output.influxdb_v2.bucket}";
            insecure_skip_verify = true;
          };
        };
      };
    };
  };

}
