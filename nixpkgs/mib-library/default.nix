{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-02-15";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "4d76309dc1802e8e46861cf8a1367d904dac7a2a";
    sha256 = "jyEzkUWLzqnanyDwk7kQXMUpl+b7Z/DS4J+YqEDPia8=";
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
