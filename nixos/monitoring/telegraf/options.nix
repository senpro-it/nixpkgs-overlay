{ lib }:

with lib;

rec {
  mkInputSettingsOption = options: description: mkOption {
    type = types.submodule { inherit options; };
    default = {};
    description = description;
  };

  mkSnmpEndpointOptions = { description, credentials }: {
    endpoints = {
      self = {
        enable = mkEnableOption description;
        agents = agentConfig;
      };
    };
    credentials = credentials;
  };

  mkSnmpV3Options = description: mkSnmpEndpointOptions {
    inherit description;
    credentials = authSNMPv3;
  };

  mkSnmpV2Options = description: mkSnmpEndpointOptions {
    inherit description;
    credentials = authSNMPv2;
  };

  agentConfig = mkOption {
    type = types.listOf types.str;
    default = [];
    example = literalExpression ''
      [ "udp://192.168.178.1:161" ]
    '';
    description = ''
      Endpoints which should be monitored. See the [documentation](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp/README.md) for syntax reference.
    '';
  };

  snmpInput = with types; {
    interval = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Interval for SNMP polling.";
    };
    timeout = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Timeout for each SNMP request.";
    };
    stop_on_error = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Stop polling tables if an agent fails.";
    };
    version = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "SNMP version (1, 2, or 3).";
    };
    unconnected_udp_socket = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Accept SNMP responses from any address.";
    };
    path = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "Paths to MIB files for the gosmi translator.";
    };
    agent_host_tag = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tag name used for the agent host.";
    };
    retries = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Number of retries for SNMP requests.";
    };
    max_repetitions = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "GETBULK max-repetitions parameter.";
    };
  };

  authSNMPv3 = with types; {
    context = {
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Context name for SNMPv3 to authenticate at the agent.
        '';
      };
    };
    authentication = {
      protocol = mkOption {
        type = types.nullOr (types.enum [ "MD5" "SHA" "SHA224" "SHA256" "SHA384" "SHA512" ]);
        default = null;
        description = ''
          Authentication protocol used by SNMPv3 to authenticate at the agent.
        '';
      };
      password = mkOption {
        type = types.str;
        example = "VJQUpLCLGniEDVGK8Q0oPS9Yf0xObE7m8aCDK4FR7Kzzh47MD2ZQy0dVtTkDeKBd";
        description = ''
          Password used by SNMPv3 to authenticate at the agent.
        '';
      };
    };
    privacy = {
      protocol = mkOption {
        type = types.nullOr (types.enum [ "DES" "AES" "AES192" "AES192C" "AES256" "AES256C" ]);
        default = null;
        description = ''
          Privacy protocol used by SNMPv3 to authenticate at the agent.
        '';
      };
      password = mkOption {
        type = types.str;
        example = "GO61HVwspXO514vbzZiV3IwGeBnSZsjHoBaHbJU4JgEaznJ4AdVTy0wzwpzgNffz";
        description = ''
          Password used by SNMPv3 to protect the connection to the agent.
        '';
      };
    };
    security = {
      level = mkOption {
        type = types.nullOr (types.enum [ "noAuthNoPriv" "authNoPriv" "authPriv" ]);
        default = null;
        description = ''
          Security level for SNMPv3. Look at the [documentation](https://snmp.com/snmpv3/snmpv3_intro.shtml) for further information.
        '';
      };
      username = mkOption {
        type = types.str;
        example = "monitor";
        description = ''
          Username for SNMPv3. Also known as `Security Name`.
        '';
      };
    };
  };

  authSNMPv2 = with types; {
    community = mkOption {
      type = types.str;
      example = "public";
      description = ''
        "Community" string used to authenticate via SNMPv2
      '';
    };
  };

  execInput = with types; {
    commands = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Commands executed by the exec input.";
    };
    environment = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "Environment variables for exec commands.";
    };
    timeout = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Timeout for each command.";
    };
    name_suffix = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Measurement name suffix for exec commands.";
    };
    ignore_error = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Ignore non-zero exit codes.";
    };
    data_format = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Data format to parse exec output.";
    };
  };

  vsphereInput = with types; {
    interval = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Collection interval for the vSphere instance.";
    };
    name_prefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Measurement name prefix.";
    };
    vm_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    vm_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    vm_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    vm_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    vm_instances = mkOption { type = types.nullOr types.bool; default = null; };
    host_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    host_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    host_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    host_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    host_instances = mkOption { type = types.nullOr types.bool; default = null; };
    ip_addresses = mkOption { type = types.nullOr (types.listOf (types.enum [ "ipv4" "ipv6" ])); default = null; };
    cluster_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    cluster_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    cluster_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    cluster_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    cluster_instances = mkOption { type = types.nullOr types.bool; default = null; };
    resource_pool_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    resource_pool_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    resource_pool_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    resource_pool_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    resource_pool_instances = mkOption { type = types.nullOr types.bool; default = null; };
    datastore_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datastore_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datastore_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datastore_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datastore_instances = mkOption { type = types.nullOr types.bool; default = null; };
    datacenter_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datacenter_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datacenter_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datacenter_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    datacenter_instances = mkOption { type = types.nullOr types.bool; default = null; };
    vsan_metric_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    vsan_metric_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    vsan_metric_skip_verify = mkOption { type = types.nullOr types.bool; default = null; };
    vsan_interval = mkOption { type = types.nullOr types.str; default = null; };
    separator = mkOption { type = types.nullOr types.str; default = null; };
    max_query_objects = mkOption { type = types.nullOr types.int; default = null; };
    max_query_metrics = mkOption { type = types.nullOr types.int; default = null; };
    collect_concurrency = mkOption { type = types.nullOr types.int; default = null; };
    discover_concurrency = mkOption { type = types.nullOr types.int; default = null; };
    object_discovery_interval = mkOption { type = types.nullOr types.str; default = null; };
    timeout = mkOption { type = types.nullOr types.str; default = null; };
    use_int_samples = mkOption { type = types.nullOr types.bool; default = null; };
    custom_attribute_include = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    custom_attribute_exclude = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    metric_lookback = mkOption { type = types.nullOr types.int; default = null; };
    ssl_ca = mkOption { type = types.nullOr types.str; default = null; };
    ssl_cert = mkOption { type = types.nullOr types.str; default = null; };
    ssl_key = mkOption { type = types.nullOr types.str; default = null; };
    insecure_skip_verify = mkOption { type = types.nullOr types.bool; default = null; };
    historical_interval = mkOption { type = types.nullOr types.str; default = null; };
    disconnected_servers_behavior = mkOption { type = types.nullOr (types.enum [ "error" "ignore" ]); default = null; };
    use_system_proxy = mkOption { type = types.nullOr types.bool; default = null; };
    http_proxy_url = mkOption { type = types.nullOr types.str; default = null; };
  };

  internetSpeedInput = with types; {
    name_override = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Measurement name override.";
    };
    interval = mkOption { type = types.nullOr types.str; default = null; };
    collection_jitter = mkOption { type = types.nullOr types.str; default = null; };
    memory_saving_mode = mkOption { type = types.nullOr types.bool; default = null; };
    cache = mkOption { type = types.nullOr types.bool; default = null; };
    connections = mkOption { type = types.nullOr types.int; default = null; };
    test_mode = mkOption { type = types.nullOr (types.enum [ "single" "multi" ]); default = null; };
    server_id_exclude = mkOption { type = types.nullOr (types.listOf types.int); default = null; };
    server_id_include = mkOption { type = types.nullOr (types.listOf types.int); default = null; };
  };

  pingInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
    method = mkOption { type = types.nullOr (types.enum [ "exec" "native" ]); default = null; };
    count = mkOption { type = types.nullOr types.int; default = null; };
    ping_interval = mkOption { type = types.nullOr types.float; default = null; };
    timeout = mkOption { type = types.nullOr types.float; default = null; };
    deadline = mkOption { type = types.nullOr types.int; default = null; };
    interface = mkOption { type = types.nullOr types.str; default = null; };
    percentiles = mkOption { type = types.nullOr (types.listOf types.int); default = null; };
    binary = mkOption { type = types.nullOr types.str; default = null; };
    arguments = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    ipv4 = mkOption { type = types.nullOr types.bool; default = null; };
    ipv6 = mkOption { type = types.nullOr types.bool; default = null; };
    size = mkOption { type = types.nullOr types.int; default = null; };
  };

  cpuInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
    percpu = mkOption { type = types.nullOr types.bool; default = null; };
    totalcpu = mkOption { type = types.nullOr types.bool; default = null; };
    collect_cpu_time = mkOption { type = types.nullOr types.bool; default = null; };
    report_active = mkOption { type = types.nullOr types.bool; default = null; };
    core_tags = mkOption { type = types.nullOr types.bool; default = null; };
  };

  diskInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
    mount_points = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    ignore_fs = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    ignore_mount_opts = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
  };

  kernelInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
    collect = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
  };

  processesInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
    use_sudo = mkOption { type = types.nullOr types.bool; default = null; };
  };

  memInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
  };

  systemInput = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
  };

  httpListener = with types; {
    name_override = mkOption { type = types.nullOr types.str; default = null; };
    service_address = mkOption { type = types.nullOr types.str; default = null; };
    socket_mode = mkOption { type = types.nullOr types.str; default = null; };
    paths = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    path_tag = mkOption { type = types.nullOr types.bool; default = null; };
    methods = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    http_headers = mkOption { type = types.nullOr (types.attrsOf types.str); default = null; };
    http_success_code = mkOption { type = types.nullOr types.int; default = null; };
    read_timeout = mkOption { type = types.nullOr types.str; default = null; };
    write_timeout = mkOption { type = types.nullOr types.str; default = null; };
    max_body_size = mkOption { type = types.nullOr types.str; default = null; };
    data_source = mkOption { type = types.nullOr types.str; default = null; };
    tls_allowed_cacerts = mkOption { type = types.nullOr (types.listOf types.str); default = null; };
    tls_cert = mkOption { type = types.nullOr types.str; default = null; };
    tls_key = mkOption { type = types.nullOr types.str; default = null; };
    tls_min_version = mkOption { type = types.nullOr types.str; default = null; };
    basic_username = mkOption { type = types.nullOr types.str; default = null; };
    basic_password = mkOption { type = types.nullOr types.str; default = null; };
    http_header_tags = mkOption { type = types.nullOr (types.attrsOf types.str); default = null; };
    data_format = mkOption { type = types.nullOr types.str; default = null; };
    json_v2 = mkOption { type = types.nullOr types.anything; default = null; };
  };
}
