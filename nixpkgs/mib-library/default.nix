{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-02-06";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "ac142927feb6d7007f5a713c45058492b8710c82";
    sha256 = "BlGR35chiaKxw4NFbaZ4aiUwXgpcss7vZDO6CFNPRpg=";
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
