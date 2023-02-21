{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    telegraf = {
      enable = mkEnableOption ''
        Whether to enable the telegraf monitoring agent.
      '';
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
          mobility-gateway = {
            enable = mkEnableOption ''
              Whether to enable the Aruba Mobility Gateway monitoring via SNMP.
            '';
            hostMonitoring = {
              agents = mkOption {
                type = types.listOf types.str;
                default = [];
                example = literalExpression ''
                  [ "udp://192.168.178.1:161" ]
                '';
                description = lib.mdDoc ''
                  List of agents (explicit hosts) to monitor. Please look at the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for further information about formatting.
                '';
              };
            };
            apMonitoring = {
              enable = mkEnableOption ''
                Whether to enable the Aruba Mobility Gateway access point monitoring via SNMP.
              '';
              agents = mkOption {
                type = types.listOf types.str;
                default = [];
                example = literalExpression ''
                  [ "udp://192.168.178.1:161" ]
                '';
                description = lib.mdDoc ''
                  List of agents to monitor the access point. Please provide here the VRRP IP address, if you have configured redundancy. Otherwise you can provide the same agent IP address as under the `hostMonitoring` option.
                  Please look at the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for further information about formatting.
                '';
              };
            };
            snmpRFCv3 = {
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
          };
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
            snmpRFCv2 = {
              community = {
                name = mkOption {
                  type = types.str;
                  default = "public";
                  example = "public";
                  description = lib.mdDoc ''
                    Community string used by SNMPv2 to authenticate at the agent.
                  '';
                };
              };
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
          snmpRFCv3 = {
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
                default = "7ecLyz7SWeDmzhZtgXFPRBuFofzpdhW0eXIt3yIYfrSpWGMJrEqfZws8OKPAQiJW";
                example = "kyM3JvtVY1BNodkxX9ac9MWbuyZPrBtsbL2phRemqqS3j7KL7nk93FJvM8WPTBJt";
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
                default = "f3KZGL7C3s1J59JJ0AtI8p6A0PqfzJgdVOzixgyMil9UfCjZPSDBPIW3JoD14djr";
                example = "qTovtQJcmFGcafQDrUS888TkzoaNPkEkWSG2WNBwtba09C9O8zSobcOHhvaN4siL";
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
        };
        schneider-electric = {
          apc = {
            enable = mkEnableOption ''
              Whether to enable the Schneider Electric APC monitoring via SNMP.
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
            snmpRFCv3 = {
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
                  default = "55efh4eQ6cEhlkdMy0ilnKRnaE9wlQbsZZu1ykZLbiqUmMfmEZjsA5ZRKr8FwfF0";
                  example = "RwYnBVLtIMHWYMhUzkv9UzIES6bKuarQ60cW6MORhOJwKuTaaxjXsMndzuSgV5Nr";
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
                  default = "9X3LPmK6AhFeB6YkkZPxq3LEksXBhXu41RgrygPjyYDuV4kARrYwOMpCiii6O79l";
                  example = "yuwGPtf1Ky67OnqfFAw56XUae9MnxOqQSFNER9seMbyJz4qb4vL9sSWARJ2bu1Jt";
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
          };
        };
        sonicwall = {
          enable = mkEnableOption ''
            Whether to enable the SonicWall monitoring via SNMP.
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
          snmpRFCv3 = {
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
                default = "7ecLyz7SWeDmzhZtgXFPRBuFofzpdhW0eXIt3yIYfrSpWGMJrEqfZws8OKPAQiJW";
                example = "kyM3JvtVY1BNodkxX9ac9MWbuyZPrBtsbL2phRemqqS3j7KL7nk93FJvM8WPTBJt";
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
                default = "f3KZGL7C3s1J59JJ0AtI8p6A0PqfzJgdVOzixgyMil9UfCjZPSDBPIW3JoD14djr";
                example = "qTovtQJcmFGcafQDrUS888TkzoaNPkEkWSG2WNBwtba09C9O8zSobcOHhvaN4siL";
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
            snmpRFCv3 = {
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
                  default = "7ecLyz7SWeDmzhZtgXFPRBuFofzpdhW0eXIt3yIYfrSpWGMJrEqfZws8OKPAQiJW";
                  example = "kyM3JvtVY1BNodkxX9ac9MWbuyZPrBtsbL2phRemqqS3j7KL7nk93FJvM8WPTBJt";
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
                  default = "f3KZGL7C3s1J59JJ0AtI8p6A0PqfzJgdVOzixgyMil9UfCjZPSDBPIW3JoD14djr";
                  example = "qTovtQJcmFGcafQDrUS888TkzoaNPkEkWSG2WNBwtba09C9O8zSobcOHhvaN4siL";
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
          };
          xg = {
            enable = mkEnableOption ''
              Whether to enable the Sophos XG(S) monitoring via SNMP.
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
            snmpRFCv3 = {
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
                  default = "7ecLyz7SWeDmzhZtgXFPRBuFofzpdhW0eXIt3yIYfrSpWGMJrEqfZws8OKPAQiJW";
                  example = "kyM3JvtVY1BNodkxX9ac9MWbuyZPrBtsbL2phRemqqS3j7KL7nk93FJvM8WPTBJt";
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
                  default = "f3KZGL7C3s1J59JJ0AtI8p6A0PqfzJgdVOzixgyMil9UfCjZPSDBPIW3JoD14djr";
                  example = "qTovtQJcmFGcafQDrUS888TkzoaNPkEkWSG2WNBwtba09C9O8zSobcOHhvaN4siL";
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
          };
        };
        synology = {
          nas = {
            enable = mkEnableOption ''
              Whether to enable the Synology NAS monitoring via SNMP.
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
            snmpRFCv3 = {
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
                  default = "7ecLyz7SWeDmzhZtgXFPRBuFofzpdhW0eXIt3yIYfrSpWGMJrEqfZws8OKPAQiJW";
                  example = "kyM3JvtVY1BNodkxX9ac9MWbuyZPrBtsbL2phRemqqS3j7KL7nk93FJvM8WPTBJt";
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
                  default = "f3KZGL7C3s1J59JJ0AtI8p6A0PqfzJgdVOzixgyMil9UfCjZPSDBPIW3JoD14djr";
                  example = "qTovtQJcmFGcafQDrUS888TkzoaNPkEkWSG2WNBwtba09C9O8zSobcOHhvaN4siL";
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
          snmp = [
            (lib.mkIf cfg.telegraf.devices.aruba.mobility-gateway.enable {
              name = "aruba.mobility-gateway.host";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.aruba.mobility-gateway.hostMonitoring.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.privacy.password}";
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
                  name = "hostname";
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
                  name = "aruba.mobility-gateway.host.memory";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtMemoryTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "aruba.mobility-gateway.host.processor";
                  oid = "WLSX-SYSTEMEXT-MIB::wlsxSysExtProcessorTable";
                  inherit_tags = [ "hostname" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.aruba.mobility-gateway.apMonitoring.enable {
              name = "aruba.mobility-gateway.ap";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.aruba.mobility-gateway.apMonitoring.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.aruba.mobility-gateway.snmpRFCv3.privacy.password}";
              retries = 5;
              table = [
                {
                  name = "aruba.mobility-gateway.ap.info";
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
            (lib.mkIf cfg.telegraf.devices.aruba.switch.enable {
              name = "aruba.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.aruba.switch.agents;
              timeout = "20s";
              version = 2;
              community = "${cfg.telegraf.devices.aruba.switch.snmpRFCv2.community.name}";
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
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.qnap.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.qnap.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.qnap.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.qnap.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.qnap.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.qnap.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.qnap.snmpRFCv3.privacy.password}";
              retries = 5;
              field = [
                {
                  name = "hostname";
                  oid = "SNMPv2-MIB::sysName.0";
                  is_tag = true;
                }
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
                  name = "qnap.disk";
                  oid = "QTS-MIB::diskTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "qnap.interfaces";
                  oid = "NAS-MIB::systemIfTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "qnap.lun";
                  oid = "QTS-MIB::lunTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "qnap.raid";
                  oid = "QTS-MIB::raidTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "qnap.system_fan";
                  oid = "QTS-MIB::systemFanTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "qnap.target";
                  oid = "QTS-MIB::targeTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "qnap.volume";
                  oid = "QTS-MIB::volumeTable";
                  inherit_tags = [ "hostname" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.schneider-electric.apc.enable {
              name = "schneider-electric.apc";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.schneider-electric.apc.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.schneider-electric.apc.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.schneider-electric.apc.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.schneider-electric.apc.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.schneider-electric.apc.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.schneider-electric.apc.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.schneider-electric.apc.snmpRFCv3.privacy.password}";
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
                  name = "hostname";
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
                  name = "schneider-electric.apc.configDevice";
                  oid = "PowerNet-MIB::upsBasicConfigDeviceTable";
                  inherit_tags = [ "hostname" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.sonicwall.enable {
              name = "sonicwall";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.sonicwall.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.sonicwall.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.sonicwall.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.sonicwall.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.sonicwall.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.sonicwall.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.sonicwall.snmpRFCv3.privacy.password}";
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
                  name = "model";
                  oid = "SNWL-COMMON-MIB::snwlSysModel.0";
                }
                {
                  name = "uptime";
                  oid = "SNMPv2-MIB::sysUpTime.0";
                }
              ];
            table = [
                {
                  name = "sonicwall.interfaces";
                  oid = "IF-MIB::ifTable";
                }
                {
                  name = "sonicwall.ip_addresses";
                  oid = "IP-MIB::ipAddrTable";
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.sophos.sg.enable {
              name = "sophos.sg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.sophos.sg.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.sophos.sg.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.sophos.sg.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.sophos.sg.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.sophos.sg.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.sophos.sg.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.sophos.sg.snmpRFCv3.privacy.password}";
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
            (lib.mkIf cfg.telegraf.devices.sophos.xg.enable {
              name = "sophos.xg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.sophos.xg.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.sophos.xg.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.sophos.xg.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.sophos.xg.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.sophos.xg.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.sophos.xg.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.sophos.xg.snmpRFCv3.privacy.password}";
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
                  name = "hostname";
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
                  name = "sophos.xg.interfaces";
                  oid = "IF-MIB::ifTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "sophos.xg.ipAddresses";
                  oid = "IP-MIB::ipAddrTable";
                  inherit_tags = [ "hostname" ];
                }
              ];
            })
            (lib.mkIf cfg.telegraf.devices.synology.nas.enable {
              name = "synology.nas";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.telegraf.devices.synology.nas.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.telegraf.devices.synology.nas.snmpRFCv3.security.level}";
              sec_name = "${cfg.telegraf.devices.synology.nas.snmpRFCv3.security.username}";
              auth_protocol = "${cfg.telegraf.devices.synology.nas.snmpRFCv3.authentication.protocol}";
              auth_password = "${cfg.telegraf.devices.synology.nas.snmpRFCv3.authentication.password}";
              priv_protocol = "${cfg.telegraf.devices.synology.nas.snmpRFCv3.privacy.protocol}";
              priv_password = "${cfg.telegraf.devices.synology.nas.snmpRFCv3.privacy.password}";
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
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "synology.nas.disk";
                  oid = "SYNOLOGY-DISK-MIB::diskTable";
                  inherit_tags = [ "hostname" ];
                }
                {
                  name = "synology.nas.raid";
                  oid = "SYNOLOGY-RAID-MIB::raidTable";
                  inherit_tags = [ "hostname" ];
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
