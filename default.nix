self: super:

{
  grafana-kiosk = super.callPackage ./nixpkgs/grafana-kiosk { };
  mib-library = super.callPackage ./nixpkgs/mib-library { };
}
