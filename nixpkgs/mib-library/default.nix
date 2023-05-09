{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-05-09";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "1cb9a376378ed1aa79423fcc6036d061a3f9e3aa";
    sha256 = "Jwm7uepbYb3oIgUMyEhvwF3CKcDC/zx4sia6MF3ZWf4=";
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
