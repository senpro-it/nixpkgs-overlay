{ config, lib, telegrafOptions, ... }:

with lib;

let
  /* Webhook input configuration subtree. */
  webhookCfg = config.senpro.monitoring.telegraf.inputs.webhook;
  /* Allowed JSON v2 field type strings. */
  jsonV2FieldTypes = [ "int" "uint" "float" "string" "bool" ];
  /* Normalize JSON v2 entries to a list.
     @param sanitizer: Function applied to each entry.
     @param value: Single entry or list of entries.
     @return List of sanitized entries.
  */
  sanitizeJsonV2Items = sanitizer: value:
    let
      list = if isList value then value else [ value ];
    in map sanitizer list;
  /* Sanitize JSON v2 tag entries.
     @param tag: Tag definition attrset.
     @return Sanitized tag entry without type metadata.
  */
  sanitizeJsonV2Tag = tag:
    removeAttrs (telegrafOptions.sanitizeToml tag) [ "type" ];
  /* Sanitize JSON v2 field entries and validate types.
     @param field: Field definition attrset.
     @return Sanitized field entry with valid type.
  */
  sanitizeJsonV2Field = field:
    let
      sanitized = telegrafOptions.sanitizeToml field;
    in if sanitized ? type && !(builtins.elem sanitized.type jsonV2FieldTypes)
      then removeAttrs sanitized [ "type" ]
      else sanitized;
  /* Sanitize JSON v2 object entries.
     @param object: Object definition attrset.
     @return Sanitized object entry with nested lists.
  */
  sanitizeJsonV2Object = object:
    let
      sanitized = telegrafOptions.sanitizeToml object;
      tagList = if sanitized ? tag then sanitizeJsonV2Items sanitizeJsonV2Tag sanitized.tag else null;
      fieldList = if sanitized ? field then sanitizeJsonV2Items sanitizeJsonV2Field sanitized.field else null;
    in sanitized
      // optionalAttrs (tagList != null) { tag = tagList; }
      // optionalAttrs (fieldList != null) { field = fieldList; };
  /* Sanitize JSON v2 top-level entry.
     @param entry: JSON v2 entry attrset.
     @return Sanitized entry with normalized lists.
  */
  sanitizeJsonV2Entry = entry:
    let
      sanitized = telegrafOptions.sanitizeToml entry;
      tagList = if sanitized ? tag then sanitizeJsonV2Items sanitizeJsonV2Tag sanitized.tag else null;
      fieldList = if sanitized ? field then sanitizeJsonV2Items sanitizeJsonV2Field sanitized.field else null;
      objectList = if sanitized ? object then sanitizeJsonV2Items sanitizeJsonV2Object sanitized.object else null;
    in sanitized
      // optionalAttrs (tagList != null) { tag = tagList; }
      // optionalAttrs (fieldList != null) { field = fieldList; }
      // optionalAttrs (objectList != null) { object = objectList; };
  /* Sanitize webhook endpoint definitions for Telegraf.
     @param endpoint: Raw endpoint attrset from module options.
     @return Sanitized endpoint with JSON v2 defaults applied.
  */
  sanitizeWebhookEndpoint = endpoint:
    let
      sanitized = telegrafOptions.sanitizeToml endpoint;
      jsonV2Value = sanitized.json_v2 or null;
      jsonV2List = if jsonV2Value == null
        then null
        else sanitizeJsonV2Items sanitizeJsonV2Entry jsonV2Value;
      dataFormat = if jsonV2Value != null && (sanitized.data_format or null) == null
        then "json_v2"
        else sanitized.data_format or null;
      formatOverride = sanitized.format or null;
      base = sanitized
        // optionalAttrs (jsonV2List != null) { json_v2 = jsonV2List; }
        // optionalAttrs (dataFormat != null) { data_format = dataFormat; };
    in if formatOverride != null && dataFormat == null
      then removeAttrs base [ "format" ] // { data_format = formatOverride; }
      else removeAttrs base [ "format" ];
  /* Final list of sanitized webhook endpoints. */
  webhookEndpoints = map sanitizeWebhookEndpoint webhookCfg.endpoints;

in {
  /* Webhook input options for Telegraf HTTP listener. */
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
      webhookEndpoints;
  };
}
