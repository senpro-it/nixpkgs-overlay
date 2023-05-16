{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "mib-library";
  version = "2023-05-17.005";

  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "mibs";
    rev = "68909c98bef4441c88bf446f0b226bc7e39647b8";
    sha256 = "YyAGlquy3ZEjzZTfImX6YrRXhwyksBPKyTSYbiSEFkA=";
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
