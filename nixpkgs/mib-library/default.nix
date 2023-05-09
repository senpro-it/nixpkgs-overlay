{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-05-10.001";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "3577722bf2f390768fa104f37ac21eb8b893953c";
    sha256 = "4T0a3lCIayAgT61F2tIQUzEz3970LEfEPZeYHpOvChY=";
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
