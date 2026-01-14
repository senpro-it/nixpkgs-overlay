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
  /* Normalize JSON v2 tag entries.
     @param tag: Tag definition attrset.
     @return Tag entry without type metadata.
  */
  sanitizeJsonV2Tag = tag:
    removeAttrs tag [ "type" ];
  /* Normalize JSON v2 field entries and validate types.
     @param field: Field definition attrset.
     @return Field entry with valid type.
  */
  sanitizeJsonV2Field = field:
    let
      typeValue = field.type or null;
    in if typeValue != null && !(builtins.elem typeValue jsonV2FieldTypes)
      then removeAttrs field [ "type" ]
      else field;
  /* Normalize JSON v2 object entries.
     @param object: Object definition attrset.
     @return Object entry with nested lists.
  */
  sanitizeJsonV2Object = object:
    let
      tagValue = object.tag or null;
      fieldValue = object.field or null;
      tagList = if tagValue == null then null else sanitizeJsonV2Items sanitizeJsonV2Tag tagValue;
      fieldList = if fieldValue == null then null else sanitizeJsonV2Items sanitizeJsonV2Field fieldValue;
      base = removeAttrs object [ "tag" "field" ];
    in base
      // optionalAttrs (tagList != null) { tag = tagList; }
      // optionalAttrs (fieldList != null) { field = fieldList; };
  /* Normalize JSON v2 top-level entry.
     @param entry: JSON v2 entry attrset.
     @return Entry with normalized lists.
  */
  sanitizeJsonV2Entry = entry:
    let
      tagValue = entry.tag or null;
      fieldValue = entry.field or null;
      objectValue = entry.object or null;
      tagList = if tagValue == null then null else sanitizeJsonV2Items sanitizeJsonV2Tag tagValue;
      fieldList = if fieldValue == null then null else sanitizeJsonV2Items sanitizeJsonV2Field fieldValue;
      objectList = if objectValue == null then null else sanitizeJsonV2Items sanitizeJsonV2Object objectValue;
      base = removeAttrs entry [ "tag" "field" "object" ];
    in base
      // optionalAttrs (tagList != null) { tag = tagList; }
      // optionalAttrs (fieldList != null) { field = fieldList; }
      // optionalAttrs (objectList != null) { object = objectList; };
  /* Normalize webhook endpoint definitions for Telegraf.
     @param endpoint: Raw endpoint attrset from module options.
     @return Endpoint with JSON v2 defaults applied.
  */
  sanitizeWebhookEndpoint = endpoint:
    let
      jsonV2Value = endpoint.json_v2 or null;
      jsonV2List = if jsonV2Value == null
        then null
        else sanitizeJsonV2Items sanitizeJsonV2Entry jsonV2Value;
      dataFormat = if jsonV2Value != null && (endpoint.data_format or null) == null
        then "json_v2"
        else endpoint.data_format or null;
      formatOverride = endpoint.format or null;
      base = removeAttrs endpoint [ "format" "json_v2" "data_format" ];
      normalized = base
        // optionalAttrs (jsonV2List != null) { json_v2 = jsonV2List; }
        // optionalAttrs (dataFormat != null) { data_format = dataFormat; };
    in if formatOverride != null && dataFormat == null
      then normalized // { data_format = formatOverride; }
      else normalized;
  /* Final list of normalized webhook endpoints. */
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
    senpro.monitoring.telegraf.rawInputs.http_listener_v2 = lib.mkIf webhookCfg.enable
      webhookEndpoints;
  };
}
