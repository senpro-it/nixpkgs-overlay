{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2024-04-09.002";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "24ad4fa9e011ac42e2a0e441cd970d37786a15bf";
    hash = "sha256-XheMQnXpCoEisTfX2J6KWBzChxPrOM1tJwYtzhQv0S0=";
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
