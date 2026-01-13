{ config, lib, ... }:

with lib;

let
  cfg = config.senpro;
  telegrafOptions = import ./options.nix { inherit lib; };
  webhookCfg = cfg.monitoring.telegraf.inputs.webhook;

in {
  options.senpro.monitoring.telegraf.inputs.webhook = {
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

  config = {
    services.telegraf.extraConfig.inputs.http_listener_v2 = lib.mkIf webhookCfg.enable
      webhookCfg.endpoints;
  };
}
