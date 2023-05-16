{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-05-17.002";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "ba9faf8c972540b9d5121376947d55cf63cc81a4";
    sha256 = "7PAOgYac0jt2Z8f9IT/fthgaL5ohWiRbCT0luZAdk7w=";
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
