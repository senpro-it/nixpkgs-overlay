{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-05-17.005";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "c8569e90856573417918a852042ce1f648db07f1";
    hash = "sha256-LAnaXb0mjZ0PZrZGHwKWoLJLl+AiihVODDkTIllvWdE=";
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
