# Telegraf input schemas

This directory shares option schemas across Telegraf input modules to keep
vendor configurations consistent and reduce per-plugin boilerplate.

## SNMP vendor schemas

### `mkSnmpV3Options`

Defines the shared SNMPv3 option set for vendor modules:

- `endpoints.self.enable` and `endpoints.self.agents`
- `credentials` with SNMPv3 security/authentication/privilege settings

Reference: https://github.com/influxdata/telegraf/tree/master/plugins/inputs/snmp

### `mkSnmpV2Options`

Defines the shared SNMPv2 option set for vendor modules:

- `endpoints.self.enable` and `endpoints.self.agents`
- `credentials` with SNMPv2 community string

Reference: https://github.com/influxdata/telegraf/tree/master/plugins/inputs/snmp

## Input settings schema

### `mkInputSettingsOption`

Defines a reusable option wrapper for plugin settings submodules. It is used for
inputs like `exec`, `ping`, `internet_speed`, `vsphere`, and local system stats
(`cpu`, `disk`, `mem`, `kernel`, `processes`, `system`).

References:
- https://github.com/influxdata/telegraf/tree/master/plugins/inputs/exec
- https://github.com/influxdata/telegraf/tree/master/plugins/inputs/ping
- https://github.com/influxdata/telegraf/tree/master/plugins/inputs/internet_speed
- https://github.com/influxdata/telegraf/tree/master/plugins/inputs/vsphere
