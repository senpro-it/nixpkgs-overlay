# Leitfaden zur Konfiguration von Telegraf-Endpunkten

Dieser Leitfaden beschreibt, wie neue Telegraf-„Gerät/Endpunkt“-Module unter `nixos/monitoring/telegraf` hinzugefügt werden. Der Fokus liegt auf SNMP-Geräten, aber dieselbe Struktur gilt auch für andere Input-Typen (API, Webhook usw.).

## Verzeichnisstruktur

- `nixos/monitoring/telegraf/snmp/vendors/<vendor>/<device>.nix`
- `nixos/monitoring/telegraf/snmp/default.nix` (importiert die Vendor-Module)
- `nixos/monitoring/telegraf/options.nix` (geteilte Optionen-Helfer)

## Standardstruktur des Moduls

Jedes Endpunkt-Modul sollte demselben Muster folgen:

1. Eine Konfigurations-Subtree und Input-Builder im `let`-Block definieren.
2. Die `options` in einem einzigen Abschnitt definieren.
3. `config`-Einträge definieren, die rohe Inputs unter `senpro.monitoring.telegraf.rawInputs` anhängen.

### Modul-Gerüst

```nix
{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  # Shared config subtree.
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  deviceCfg = snmpCfg.vendors.vendor.device;

  # Build the per-agent SNMP input.
  mkSnmpInput = agent: {
    name = "vendor.device";
    path = [ "${pkgs.mib-library}/opt/mib-library/" ];
    agents = [ agent ];
    timeout = "20s";
    version = 3;
    sec_level = "${deviceCfg.credentials.security.level}";
    sec_name = "${deviceCfg.credentials.security.username}";
    auth_protocol = "${deviceCfg.credentials.authentication.protocol}";
    auth_password = "${deviceCfg.credentials.authentication.password}";
    priv_protocol = "${deviceCfg.credentials.privacy.protocol}";
    priv_password = "${deviceCfg.credentials.privacy.password}";
    retries = 5;
    field = [
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
    ];
    table = [ ];
  };

  # Assemble enabled inputs.
  snmpInputs = telegrafOptions.mkSnmpInputs deviceCfg.endpoints.self mkSnmpInput;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.vendor.device =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Vendor Device monitoring via SNMP.
    '';

  config = {
    senpro.monitoring.telegraf.rawInputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
```

## Schritt für Schritt: Ein neues SNMP-Gerät hinzufügen

1. **Hersteller-Modul erstellen**
   - Füge `nixos/monitoring/telegraf/snmp/vendors/<vendor>/<device>.nix` hinzu.
   - Verwende das Gerüst oben und aktualisiere `name`, `field`, `table` und die Optionsbeschreibung.

2. **Modul verfügbar machen**
   - Füge das Modul zu `nixos/monitoring/telegraf/snmp/default.nix` hinzu.

3. **Gerätekonfiguration definieren**
   - Aktiviere das Gerät in deiner Host-Konfiguration und ergänze Anmeldedaten sowie Agent-Liste.

4. **Struktur prüfen**
   - Stelle sicher, dass der `options`-Abschnitt vor dem `config`-Abschnitt steht.
   - Behalte alle Hilfsfunktionen im `let`-Block.

## Beispiel: SNMP-Monitoring für eine neue Enterprise-Appliance

### Modulausschnitt

```nix
{ config, lib, pkgs, telegrafOptions, ... }:

with lib;

let
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  deviceCfg = snmpCfg.vendors.example.enterpriseAppliance;

  mkSnmpInput = agent: {
    name = "example.enterpriseAppliance";
    path = [ "${pkgs.mib-library}/opt/mib-library/" ];
    agents = [ agent ];
    timeout = "20s";
    version = 3;
    sec_level = "${deviceCfg.credentials.security.level}";
    sec_name = "${deviceCfg.credentials.security.username}";
    auth_protocol = "${deviceCfg.credentials.authentication.protocol}";
    auth_password = "${deviceCfg.credentials.authentication.password}";
    priv_protocol = "${deviceCfg.credentials.privacy.protocol}";
    priv_password = "${deviceCfg.credentials.privacy.password}";
    retries = 5;
    field = [
      { name = "host"; oid = "SNMPv2-MIB::sysName.0"; is_tag = true; }
      { name = "serialNumber"; oid = "EXAMPLE-MIB::serialNumber.0"; }
      { name = "firmwareVersion"; oid = "EXAMPLE-MIB::firmwareVersion.0"; }
    ];
    table = [
      { name = "example.enterpriseAppliance.ifTable"; oid = "IF-MIB::ifTable"; index_as_tag = true; inherit_tags = [ "host" ]; field = [
        { oid = "IF-MIB::ifDescr"; is_tag = true; }
      ]; }
    ];
  };

  snmpInputs = telegrafOptions.mkSnmpInputs deviceCfg.endpoints.self mkSnmpInput;

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.example.enterpriseAppliance =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Example Enterprise Appliance monitoring via SNMP.
    '';

  config = {
    senpro.monitoring.telegraf.rawInputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
```

### Host-Konfigurationsausschnitt

```nix
senpro.monitoring.telegraf.inputs.snmp.vendors.example.enterpriseAppliance = {
  endpoints.self.enable = true;
  endpoints.self.agents = [ "udp://192.0.2.10:161" ];

  credentials.security = {
    level = "authPriv";
    username = "monitor";
  };
  credentials.authentication = {
    protocol = "SHA";
    password = "super-secret-auth";
  };
  credentials.privacy = {
    protocol = "AES";
    password = "super-secret-priv";
  };
};
```

## Tipps und Konventionen

- Gib rohe Input-Payloads unter `senpro.monitoring.telegraf.rawInputs` aus (bereinigt in `nixos/monitoring/telegraf.nix`).
- Halte `name` konsistent (`vendor.device`), damit Dashboards und Output-Filter vorhersehbar bleiben.
- Wenn du mehrere Endpunkttypen benötigst (z. B. Access Points), erstelle zwei `mk...`-Hilfsfunktionen und kombiniere die `telegrafOptions.mkSnmpInputs`-Listen mit `++`.
- Aktualisiere `nixos/monitoring/telegraf/snmp/default.nix`, sobald ein neues Modul hinzugefügt wird.
