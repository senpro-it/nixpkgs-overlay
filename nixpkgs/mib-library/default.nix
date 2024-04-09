{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2024-04-09.002";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "064f895e887973d3cb41e49e760b1611b296dbdc";
    hash = "sha256-htxBGjzrY/GlHT2uuVGBIqHbsnTQBIro9MtOC73dBoo=";
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
