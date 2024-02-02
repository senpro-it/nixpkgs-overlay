{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2024-01-11.001";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "1727d7daa390aaa7da63af43d0c9f74dd77b18a2";
    hash = "sha256-NutCf2zsgh6dkWABzrD7DkETOWdMolwG58iMFuoJ1m0=";
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
