{ lib }:

with lib;

{
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

  authSNMPv3 = with types; {
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

  authSNMPv2 = with types; {
    community = mkOption {
      type = types.str;
      example = "public";
      default = "public"; # This actually is the default...
      description = ''
        "Community" string used to authenticate via SNMPv2
      '';
    };
  };

  httpListener = with types; {
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
}
