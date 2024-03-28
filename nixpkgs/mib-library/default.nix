{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2024-02-05.001";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "fdb5f6905812a39e626fa27e3cdd1db0d5585de0";
    hash = "sha256-RW335nVucV85urvFzMDVsSyHi0Z2E6/PmeBwoaErmto=";
  };

  installPhase = ''
    mkdir -vp "$out/opt/mib-library"
    cp -v dist/* $out/opt/mib-library/
  '';

  meta = with lib; {
    license = licenses.free;
    description = "Library of MIB files for SNMP monitoring.";
  };
}
