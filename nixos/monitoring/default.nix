{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.senpro;

  settingsFormat = pkgs.formats.toml {};

  fritzinfluxdbOptions.inputConfig = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = "${name}";
        example = "FRITZ1";
        description = ''
          Name of the FRITZ!Box (used as measurement tag in InfluxDB).
        '';
      };
      host = mkOption {
        type = types.str;
        example = "192.168.178.1";
        description = ''
          FQDN or IPv4 address of the FRITZ!Box.
        '';
      };
      user = mkOption {
        type = types.str;
        example = "admin";
        description = ''
          User to access the targeted FRITZ!Box via TR-064.
        '';
      };
      pass = mkOption {
        type = types.str;
        example = "your-secure-password";
        description = ''
          Password for the specified FRITZ!Box read-access user.
        '';
      };
    };
  };

  createFritzInfluxDBContainer = opts: name: {
      image = "docker.io/bbricardo/fritzinfluxdb:latest";
      autoStart = true;
      environment = {
        FRITZBOX_HOSTNAME = "${opts.host}";
        FRITZBOX_PORT = "49443";
        FRITZBOX_TLS_ENABLED = "true";
        FRITZBOX_USERNAME = "${opts.user}";
        FRITZBOX_PASSWORD = "${opts.pass}";
        FRITZBOX_BOX_TAG = "${opts.name}";
        INFLUXDB_VERSION = "2";
        INFLUXDB_HOSTNAME = "${cfg.monitoring.fritzinfluxdb.output.influxdb_v2.host}";
        INFLUXDB_PORT = "443";
        INFLUXDB_TLS_ENABLED = "true";
        INFLUXDB_ORGANISATION = "${cfg.monitoring.fritzinfluxdb.output.influxdb_v2.organization}";
        INFLUXDB_BUCKET = "${cfg.monitoring.fritzinfluxdb.output.influxdb_v2.bucket}";
        INFLUXDB_TOKEN = "${cfg.monitoring.fritzinfluxdb.output.influxdb_v2.token}";
        INFLUXDB_MEASUREMENT_NAME = "fritzbox";
      };
    };


  telegrafOptions.agentConfig = mkOption {
    type = types.listOf types.str;
    default = [];
    example = literalExpression ''
      [ "udp://192.168.178.1:161" ]
    '';
    description = ''
      Endpoints which should be monitored. See the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for syntax reference.
    '';
  };

  telegrafOptions.authSNMPv3 = with types; {
    context = {
      name = mkOption {
        type = types.str;
        example = "27652626525562";
        description = ''
          Context name for SNMPv3 to authenticate at the agent.
        '';
      };
    };
    authentication = {
      protocol = mkOption {
        type = types.enum [ "MD5" "SHA" "SHA224" "SHA256" "SHA384" "SHA512" ];
        default = "MD5";
        example = "SHA";
        description = ''
          Authentication protocol used by SNMPv3 to authenticate at the agent.
        '';
      };
      password = mkOption {
        type = types.str;
        default = "yzL9sHgeYf5NJzaeAB73014M7XrY6Aagj8UhrHbePfCfxBa99uLzVrGC8ywhfW97";
        example = "VJQUpLCLGniEDVGK8Q0oPS9Yf0xObE7m8aCDK4FR7Kzzh47MD2ZQy0dVtTkDeKBd";
        description = ''
          Password used by SNMPv3 to authenticate at the agent.
        '';
      };
    };
    privacy = {
      protocol = mkOption {
        type = types.enum [ "DES" "AES" "AES192" "AES192C" "AES256" "AES256C" ];
        default = "MD5";
        example = "SHA";
        description = ''
          Privacy protocol used by SNMPv3 to authenticate at the agent.
        '';
      };
      password = mkOption {
        type = types.str;
          default = "qNMR7yeaIyQ8HKfRCZU8UW5AdKM6P56UALUeYATENOn4dX3nezXELwmLgpuMWKS2";
          example = "GO61HVwspXO514vbzZiV3IwGeBnSZsjHoBaHbJU4JgEaznJ4AdVTy0wzwpzgNffz";
          description = ''
            Password used by SNMPv3 to protect to connectiont to the agent.
          '';
        };
      };
    security = {
      level = mkOption {
        type = types.enum [ "noAuthNoPriv" "authNoPriv" "authPriv" ];
        default = "authPriv";
        example = "authPriv";
        description = ''
          Security level for SNMPv3. Look at the [documentation](https://snmp.com/snmpv3/snmpv3_intro.shtml) for further information.
        '';
      };
      username = mkOption {
        type = types.str;
        default = "monitor";
        example = "monitor";
        description = ''
          Username for SNMPv3. Also known as `Security Name`.
        '';
      };
    };
  };
  telegrafOptions.authSNMPv2 = with types; {
    community = mkOption {
      type = types.str;
      example = "public";
      default = "public"; # This actually is the default...
      description = ''
        "Community" string used to authenticate via SNMPv2
      '';
    };
  };
  telegrafOptions.httpListener = with types; {
    name_override = mkOption {
      type = str;
      default = "webhook";
      description = ''
        Wird als Name der Messung verwendet.
        Bei mehreren HTTP Servern sollten auch verschiedene Namen
        verwendet werden, damit sich diese nicht überschreiben.
        Wichtig: namepass in den Output Optiions!
      '';
    };
    service_address = mkOption {
      type = str;
      default = ":8080";
      example = ":8080";
      description = ''
        HTTP-Addresse auf der gelauscht wird.
        Wird ein Host vor dem Port angegeben (127.0.0.1:8080), dann
        ist dieser HTTP Server nur dort erreichbar.
        Wird dieser allerdings weggelassen, wird auf allen IPs
        gelauscht; das ist der Default.
      '';
    };
    paths = mkOption {
      type = listOf str;
      default = [ "/telegraf" ];
      description = ''
        Liste der HTTP Pfade.
        "/telegraf" ist der Default.
        Nützlich, um mehrere Endpunkte anzulegen, insbesondere wenn path_tag=true ist.
      '';
    };
    path_tag = mkOption {
      type = bool;
      default = false;
      description = ''
        Legt den HTTP-Pfad als Tag an.
      '';
    };
    methods = mkOption {
      type = listOf str;
      default = ["POST"];
      description = ''
        Definiert die HTTP Methoden, die akzeptiert werden.
        POST ist der Standart, PUT ist relativ neu (http/1.1)
        und manche besonderen Endpunkte benutzen vielleicht obskure Methoden.
      '';
    };
    basic_username = mkOption {
      type = str;
      default = "";
      example = "bobderbaumeister";
      description = ''
        Kann optional verwendet werden, um einen Benutzernamen festzulegen.
        Nicht alle Hook-Sender können damit umgehen.
        Es ist möglich, mit http://user:password@host.tld/path diese Creds
        einfach zu übergeben. Aber, wie gesagt, nicht alle Sender können damit umgehen.
      '';
    };
    basic_password = mkOption {
      type = str;
      default = "";
      example = "#K0nnenWirDasSchaffen?!";
      description = ''
        Ein Passwort zum Username.
        Diese werden meist zusammengenommen und als Base64 encodiert.
        Die beiden obigen Beispiele ergeben als Teil der HTTP-Abfrage:

        > echo "Authorization: $(echo "bobderbaumeister:#K0nnenWirDasSchaffen?!" | base64)"
        Authorization: Ym9iZGVyYmF1bWVpc3RlcjojSzBubmVuV2lyRGFzU2NoYWZmZW4/IQo=
      '';
    };
    data_format = mkOption {
      type = str;
      default = "json_v2";
      description = ''
        Bestimmt, welches Datenformat erwartet wird.
        Mögliche Werte: https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
        Vorsicht, je nach Option müssen zusätzliche Optionen hinzugefügt werden!
      '';
    };
    json_v2 = mkOption {
      type = anything;
      default = {};
      description = ''
        JSONv2 options
        Ref: https://github.com/influxdata/telegraf/tree/master/plugins/parsers/json_v2
      '';
    };
    # NOTE(KI): Folgende Optionen sind nicht implementiert;
    # http_headers     : Ausgelassen, kaum benutzt.
    # http_header_tags : Definiert header als tags, kommt nur in Nieche vor.
    # read_timeout     : Vorerst irrelevant. {type = types.str; default = "20s";}
    # write_timeout    : Gleiche wie oben
    # max_body_size    : Standart ist 500MB, sollte dicke reichen.
    # data_source      : Standart ist "body" - gibt kaum Hooks für die "query" gut währe.
    # tls_*            : Theoretisch für SSL/TLS - aber hier muss eine acme.sh Anbindung her.
  };

  # Kentix-specific
  kentixFuncs = {
    ##
    # Returns a list of generated oid/name pairs.
    #
    # @param name:    Name of the sensor prefix
    # @param num:     Amount of sensors to generate
    # @param ext:     Specify object to merge with the generated one
    # @return         A list (aka. array) of oid-name pairs.
    #
    # Note: If you need 0-prefixing, make it part of the name!
    ##
    genSensorListExt = name: num: obj: map (n: {
      oid = "KAM-PRO::${name}${builtins.toString (n + 1)}.0";
      name = "${name}${builtins.toString (n + 1)}";
    } // obj) (builtins.genList (x: x) num);
    ## Same as above, but does not take an additional object.
    genSensorList = name: num: (kentixFuncs.genSensorListExt name num {});

    ## Generate tagged Sensors
    mkMultisensor = num: kentixFuncs.genSensorListExt "sensorname0" num { is_tag = true; };
    ## Generate temperatures
    mkTemperature = num: kentixFuncs.genSensorList "temperature0" num;
    # Generate humidity
    mkHumidity = num: kentixFuncs.genSensorList "humidity0" num;
    # Generate dewpoint
    mkDewpoint = num: kentixFuncs.genSensorList "dewpoint0" num;
    ## Generate alarm pairs
    mkAlarm = num: kentixFuncs.genSensorList "alarm" num;
    ## Generate CO2 pairs
    mkCo2 = num: kentixFuncs.genSensorList "co0" num;
    ## Generate Motion
    mkMotion = num: kentixFuncs.genSensorList "motion0" num;
    # Generate pairs for Digital IN 1
    mkDigiIn1 = num: kentixFuncs.genSensorList "digitalin10" num;
    # Generate pairs for Digital IN 2
    mkDigiIn2 = num: kentixFuncs.genSensorList "digitalin20" num;
    # Generate pairs for Digital OUT 2
    mkDigiOut2 = num: kentixFuncs.genSensorList "digitalout20" num;
    ## Generate Initialization error pairs
    mkInitErrors = num: kentixFuncs.genSensorList "comError0" num;
    # WIP: Force a table.
    /*
    mkSensorTable' = g: [{
      name_override = "kentix.sensors.group${g}.sensorname";
      oid = "KAM-PRO::sensorname${g}";
      is_tag = true;
    }] ++ (map(key: {
      name_override = "kentix.sensors.group${g}.${key}";
      oid = "KAM-PRO::${key}${g}";
    }) [
      "temperature", "humidity", "dewpoint", 
      "co2", "motion", 
      "digitalin1", "digitalin2", 
      "digitalout2",
      "comError"
    ]);
    mkSensorTable groups: map(g: (mkSensorTable' g) groups);
    // i.e. mkSensorTable ["01", "02"]
    */
  };

in {

  options.senpro = {
    monitoring = {
      fritzinfluxdb = {
        enable = mkEnableOption ''
          Whether to enable fritzinfluxdb (FRITZ!Box monitoring agent).
        '';
        inputs = mkOption {
          default = {};
          type = with types; attrsOf (submodule fritzinfluxdbOptions.inputConfig);
          example = literalExpression ''
            {
              FRITZ1 = {
                host = "192.168.178.1";
                user = "fritz";
                pass = "your-secure-password";
              };
            }
          '';
          description = ''
            Per-host configuration for the FRITZ!Box devices which should be monitored.
          '';
        };
        output = {
          influxdb_v2 = {
            host = mkOption {
              type = types.str;
              example = "influxdb.example.com";
              description = ''
                FQDN of the targeted InfluxDB instance. Protocol is hardcoded to SSL over 443.
              '';
            };
            token = mkOption {
              type = types.str;
              example = "your-influxdb-token";
              description = ''
                Token for the the targeted InfluxDB instance.
              '';
            };
            organization = mkOption {
              type = types.str;
              example = "your-influxdb-org";
              description = ''
                InfluxDB organization where the targeted bucket resides.
              '';
            };
            bucket = mkOption {
              type = types.str;
              default = "avm";
              example = "your-influxdb-bucket";
              description = ''
                InfluxDB bucket where the output should be delivered to.
              '';
            };
          };
        };
      };
      telegraf = {
        enable = mkEnableOption ''
          Whether to enable the telegraf monitoring agent.
        '';
        outputs = mkOption {
          default = {};
          description = "Output configuration for telegraf";
          type = settingsFormat.type;
          example = {
            influxdb_v2 = {
              urls = [ "https://influxdb.example.com/" ];
              token = "your-influxdb-token";
              organization = "ExampleOrg";
              bucket = "ExampleBucket";
              namepass = [ "sophos" ];
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
                    Whether to enable the Sophos Central monitoring via API.
                  '';
                  client = {
                    id = mkOption {
                      type = types.str;
                      example = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                      description = ''
                        Client ID for the Sophos Central API (Tenant).
                      '';
                    };
                    secret = mkOption {
                      type = types.str;
                      example = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
                      description = ''
                        Client Secret for the Sophos Central API (Tenant).
                      '';
                    };
                  };
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
                      description = ''
                        Username of the login user for vSphere.
                      '';
                    };
                    password = mkOption {
                      type = types.str;
                      example = "C8TK9UHEKLSv7BcJPKpEu5ij8de3HEHa";
                      description = ''
                        Password of the login user for vSphere.
                      '';
                    };
                    endpoints = mkOption {
                      type = types.listOf types.str;
                      default = [];
                      example = literalExpression ''
                        [ "https://vcenter.local/sdk" ]
                      '';
                      description = ''
                        vSphere instances which should be monitored. Note the `/sdk` at the end, which is essentially to connect to the right endpoint.
                      '';
                    };
                  };
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
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
                switch = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the Aruba switch monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
                  };
                  credentials = telegrafOptions.authSNMPv2;
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
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
              };
              fortinet = {
                firewall = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the Fortinet firewall monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
                  };
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
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
              };
              kentix = {
                accessmanager = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the Kentix AccessManager monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
                sensors = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the Kentix Sensor monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
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
                  credentials = telegrafOptions.authSNMPv2;
                };
              };
              lancom = {
                router = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the LANCOM router monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
              };
              lenovo = {
                storage = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the Lenovo storage monitoring via SNMP.
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
              reddoxx = {
                endpoints = {
                  self = {
                    enable = mkEnableOption ''
                      Whether to enable REDDOXX monitoring via SNMP.
                    '';
                    agents = telegrafOptions.agentConfig;
                  };
                };
                credentials = telegrafOptions.authSNMPv3;
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
                    accessPoints = {
                      enable = mkEnableOption ''
                        Whether to enable the SonicWall AP monitoring (through Firewall) via SNMP.
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
                dsm = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the Synology DSM monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
              };
              vmware = {
                esxi = {
                  endpoints = {
                    self = {
                      enable = mkEnableOption ''
                        Whether to enable the VMware ESXi monitoring via SNMP.
                      '';
                      agents = telegrafOptions.agentConfig;
                    };
                  };
                  credentials = telegrafOptions.authSNMPv3;
                };
              };
              zyxel = {
                switch = {
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
              };
            };
          };

          ## Options: Ping
          ping = {
            enable = mkEnableOption ''
              Whether to enable Ping.
            '';
            #urls = [ "example.org" ];
            urls = mkOption {
              type = types.listOf types.str;
              default = [];
              example = literalExpression ''
                [ "192.168.0.1" ]
              '';
              description = ''
                Hosts to be pinged
              '';
            };
            # count = 1 types.str (ping -n)
            # ping_interval = 1.0 types.str (sec)
            # timeout = 1.0 (sec)
            # deadline = 10 (sec)
            # interface = "" types.str
            # percentiles = [50, 95, 99] list (if method == "native")
            # ipv6 = false types.bool
            # size = 56 (ICMP size)
          };

          ## Options: Local Raspberry Pi
          local_pi = {
            enable = mkEnableOption ''
                Monitor the local Raspberry Pi monitoring agent as well.
            '';
            name_override = mkOption {
              type = types.str;
              default = "local_pi";
              example = literalExpression ''
                "linux" or "unix"
              '';
              description = mkDoc ''
                Changes the name_override value being used.
                Especially useful to re-use this option set for other Linux
                instances that are not Raspberry Pi Monitoring Agents.
              '';
            };
            stats = {
              cpu = {
                enable = mkEnableOption ''
                    Monitor the Pi's CPU?
                '';
              };
              disk = {
                enable = mkEnableOption ''
                    Monitor the Pi's internal storage?
                '';
              };
              mem = {
                enable = mkEnableOption ''
                    Monitor the Pi's RAM and SWAP?
                '';
              };
              kernel = {
                enable = mkEnableOption ''
                    Monitor the Pi's Linux Kernel information?
                '';
              };
              processes = {
                enable = mkEnableOption ''
                    Monitor the Pi's running processes?
                '';
              };
              system = {
                enable = mkEnableOption ''
                    Monitor the Pi's system information?
                '';
              };
            };
          };

          webhook = {
            enable = mkEnableOption "Use Webhooks?";
            endpoints = mkOption {
              type = types.listOf (types.submodule {
                options = telegrafOptions.httpListener;
              });
              default = [];
              example = literalExpression ''
                senpro-it.monitoring.telegraf.inputs.webhook.endpoints = [
                  {
                    name_override = "odd_thing_without_snmp";
                    service_address = ":42096";
                    paths = ["/thing-a", "/thing-b"];
                    path_tags = true;
                  }
                  {
                    name_override = "xml_example";
                    service_address = ":9999";
                    paths = ["/"];
                    format = "xml";
                  }
                  {
                    name_override = "json_example";
                    service_address = ":42024";
                    paths = ["/"];
                    format = "json_v2";
                    json_v2 = [
                      // GJSON Path: https://github.com/tidwall/gjson?tab=readme-ov-file#get-a-value
                      // Uns interessiert hier nur die Syntax der .Get() Methode.

                      // Name der Messung:
                      measurement_name_gjson = "event_type";
                      // Name des Schlüssels mit Zeitstempel:
                      timestamp_path = "time_at";
                      // Zeitstempel Format:
                      // ref: 
                      timestamp_format = "";
                      // Zeitzone:
                      // ref: 
                      timestamp_timezone = "";
                      // Tags:
                      tag = [
                        {
                          // Pfad zu einem Tag der hinzugefügt werden soll.
                          path = "keyfob_owner";
                        }
                      ];
                      // Felder:
                      // Diese Angabe beschreibt ein einzelnes Feld
                      // z.B.: { "foo": "bar" }
                      field = [
                        {
                          path = "foo";
                          // Optional?:
                          optional = false;
                          // Umbenennen? Weglassen wenn nicht benötigt!:
                          rename = "";
                          // Typ:
                          type = "string";
                        }
                      ];
                      // Objekt: Eine andere Weiße zur Notation von Informationen.
                      // Der einfachhalber zu bevorzugen, aber weniger Robust
                      // in der Validierung!
                      // Außerdem für Unterobjekte gedacht. Bei Root-Objekten
                      // wird diese Anweisung nicht benötigt.
                      // Beispiel: {"time": "...", "data": { ... }}
                      // "path" währe hier also "data", weil hier die eigentlichen
                      // Informationen liegen.
                      object = [
                        // Bestimmen des Pfades zum eigentlichen Objekt:
                        path = "actual_event_data";
                        timestamp_key = "event_at";
                        timestamp_format = "";
                        timestamp_timezone = "";
                        tags = ["keyfob_owner"];
                        // Whitelist-System:
                        included_keys = ["event_kind", "door_name"];
                        // Oder Blacklist-System:
                        excluded_keys = ["kentix_version"];
                        // Auch hier können Tag und Field verwendet werden...
                        //tag = [ ... ];
                        //field = [ ... ];
                        // Spezifisches Umbenennen:
                        renames = {
                          // <von Key> = "<zu Key>";
                          keyfob_id = "schlüssel_ident";
                        };
                        // Spezifische Typen-Information
                        fields = {
                          // <key> = "<typ>";
                          keyfob_id = "int";
                        };
                      ];
                    ];
                  }
                ]
              '';
            };
          };
        };
      };

      svci = {
        enable = mkEnableOption ''
          Whether to enable SVCi (Spectrum Virtualize Insights).
        '';
        input = {
          svc = {
            host = mkOption {
              type = types.str;
              example = "192.168.178.1";
              description = ''
                FQDN or IP address of an IBM SAN Volume Controller.
              '';
            };
            user = mkOption {
              type = types.str;
              example = "admin";
              description = ''
                User to access the targeted IBM SAN Volume Controller.
              '';
            };
            pass = mkOption {
              type = types.str;
              example = "your-secure-password";
              description = ''
                Password for the specified IBM SAN Volume Controller read-access monitoring user.
              '';
            };
          };
        };
        output = {
          influxdb_v2 = {
            url = mkOption {
              type = types.str;
              example = "https://influxdb.example.com/";
              description = ''
                URL of the targeted InfluxDB instance.
              '';
            };
            token = mkOption {
              type = types.str;
              example = "your-influxdb-token";
              description = ''
                Token for the the targeted InfluxDB instance.
              '';
            };
            organization = mkOption {
              type = types.str;
              example = "your-influxdb-org";
              description = ''
                InfluxDB organization where the targeted bucket resides.
              '';
            };
            bucket = mkOption {
              type = types.str;
              default = "ibm";
              example = "your-influxdb-bucket";
              description = ''
                InfluxDB bucket where the output should be delivered to.
              '';
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
              description = ''
                URL of the targeted UniFi controller.
              '';
            };
            user = mkOption {
              type = types.str;
              example = "admin";
              description = ''
                User to access the targeted UniFi controller.
              '';
            };
            pass = mkOption {
              type = types.str;
              example = "your-secure-password";
              description = ''
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
              description = ''
                URL of the targeted InfluxDB instance.
              '';
            };
            token = mkOption {
              type = types.str;
              example = "your-influxdb-token";
              description = ''
                Token for the the targeted InfluxDB instance.
              '';
            };
            organization = mkOption {
              type = types.str;
              example = "your-influxdb-org";
              description = ''
                InfluxDB organization where the targeted bucket resides.
              '';
            };
            bucket = mkOption {
              type = types.str;
              default = "ubiquiti";
              example = "your-influxdb-bucket";
              description = ''
                InfluxDB bucket where the output should be delivered to.
              '';
            };
          };
        };
      };
    };
  };

  config = {

    services.telegraf = lib.mkIf cfg.monitoring.telegraf.enable {
      enable = true;
      extraConfig = {
        agent = {
          interval = "60s";
          snmp_translator = "gosmi";
        };
        inputs = {
          exec = lib.mkIf cfg.monitoring.telegraf.inputs.api.vendors.sophos.central.enable [
            (lib.mkIf cfg.monitoring.telegraf.inputs.api.vendors.sophos.central.enable {
              commands = [ "${pkgs.line-exporters}/bin/lxp-sophos-central '${cfg.monitoring.telegraf.inputs.api.vendors.sophos.central.client.id}' '${cfg.monitoring.telegraf.inputs.api.vendors.sophos.central.client.secret}'" ];
              timeout = "5m";
              interval = "900s";
              data_format = "influx";
            })
          ];
          snmp = lib.mkIf cfg.monitoring.telegraf.inputs.snmp.enable [
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.self.enable {
              name = "aruba.mobilityGateway";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.password}";
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
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.accessPoints.enable {
              name = "aruba.mobilityGateway.accessPoints";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.endpoints.accessPoints.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.mobilityGateway.credentials.privacy.password}";
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
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.switch.endpoints.self.enable {
              name = "aruba.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.switch.endpoints.self.agents;
              timeout = "20s";
              version = 2;
              community = "${cfg.monitoring.telegraf.inputs.snmp.vendors.aruba.switch.credentials.community}";
              retries = 5;
              field = [
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
              ];
              table = [
                { name = "aruba.switch.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "aruba.switch.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.endpoints.self.enable {
              name = "cisco.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.cisco.switch.credentials.privacy.password}";
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
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.endpoints.self.enable {
              name = "fortinet.firewall";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fortinet.firewall.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "serialNumber"; oid = "FORTINET-CORE-MIB::fnSysSerial.0"; }
                { name = "cpuUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0"; }
                { name = "memUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysMemUsage.0"; }
                { name = "lowMemUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0"; }
                { name = "lowMemCapacity"; oid = "FORTINET-FORTIGATE-MIB::fgSysLowMemCapacity.0"; }
                { name = "memCapacity"; oid = "FORTINET-FORTIGATE-MIB::fgSysMemCapacity.0"; }
                { name = "diskUsage"; oid = "FORTINET-FORTIGATE-MIB::fgSysDiskUsage.0"; }
                { name = "diskCapacity"; oid = "FORTINET-FORTIGATE-MIB::fgSysDiskCapacity.0"; }
                { name = "avVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionAv.0"; }
                { name = "ipsVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionIps.0"; }
                { name = "avEtVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionAvEt.0"; }
                { name = "ipsEtVersion"; oid = "FORTINET-FORTIGATE-MIB::fgSysVersionIpsEt.0"; }
                { name = "userNumber"; oid = "FORTINET-FORTIGATE-MIB::fgFwUserNumber.0"; }
                { name = "haSystemMode"; oid = "FORTINET-FORTIGATE-MIB::fgHaSystemMode.0"; }
                { name = "haGroupId"; oid = "FORTINET-FORTIGATE-MIB::fgHaGroupId.0"; }
                { name = "haPriority"; oid = "FORTINET-FORTIGATE-MIB::fgHaPriority.0"; }
                { name = "haOverride"; oid = "FORTINET-FORTIGATE-MIB::fgHaOverride.0"; }
                { name = "haAutoSync"; oid = "FORTINET-FORTIGATE-MIB::fgHaAutoSync.0"; }
                { name = "haSchedule"; oid = "FORTINET-FORTIGATE-MIB::fgHaSchedule.0"; }
                { name = "haGroupName"; oid = "FORTINET-FORTIGATE-MIB::fgHaGroupName.0"; }
                { name = "configSerial"; oid = "FORTINET-FORTIGATE-MIB::fgConfigSerial.0"; }
                { name = "configChecksum"; oid = "FORTINET-FORTIGATE-MIB::fgConfigChecksum.0"; }
                { name = "configLastChange"; oid = "FORTINET-FORTIGATE-MIB::fgConfigLastChangeTime.0"; }
              ];
              table = [
                { name = "fortinet.firewall.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "fortinet.firewall.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "fortinet.firewall.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
                ]; }
                { name = "fortinet.firewall.hwSensorTable"; oid = "FORTINET-FORTIGATE-MIB::fgHwSensorTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "FORTINET-FORTIGATE-MIB::fgHwSensorEntName"; is_tag = true; }
                ]; }
                { name = "fortinet.firewall.licContractTable"; oid = "FORTINET-FORTIGATE-MIB::fgLicContractTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "FORTINET-FORTIGATE-MIB::fgLicContractDesc"; is_tag = true; }
                ]; }
                { name = "fortinet.firewall.avStatsTable"; oid = "FORTINET-FORTIGATE-MIB::fgAvStatsTable"; inherit_tags = [ "host" ]; }
                { name = "fortinet.firewall.IpsStatsTable"; oid = "FORTINET-FORTIGATE-MIB::fgIpsStatsTable"; inherit_tags = [ "host" ]; }
                { name = "fortinet.firewall.haStatsTable"; oid = "FORTINET-FORTIGATE-MIB::fgHaStatsTable"; inherit_tags = [ "host" ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.endpoints.self.enable {
              name = "fs.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.fs.switch.credentials.privacy.password}";
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
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.endpoints.self.enable {
              name = "kentix.accessmanager";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.endpoints.self.agents;
              interval = "60s";
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.accessmanager.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
              ];
              table = [
                { name = "kentix.accessmanager.generalTable"; oid = "KENTIXDEVICES::generalTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "KENTIXDEVICES::sensorName"; is_tag = true; }
                ]; }
                { name = "kentix.accessmanager.batteryTable"; oid = "KENTIXDEVICES::batteryTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "KENTIXDEVICES::batteryIndex"; is_tag = true; }
                ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.self.enable {
              name = "kentix.sensors";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.self.agents;
              interval = "60s";
              timeout = "20s";
              version = 2;
              community = "${cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.credentials.community}";
              field = [
                # Defaults:
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }

                # Kentix specific:
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
              # Plus multisensors; generated
              ++ (kentixFuncs.mkMultisensor cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.multisensors)
              ++ (kentixFuncs.mkTemperature cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.temperatures)
              ++ (kentixFuncs.mkHumidity cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.humiditys)
              ++ (kentixFuncs.mkDewpoint cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.dewpoints)
              ++ (kentixFuncs.mkAlarm cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.alarms)
              ++ (kentixFuncs.mkCo2 cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.co2s)
              ++ (kentixFuncs.mkMotion cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.motions)
              ++ (kentixFuncs.mkDigiIn1 cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.digitalIn1s)
              ++ (kentixFuncs.mkDigiIn2 cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.digitalIn2s)
              ++ (kentixFuncs.mkDigiOut2 cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.digitalOut2s)
              ++ (kentixFuncs.mkInitErrors cfg.monitoring.telegraf.inputs.snmp.vendors.kentix.sensors.endpoints.initErrors)
              ; # Hide and seek champion.
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.endpoints.self.enable {
              name = "lancom.router";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.endpoints.self.agents;
              interval = "60s";
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lancom.router.credentials.privacy.password}";
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
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.endpoints.self.enable {
              name = "lenovo.storage";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.endpoints.self.agents;
              interval = "60s";
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.lenovo.storage.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "serialNumber"; oid = "ES-NETAPP-06-MIB::ssChassisSerialNumber.0"; }
                { name = "productFamily"; oid = "ES-NETAPP-06-MIB::ssProductID.0"; }
                { name = "status"; oid = "ES-NETAPP-06-MIB::ssStorageArrayNeedsAttention.0"; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.endpoints.self.enable {
              name = "qnap.nas";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.endpoints.self.agents;
              interval = "60s";
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.qnap.nas.credentials.privacy.password}";
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
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.endpoints.self.enable {
              name = "schneiderElectric.apc";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.schneiderElectric.apc.credentials.privacy.password}";
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
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.endpoints.self.enable {
              name = "sonicWall.fwTzNsa";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.privacy.password}";
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
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "cpuUsage"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentCPUUtil.0"; }
                { name = "cpuUsageMgmt"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentManagementCPUUtil.0"; }
                { name = "cpuUsageInspect"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentFwdAndInspectCPUUtil.0"; }
                { name = "memUsage"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentRAMUtil.0"; }
                { name = "contentFilter"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCFS.0"; }
                { name = "currentConnections"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicCurrentConnCacheEntries.0"; }
              ];
              table = [
                { name = "sonicWall.fwTzNsa.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "sonicWall.fwTzNsa.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "sonicWall.fwTzNsa.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
                ]; }
                { name = "sonicWall.fwTzNsa.vpnIpsecStats"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicSAStatTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
                { name = "sonicWall.fwTzNsa.zoneStats"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicwallFwZoneTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.endpoints.accessPoints.enable {
              name = "sonicWall.fwTzNsa.accessPoints";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.endpoints.accessPoints.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sonicWall.fwTzNsa.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "apHost"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "apNumber"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessApNumber.0"; }
              ];
              table = [
                { name = "sonicWall.fwTzNsa.accessPoints.apTable"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessApTable"; index_as_tag = true; inherit_tags = [ "apHost" ]; field = [
                  { oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicApName"; is_tag = true; }
                ]; }
                { name = "sonicWall.fwTzNsa.accessPoints.vapTable"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessVapTable"; index_as_tag = true; inherit_tags = [ "apHost" ]; field = [
                  { oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessVapSsid"; is_tag = true; }
                ]; }
                { name = "sonicWall.fwTzNsa.accessPoints.statTable"; oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicWirelessStaTable"; index_as_tag = true; inherit_tags = [ "apHost" ]; field = [
                  { oid = "SONICWALL-FIREWALL-IP-STATISTICS-MIB::sonicStaIpAddress"; is_tag = true; }
                ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.endpoints.self.enable {
              name = "sophos.sg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.sg.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "memAvailReal"; oid = "UCD-SNMP-MIB::memAvailReal.0"; }
                { name = "memTotalReal"; oid = "UCD-SNMP-MIB::memTotalReal.0"; }
                { name = "memTotalFree"; oid = "UCD-SNMP-MIB::memTotalFree.0"; }
                { name = "memBuffer"; oid = "UCD-SNMP-MIB::memBuffer.0"; }
                { name = "memCached"; oid = "UCD-SNMP-MIB::memCached.0"; }
                { name = "memAvailSwap"; oid = "UCD-SNMP-MIB::memAvailSwap.0"; }
                { name = "memTotalSwap"; oid = "UCD-SNMP-MIB::memTotalSwap.0"; }
              ];
              table = [
                { name = "sophos.sg.dskTable"; oid = "UCD-SNMP-MIB::dskTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "UCD-SNMP-MIB::dskDevice"; is_tag = true; }
                ]; }
                { name = "sophos.sg.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "sophos.sg.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "sophos.sg.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.endpoints.self.enable {
              name = "sophos.xg";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.sophos.xg.credentials.privacy.password}";
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
                { name = "sophos.xg.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "IP-MIB::ipAdEntIfIndex"; is_tag = true; }
                ]; }
                { name = "sophos.xg.vpnIpsecTable"; oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnTunnelTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnConnName"; is_tag = true; }
                  { oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnConnType"; is_tag = true; }
                  { oid = "SFOS-FIREWALL-MIB::sfosIPSecVpnActivated"; is_tag = true; }
                ]; }
                { name = "sophos.xg.processorTable"; oid = "HOST-RESOURCES-MIB::hrProcessorTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.endpoints.self.enable {
              name = "synology.dsm";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.synology.dsm.credentials.privacy.password}";
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
                { name = "highAvailActiveNode"; oid = "SYNOLOGY-SHA-MIB::activeNodeName.0"; }
                { name = "highAvailPassiveNode"; oid = "SYNOLOGY-SHA-MIB::passiveNodeName.0"; }
                { name = "highAvailClusterName"; oid = "SYNOLOGY-SHA-MIB::clusterName.0"; }
                { name = "highAvailClusterStatus"; oid = "SYNOLOGY-SHA-MIB::clusterStatus.0"; }
                { name = "highAvailClusterAutoFailover"; oid = "SYNOLOGY-SHA-MIB::clusterAutoFailover.0"; }
                { name = "highAvailHeartbeatStatus"; oid = "SYNOLOGY-SHA-MIB::heartbeatStatus.0"; }
                { name = "highAvailHeartbeatTxRate"; oid = "SYNOLOGY-SHA-MIB::heartbeatTxRate.0"; }
                { name = "highAvailHeartbeatLatency"; oid = "SYNOLOGY-SHA-MIB::heartbeatLatency.0"; }
              ];
              table = [
                { name = "synology.dsm.diskTable"; oid = "SYNOLOGY-DISK-MIB::diskTable"; inherit_tags = [ "host" ]; }
                { name = "synology.dsm.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "synology.dsm.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
                { name = "synology.dsm.raidTable"; oid = "SYNOLOGY-RAID-MIB::raidTable"; inherit_tags = [ "host" ]; field = [
                  { oid = "SYNOLOGY-RAID-MIB::raidName"; is_tag = true; }
                ]; }
                { name = "synology.dsm.serviceTable"; oid = "SYNOLOGY-SERVICES-MIB::serviceTable"; inherit_tags = [ "host" ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.endpoints.self.enable {
              name = "vmware.esxi";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.vmware.esxi.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                { name = "model"; oid = "VMWARE-SYSTEM-MIB::vmwProdName.0"; }
                { name = "firmwareVersion"; oid = "VMWARE-SYSTEM-MIB::vmwProdVersion.0"; }
                { name = "firmwareBuild"; oid = "VMWARE-SYSTEM-MIB::vmwProdBuild.0"; }
                { name = "firmwareUpdateLevel"; oid = "VMWARE-SYSTEM-MIB::vmwProdUpdate.0"; }
                { name = "firmwarePatchLevel"; oid = "VMWARE-SYSTEM-MIB::vmwProdPatch.0"; }
                { name = "memorySize"; oid = "HOST-RESOURCES-MIB::hrMemorySize.0"; }
              ];
              table = [
                { name = "vmware.esxi.vmTable"; oid = "VMWARE-VMINFO-MIB::vmwVmTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "VMWARE-VMINFO-MIB::vmwVmDisplayName"; is_tag = true; }
                ]; }
                { name = "vmware.esxi.storageTable"; oid = "HOST-RESOURCES-MIB::hrStorageTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "HOST-RESOURCES-MIB::hrStorageDescr"; is_tag = true; }
                ]; }
                { name = "vmware.esxi.deviceTable"; oid = "HOST-RESOURCES-MIB::hrDeviceTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
                { name = "vmware.esxi.processorTable"; oid = "HOST-RESOURCES-MIB::hrProcessorTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
                { name = "vmware.esxi.diskStorageTable"; oid = "HOST-RESOURCES-MIB::hrDiskStorageTable"; index_as_tag = true; inherit_tags = [ "host" ]; }
                { name = "vmware.esxi.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifDescr"; is_tag = true; }
                ]; }
                { name = "vmware.esxi.ifXTable"; oid = "IF-MIB::ifXTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
                  { oid = "IF-MIB::ifName"; is_tag = true; }
                ]; }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.endpoints.self.enable {
              name = "reddoxx";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.reddoxx.credentials.privacy.password}";
              retries = 5;
              field = [
                { name = "SmtpReceiverConnectionsIn"; oid = "REDDOXX-MIB::smtpReceiverConnectionsIn"; conversion = "int"; }
                { name = "SmtpReceiverConnectionsOut"; oid = "REDDOXX-MIB::smtpReceiverConnectionsOut"; conversion = "int"; }
                { name = "SmtpReceiverMessagesReceivedIn"; oid = "REDDOXX-MIB::smtpReceiverMessagesReceivedIn"; conversion = "int"; }
                { name = "SmtpReceiverMessagesReceivedOut"; oid = "REDDOXX-MIB::smtpReceiverMessagesReceivedOut"; conversion = "int"; }
                { name = "SmtpReceiverBytesReceivedIn"; oid = "REDDOXX-MIB::smtpReceiverBytesReceivedIn"; conversion = "int"; }
                { name = "SmtpReceiverBytesReceivedOut"; oid = "REDDOXX-MIB::smtpReceiverBytesReceivedOut"; conversion = "int"; }
                { name = "SmtpReceiverActiveConnections"; oid = "REDDOXX-MIB::smtpReceiverActiveConnections"; conversion = "int"; }
                { name = "RejectedMessagesBecauseIpBlacklisted"; oid = "REDDOXX-MIB::rejectedMessagesBecauseIpBlacklisted"; conversion = "int"; }
                { name = "RejectedMessagesBecauseAntiSpoofing"; oid = "REDDOXX-MIB::rejectedMessagesBecauseAntiSpoofing"; conversion = "int"; }
                { name = "RejectedMessagesBecauseSpf"; oid = "REDDOXX-MIB::rejectedMessagesBecauseSpf"; conversion = "int"; }
                { name = "ValidDkimSignatures"; oid = "REDDOXX-MIB::validDkimSignatures"; conversion = "int"; }
                { name = "InvalidDkimSignatures"; oid = "REDDOXX-MIB::invalidDkimSignatures"; conversion = "int"; }
                { name = "SmtpSenderConnectionsIn"; oid = "REDDOXX-MIB::smtpSenderConnectionsIn"; conversion = "int"; }
                { name = "SmtpSenderConnectionsOut"; oid = "REDDOXX-MIB::smtpSenderConnectionsOut"; conversion = "int"; }
                { name = "SmtpSenderMessagesSentIn"; oid = "REDDOXX-MIB::smtpSenderMessagesSentIn"; conversion = "int"; }
                { name = "SmtpSenderMessagesSentOut"; oid = "REDDOXX-MIB::smtpSenderMessagesSentOut"; conversion = "int"; }
                { name = "SmtpSenderBytesSentIn"; oid = "REDDOXX-MIB::smtpSenderBytesSentIn"; conversion = "int"; }
                { name = "SmtpSenderBytesSentOut"; oid = "REDDOXX-MIB::smtpSenderBytesSentOut"; conversion = "int"; }
                { name = "SmtpSenderActiveConnections"; oid = "REDDOXX-MIB::smtpSenderActiveConnections"; conversion = "int"; }
                { name = "MessagesWaitingForProcessing"; oid = "REDDOXX-MIB::messagesWaitingForProcessing"; conversion = "int"; }
                { name = "MessagesWaitingForDelivery"; oid = "REDDOXX-MIB::messagesWaitingForDelivery"; conversion = "int"; }
                { name = "ArchiveQueueLength"; oid = "REDDOXX-MIB::archiveQueueLength"; conversion = "int"; }
                { name = "RssMemoryUsageApplianceManager"; oid = "REDDOXX-MIB::rssMemoryUsageApplianceManager"; conversion = "int"; }
                { name = "RssMemoryUsageMailDepot"; oid = "REDDOXX-MIB::rssMemoryUsageMailDepot"; conversion = "int"; }
                { name = "RssMemoryUsageSystemManager"; oid = "REDDOXX-MIB::rssMemoryUsageSystemManager"; conversion = "int"; }
                { name = "RssMemoryyUsageComplianceLog"; oid = "REDDOXX-MIB::rssMemoryyUsageComplianceLog"; conversion = "int"; }
                { name = "RssMemoryUsageSpamfinder"; oid = "REDDOXX-MIB::rssMemoryUsageSpamfinder"; conversion = "int"; }
                { name = "RssMemoryUsageClamav"; oid = "REDDOXX-MIB::rssMemoryUsageClamav"; conversion = "int"; }
                { name = "RssMemoryUsageMongoDB"; oid = "REDDOXX-MIB::rssMemoryUsageMongoDB"; conversion = "int"; }
                { name = "RssMemoryUsageHaProxy"; oid = "REDDOXX-MIB::rssMemoryUsageHaProxy"; conversion = "int"; }
                { name = "RssMemoryUsageMailSealer"; oid = "REDDOXX-MIB::rssMemoryUsageMailSealer"; conversion = "int"; }
                { name = "RssMemoryUsageSmtpReceiver"; oid = "REDDOXX-MIB::rssMemoryUsageSmtpReceiver"; conversion = "int"; }
                { name = "RssMemoryUsageSmtpSender"; oid = "REDDOXX-MIB::rssMemoryUsageSmtpSender"; conversion = "int"; }
                { name = "RssMemoryUsageLogManager"; oid = "REDDOXX-MIB::rssMemoryUsageLogManager"; conversion = "int"; }
                { name = "RssMemoryUsageReddcryptGateway"; oid = "REDDOXX-MIB::rssMemoryUsageReddcryptGateway"; conversion = "int"; }
                { name = "RssMemoryUsageMailDepotIndex"; oid = "REDDOXX-MIB::rssMemoryUsageMailDepotIndex"; conversion = "int"; }
                { name = "CpuUsageApplianceManager"; oid = "REDDOXX-MIB::cpuUsageApplianceManager"; conversion = "int"; }
                { name = "CpuUsageMailDepot"; oid = "REDDOXX-MIB::cpuUsageMailDepot"; conversion = "int"; }
                { name = "CpuUsageSystemManager"; oid = "REDDOXX-MIB::cpuUsageSystemManager"; conversion = "int"; }
                { name = "CpuUsageComplianceLog"; oid = "REDDOXX-MIB::cpuUsageComplianceLog"; conversion = "int"; }
                { name = "CpuUsageSpamfinder"; oid = "REDDOXX-MIB::cpuUsageSpamfinder"; conversion = "int"; }
                { name = "CpuUsageClamav"; oid = "REDDOXX-MIB::cpuUsageClamav"; conversion = "int"; }
                { name = "CpuUsageMongoDB"; oid = "REDDOXX-MIB::cpuUsageMongoDB"; conversion = "int"; }
                { name = "CpuUsageHaProxy"; oid = "REDDOXX-MIB::cpuUsageHaProxy"; conversion = "int"; }
                { name = "CpuUsageMailSealer"; oid = "REDDOXX-MIB::cpuUsageMailSealer"; conversion = "int"; }
                { name = "CpuUsageSmtpReceiver"; oid = "REDDOXX-MIB::cpuUsageSmtpReceiver"; conversion = "int"; }
                { name = "CpuUsageSmtpSender"; oid = "REDDOXX-MIB::cpuUsageSmtpSender"; conversion = "int"; }
                { name = "CpuUsageLogManager"; oid = "REDDOXX-MIB::cpuUsageLogManager"; conversion = "int"; }
                { name = "CpuUsageReddcryptGateway"; oid = "REDDOXX-MIB::cpuUsageReddcryptGateway"; conversion = "int"; }
                { name = "CpuUsageMailDepotIndex"; oid = "REDDOXX-MIB::cpuUsageMailDepotIndex"; conversion = "int"; }
                { name = "UptimeApplianceManager"; oid = "REDDOXX-MIB::uptimeApplianceManager"; conversion = "int"; }
                { name = "UptimeMailDepot"; oid = "REDDOXX-MIB::uptimeMailDepot"; conversion = "int"; }
                { name = "UptimeSystemManager"; oid = "REDDOXX-MIB::uptimeSystemManager"; conversion = "int"; }
                { name = "UptimeComplianceLog"; oid = "REDDOXX-MIB::uptimeComplianceLog"; conversion = "int"; }
                { name = "UptimeSpamfinder"; oid = "REDDOXX-MIB::uptimeSpamfinder"; conversion = "int"; }
                { name = "UptimeClamav"; oid = "REDDOXX-MIB::uptimeClamav"; conversion = "int"; }
                { name = "UptimeMongoDB"; oid = "REDDOXX-MIB::uptimeMongoDB"; conversion = "int"; }
                { name = "UptimeHaProxy"; oid = "REDDOXX-MIB::uptimeHaProxy"; conversion = "int"; }
                { name = "UptimeMailSealer"; oid = "REDDOXX-MIB::uptimeMailSealer"; conversion = "int"; }
                { name = "UptimeSmtpReceiver"; oid = "REDDOXX-MIB::uptimeSmtpReceiver"; conversion = "int"; }
                { name = "UptimeSmtpSender"; oid = "REDDOXX-MIB::uptimeSmtpSender"; conversion = "int"; }
                { name = "UptimeLogManager"; oid = "REDDOXX-MIB::uptimeLogManager"; conversion = "int"; }
                { name = "UptimeReddcryptGateway"; oid = "REDDOXX-MIB::uptimeReddcryptGateway"; conversion = "int"; }
                { name = "UptimeMailDepotIndex"; oid = "REDDOXX-MIB::uptimeMailDepotIndex"; conversion = "int"; }
                { name = "OpenFilesTotal"; oid = "REDDOXX-MIB::openFilesTotal"; conversion = "int"; }
                { name = "OpenFilesContainer"; oid = "REDDOXX-MIB::openFilesContainer"; conversion = "int"; }
                { name = "OpenFilesIndex"; oid = "REDDOXX-MIB::openFilesIndex"; conversion = "int"; }

                # Default MIB OIDs (reused from (...).vendor.sophos.xg)
                { name = "contact"; oid = "SNMPv2-MIB::sysContact.0"; }
                { name = "description"; oid = "SNMPv2-MIB::sysDescr.0"; }
                { name = "location"; oid = "SNMPv2-MIB::sysLocation.0"; }
                { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
                { name = "uptime"; oid = "SNMPv2-MIB::sysUpTime.0"; }
                # Missing:
                # diskCapacity, diskPercentUsage,
                # memoryCapacity (via defaults?), memoryPercentage
              ];
              table = [
                {
                  name = "reddoxx.storage";
                  oid = "HOST-RESOURCES-MIB::hrStorageTable";
                  index_as_tag = true;
                  inherit_tags = ["host"];
                  field = [
                    {
                      oid = "HOST-RESOURCES-MIB::hrStorageType";
                      is_tag = true;
                    }
                    {
                      oid = "HOST-RESOURCES-MIB::hrStorageDescr";
                      is_tag = true;
                    }
                    {
                      oid = "HOST-RESOURCES-MIB::hrStorageSize";
                    }
                    {
                      oid = "HOST-RESOURCES-MIB::hrStorageUsed";
                    }
                  ];
                }
                {
                  name = "reddoxx.ifTable"; 
                  oid = "IF-MIB::ifTable"; 
                  index_as_tag = true; 
                  inherit_tags = [ "host" ]; 
                  field = [
                    { oid = "IF-MIB::ifDescr"; is_tag = true; }
                  ];
                }
                {
                  name = "reddoxx.ifXTable"; 
                  oid = "IF-MIB::ifXTable"; 
                  index_as_tag = true; 
                  inherit_tags = [ "host" ]; 
                  field = [
                    { oid = "IF-MIB::ifName"; is_tag = true; }
                  ];
                }
                { name = "reddoxx.ipAddrTable"; oid = "IP-MIB::ipAddrTable"; inherit_tags = [ "host" ]; }
                {
                  name = "reddoxx.cpu";
                  oid = "HOST-RESOURCES-MIB::hrProcessorTable";
                  index_as_tag = true;
                  inherit_tags = [ "host" ];
                  field = [{
                    oid = "HOST-RESOURCES-MIB::hrProcessorFrwID";
                    is_tag = true;
                  }];
                }
              ];
            })
            (lib.mkIf cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.endpoints.self.enable {
              name = "zyxel.switch";
              path = [ "${pkgs.mib-library}/opt/mib-library/" ];
              agents = cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.endpoints.self.agents;
              timeout = "20s";
              version = 3;
              sec_level = "${cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.credentials.security.level}";
              sec_name = "${cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.credentials.security.username}";
              auth_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.credentials.authentication.protocol}";
              auth_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.credentials.authentication.password}";
              priv_protocol = "${cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.credentials.privacy.protocol}";
              priv_password = "${cfg.monitoring.telegraf.inputs.snmp.vendors.zyxel.switch.credentials.privacy.password}";
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
            })
          ];
          vsphere = lib.mkIf cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.enable [
            {
              interval = "60s";
              name_prefix = "vmware.";
              vcenters = cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.sdk.endpoints;
              username = "${cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.sdk.username}";
              password = "${cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.sdk.password}";
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
              vcenters = cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.sdk.endpoints;
              username = "${cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.sdk.username}";
              password = "${cfg.monitoring.telegraf.inputs.api.vendors.vmware.vsphere.sdk.password}";
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

          ## Ping Configuration
          ping = lib.mkIf cfg.monitoring.telegraf.inputs.ping.enable [{
            name_override = "ping";
            urls = cfg.monitoring.telegraf.inputs.ping.urls;
            method = "native";
          }];

          ## Local Raspberry Pi Configuration
          cpu = lib.mkIf cfg.monitoring.telegraf.inputs.local_pi.stats.cpu.enable [{
            name_override = "${cfg.monitoring.telegraf.inputs.local_pi.name_override}.cpu";
            percpu = true;
            totalcpu = true;
            collect_cpu_time = false;
            report_active = false;
            core_tags = true;
          }];
          disk = lib.mkIf cfg.monitoring.telegraf.inputs.local_pi.stats.disk.enable [{
            name_override = "${cfg.monitoring.telegraf.inputs.local_pi.name_override}.disk";
            # NixOS verwendet btrfs; und das spammt die aktiven Mounts leider.
            # Daher wird nur Bezug auf die MicroSD (rootFS bei einem Pi) verwendet.
            # Die Boot Partition (/boot) wird komplett ignoriert - sind ca 200mb weil EFI GPT
            mount_points = [ "/" ];
          }];
          mem = lib.mkIf cfg.monitoring.telegraf.inputs.local_pi.stats.mem.enable [{
            name_override = "${cfg.monitoring.telegraf.inputs.local_pi.name_override}.mem";
            # Keine Konfiguration nötig.
          }];
          kernel = lib.mkIf cfg.monitoring.telegraf.inputs.local_pi.stats.kernel.enable [{
            name_override = "${cfg.monitoring.telegraf.inputs.local_pi.name_override}.kernel";
            collect = [ "*" ];
          }];
          processes = lib.mkIf cfg.monitoring.telegraf.inputs.local_pi.stats.processes.enable [{
            name_override = "${cfg.monitoring.telegraf.inputs.local_pi.name_override}.proc";
            # Keine Konfiguration nötig.
          }];
          system = lib.mkIf cfg.monitoring.telegraf.inputs.local_pi.stats.system.enable [{
            name_override = "${cfg.monitoring.telegraf.inputs.local_pi.name_override}.sys";
            # Keine Konfiguration nötig.
          }];

          http_listener_v2 = lib.mkIf cfg.monitoring.telegraf.inputs.webhook.enable
            cfg.monitoring.telegraf.inputs.webhook.endpoints;
        };
        outputs = cfg.monitoring.telegraf.outputs;
      };
    };

    virtualisation.oci-containers = {
      containers =
        { svci = lib.mkIf cfg.monitoring.svci.enable {
          image = "ghcr.io/senpro-it/svci:main";
          autoStart = true;
          volumes = [
            "svci:/config/svci"
          ];
          cmd = [ "--conf=/config/svci/svci.toml" ];
        }; }
        //
        { unifi-poller = lib.mkIf cfg.monitoring.unifi-poller.enable {
          image = "ghcr.io/unpoller/unpoller:latest-arm64v8";
          autoStart = true;
          environment = {
            UP_INFLUXDB_URL = "${cfg.monitoring.unifi-poller.output.influxdb_v2.url}";
            UP_INFLUXDB_ORG = "${cfg.monitoring.unifi-poller.output.influxdb_v2.organization}";
            UP_INFLUXDB_BUCKET = "${cfg.monitoring.unifi-poller.output.influxdb_v2.bucket}";
            UP_INFLUXDB_AUTH_TOKEN = "${cfg.monitoring.unifi-poller.output.influxdb_v2.token}";
            UP_UNIFI_DEFAULT_USER = "${cfg.monitoring.unifi-poller.input.unifi-controller.user}";
            UP_UNIFI_DEFAULT_PASS = "${cfg.monitoring.unifi-poller.input.unifi-controller.pass}";
            UP_UNIFI_DEFAULT_URL = "${cfg.monitoring.unifi-poller.input.unifi-controller.url}";
            UP_POLLER_DEBUG = "true";
          };
        }; }
        //
        listToAttrs (
          (map (name: {
            name = "fritzinfluxdb-${name}"; value = createFritzInfluxDBContainer (builtins.getAttr name cfg.monitoring.fritzinfluxdb.inputs) name;
          }) (builtins.attrNames cfg.monitoring.fritzinfluxdb.inputs))
        );
    };

    systemd.services = {
      docker-svci-provisioner = lib.mkIf cfg.monitoring.svci.enable {
        enable = true;
        description = "Provisioner for SVCi docker container.";
        requiredBy = [ "docker-svci.service" ];
        restartIfChanged = true;
        preStart = ''
          ${pkgs.docker-client}/bin/docker volume create svci
          ${pkgs.coreutils-full}/bin/printf "%s\n" \
            "# SVCi Configuration" \
            "# Copy this file into /etc/svci.toml and customize it to your environment." \
            "" \
            "###" \
            "### Define one InfluxDB to save metrics into" \
            "### There must be only one and it should be named [influx]" \
            "###" \
            "" \
            "[influx]" \
            "url = \"${cfg.monitoring.svci.output.influxdb_v2.url}\"" \
            "org = \"${cfg.monitoring.svci.output.influxdb_v2.organization}\"" \
            "token = \"${cfg.monitoring.svci.output.influxdb_v2.token}\"" \
            "bucket = \"${cfg.monitoring.svci.output.influxdb_v2.bucket}\"" \
            "" \
            "[svc.ibm]" \
            "url = \"https://${cfg.monitoring.svci.input.svc.host}:7443\"" \
            "username = \"${cfg.monitoring.svci.input.svc.user}\"" \
            "password = \"${cfg.monitoring.svci.input.svc.pass}\"" \
            "refresh = 30   # How often to query SVC for data - in seconds" \
            "trust = true   # Ignore SSL cert. errors (due to default self-signed cert.)" > /var/lib/docker/volumes/svci/_data/svci.toml
        '';
        postStop = ''
          ${pkgs.coreutils-full}/bin/rm -f /var/lib/docker/volumes/svci/_data/svci.toml
          ${pkgs.docker-client}/bin/docker volume delete svci
        '';
        serviceConfig = { ExecStart = ''${pkgs.bashInteractive}/bin/bash -c "while true; do echo 'docker-svci-provisioner is up & running'; sleep 1d; done"''; };
      };
    };

  };

}
