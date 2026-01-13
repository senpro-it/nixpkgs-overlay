{ ... }:
{
  imports = [
    ./fritzinfluxdb.nix
    ./telegraf.nix
    ./svci.nix
    ./unifi-poller.nix
  ];
}
