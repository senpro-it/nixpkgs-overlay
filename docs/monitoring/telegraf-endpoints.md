# Telegraf endpoint configuration guide

This guide documents how to add new Telegraf “device/endpoint” modules under `nixos/monitoring/telegraf`. It focuses on SNMP devices, but the same structure applies to other input types (API, webhook, etc.).

## Directory layout

- `nixos/monitoring/telegraf/snmp/vendors/<vendor>/<device>.nix`
- `nixos/monitoring/telegraf/snmp/default.nix` (imports the vendor modules)
- `nixos/monitoring/telegraf/options.nix` (shared option helpers)

## Standard module structure

Each endpoint module should follow the same pattern:

1. Define a config subtree and input builders in the `let` block.
2. Define the `options` in a single section.
3. Define `config` entries that append raw inputs under `senpro.monitoring.telegraf.rawInputs`.

### Skeleton module

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

- Emit raw input payloads under `senpro.monitoring.telegraf.rawInputs` (sanitized in `nixos/monitoring/telegraf.nix`).
- Keep `name` consistent (`vendor.device`) so dashboards and output filters stay predictable.
- If you need multiple endpoint types (e.g., access points), create two `mk...` helpers and combine `telegrafOptions.mkSnmpInputs` lists with `++`.
- Update `nixos/monitoring/telegraf/snmp/default.nix` whenever a new module is added.
