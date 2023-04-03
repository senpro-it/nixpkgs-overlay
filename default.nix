self: super:

{
  grafana-kiosk = super.callPackage ./nixpkgs/grafana-kiosk { };
  line-exporters = super.callPackage ./nixpkgs/line-exporters { };
  mib-library = super.callPackage ./nixpkgs/mib-library { };
}
