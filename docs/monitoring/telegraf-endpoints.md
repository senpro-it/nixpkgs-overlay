# Telegraf endpoint configuration guide

This guide documents how to add new Telegraf “device/endpoint” modules under `nixos/monitoring/telegraf`. It focuses on SNMP devices, but the same structure applies to other input types (API, webhook, etc.).

## Directory layout

- `nixos/monitoring/telegraf/snmp/vendors/<vendor>/<device>.nix`
- `nixos/monitoring/telegraf/snmp/default.nix` (imports the vendor modules)
- `nixos/monitoring/telegraf/options.nix` (shared option helpers)

## Standard module structure

Each endpoint module should follow the same pattern:

1. Define a config subtree and shared helpers in the `let` block.
2. Define the `options` in a single section.
3. Define `config` entries that add Telegraf inputs using `snmpInputs`.

### Skeleton module

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  # Shared helpers and config subtree.
  telegrafOptions = import ../../../options.nix { inherit lib; };
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.vendor.device;

  # Build the per-agent SNMP input.
  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
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
  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.vendor.device =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Vendor Device monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
```

## Step-by-step: add a new SNMP device

1. **Create the vendor module**
   - Add `nixos/monitoring/telegraf/snmp/vendors/<vendor>/<device>.nix`.
   - Use the skeleton above and update `name`, `field`, `table`, and the option description.

2. **Expose the module**
   - Add the module to `nixos/monitoring/telegraf/snmp/default.nix`.

3. **Define the device configuration**
   - In your host config, enable the device and fill credentials + agent list.

4. **Verify structure**
   - Ensure the module keeps the `options` section before the `config` section.
   - Keep all helper functions in the `let` block.

## Example: SNMP monitoring for a new enterprise appliance

### Module snippet

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  telegrafOptions = import ../../../options.nix { inherit lib; };
  snmpCfg = config.senpro.monitoring.telegraf.inputs.snmp;
  deviceCfg = config.senpro.monitoring.telegraf.inputs.snmp.vendors.example.enterpriseAppliance;

  mkSnmpInput = agent: telegrafOptions.sanitizeToml {
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

  snmpInputs = lib.optionals deviceCfg.endpoints.self.enable
    (map mkSnmpInput deviceCfg.endpoints.self.agents);

in {
  options.senpro.monitoring.telegraf.inputs.snmp.vendors.example.enterpriseAppliance =
    telegrafOptions.mkSnmpV3Options ''
      Whether to enable the Example Enterprise Appliance monitoring via SNMP.
    '';

  config = {
    services.telegraf.extraConfig.inputs.snmp = lib.mkIf snmpCfg.enable snmpInputs;
  };
}
```

### Host configuration snippet

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

## Tips and conventions

- Prefer `telegrafOptions.sanitizeToml` for any Telegraf configuration payloads.
- Keep `name` consistent (`vendor.device`) so dashboards and output filters stay predictable.
- If you need multiple endpoint types (e.g., access points), create two `mk...` helpers and combine them with `lib.optionals`.
- Update `nixos/monitoring/telegraf/snmp/default.nix` whenever a new module is added.
