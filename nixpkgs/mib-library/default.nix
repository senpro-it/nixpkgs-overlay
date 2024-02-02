{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2024-01-11.001";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "b36b4aa81f55658b5b54b80cfe3d5970af0f5b4e";
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
