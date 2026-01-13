{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.senpro;
  settingsFormat = pkgs.formats.toml {};
  telegrafOptions = import ./telegraf/options.nix { inherit lib; };
  inputsCfg = cfg.monitoring.telegraf.inputs;
  apiCfg = inputsCfg.api;
  vsphereCfg = apiCfg.vendors.vmware.vsphere;
  pingCfg = inputsCfg.ping;
  localPiCfg = inputsCfg.local_pi;
  webhookCfg = inputsCfg.webhook;

in {
  imports = [
    ./telegraf/snmp/default.nix
  ];

  options.senpro.monitoring.telegraf = {
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
      internet_speed = {
        enable = mkEnableOption ''
          Whether to enable internet speed monitoring.
        '';
        settings = mkOption {
          type = settingsFormat.type;
          default = {};
          description = "Options passed straight into [[inputs.internet_speed]].";
          example = {
            interval = "60m";
            collection_jitter = "60s";
            cache = false;
            memory_saving_mode = true;
            test_mode = "multi";
            connections = 4;
            # server_id_include = [ 54619 ];
            # server_id_exclude = [ 9999 ];
          };
        };
      };
      snmp = {
        enable = mkEnableOption ''
          Whether to enable SNMP monitoring.
        '';
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

  config = {
    services.telegraf = lib.mkIf cfg.monitoring.telegraf.enable {
      enable = true;
      extraConfig = {
        agent = {
          interval = "60s";
          snmp_translator = "gosmi";
        };
        processors = {
          converter = [
            {
              namepass = [ "internet.speed" ];
              tags = { string = [ "source" "server_id" "test_mode" ]; };
            }
          ];
        };
        inputs = {
          internet_speed = lib.mkIf inputsCfg.internet_speed.enable [
            (let s = inputsCfg.internet_speed.settings; in
              # merge user settings with defaults (only when not provided)
              s
              // { name_override = "internet.speed"; }
              // lib.optionalAttrs (!(s ? interval))              { interval = "60m"; }
              // lib.optionalAttrs (!(s ? collection_jitter))     { collection_jitter = "60s"; }
              // lib.optionalAttrs (!(s ? memory_saving_mode))    { memory_saving_mode = true; }
              // lib.optionalAttrs (!(s ? cache))                 { cache = false; }
              // lib.optionalAttrs (!(s ? test_mode))             { test_mode = "multi"; }
              // lib.optionalAttrs (!(s ? connections))           { connections = 4; }
            )
          ];
          exec = lib.mkIf apiCfg.vendors.sophos.central.enable [
            (lib.mkIf apiCfg.vendors.sophos.central.enable {
              commands = [ "${pkgs.line-exporters}/bin/lxp-sophos-central '${apiCfg.vendors.sophos.central.client.id}' '${apiCfg.vendors.sophos.central.client.secret}'" ];
              timeout = "5m";
              interval = "900s";
              data_format = "influx";
            })
          ];
          vsphere = lib.mkIf vsphereCfg.enable [
            {
              interval = "60s";
              name_prefix = "vmware.";
              vcenters = vsphereCfg.sdk.endpoints;
              username = "${vsphereCfg.sdk.username}";
              password = "${vsphereCfg.sdk.password}";
              insecure_skip_verify = true;
              # NOTE(KI): Possibly quietly deprecated
              # force_discover_on_init = true;
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
              vcenters = vsphereCfg.sdk.endpoints;
              username = "${vsphereCfg.sdk.username}";
              password = "${vsphereCfg.sdk.password}";
              insecure_skip_verify = true;
              # NOTE(KI): Possibly quietly deprecated
              # force_discover_on_init = true;
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
          ping = lib.mkIf pingCfg.enable [{
            name_override = "ping";
            urls = pingCfg.urls;
            method = "native";
          }];

          ## Local Raspberry Pi Configuration
          cpu = lib.mkIf localPiCfg.stats.cpu.enable [{
            name_override = "${localPiCfg.name_override}.cpu";
            percpu = true;
            totalcpu = true;
            collect_cpu_time = false;
            report_active = false;
            core_tags = true;
          }];
          disk = lib.mkIf localPiCfg.stats.disk.enable [{
            name_override = "${localPiCfg.name_override}.disk";
            # NixOS verwendet btrfs; und das spammt die aktiven Mounts leider.
            # Daher wird nur Bezug auf die MicroSD (rootFS bei einem Pi) verwendet.
            # Die Boot Partition (/boot) wird komplett ignoriert - sind ca 200mb weil EFI GPT
            mount_points = [ "/" ];
          }];
          mem = lib.mkIf localPiCfg.stats.mem.enable [{
            name_override = "${localPiCfg.name_override}.mem";
            # Keine Konfiguration nötig.
          }];
          kernel = lib.mkIf localPiCfg.stats.kernel.enable [{
            name_override = "${localPiCfg.name_override}.kernel";
            collect = [ "*" ];
          }];
          processes = lib.mkIf localPiCfg.stats.processes.enable [{
            name_override = "${localPiCfg.name_override}.proc";
            # Keine Konfiguration nötig.
          }];
          system = lib.mkIf localPiCfg.stats.system.enable [{
            name_override = "${localPiCfg.name_override}.sys";
            # Keine Konfiguration nötig.
          }];

          http_listener_v2 = lib.mkIf webhookCfg.enable
            webhookCfg.endpoints;
        };
        outputs = cfg.monitoring.telegraf.outputs;
      };
    };
  };
}
