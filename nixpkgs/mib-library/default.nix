{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-02-13";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "6f598316b7e973cc979698363c1a043cc14a560b";
    sha256 = "wv7xZgZE+jRKPhz9czMEdVI5PXzTCk4DFonCKSeFmpw=";
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
