{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-02-15";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "81a12874ea0eb14428f9c06a300ad71faf5409a7";
    sha256 = "2RqfJuwn2e0xamq+mEQBamqgqh2AXojE10iFxC9Noww=";
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
