{ ... }:
{
  /* Aggregate all monitoring-related modules. */
  imports = [
    ./fritzinfluxdb.nix
    ./telegraf.nix
    ./svci.nix
    ./unifi-poller.nix
  ];
}
