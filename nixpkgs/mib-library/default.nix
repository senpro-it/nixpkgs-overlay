{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2024-02-05.001";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "969e1ee58a74bfcde531802fe201e371c9dfd2d8";
    hash = "sha256-mHGwj2NdrCDU2I8SP3YkWiME+NwqJyCk5y72GCguTBY=";
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
