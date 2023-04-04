{ stdenv
, lib
, fetchFromGitHub
, bash, curl, jq
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "line-exporters";
  version = "2023-04-04";
  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "line-exporters";
    rev = "b9ad5fe9034bed3cce0b418e86874631886f50f8";
    sha256 = "Nj6xRl7ycigzZ735uldXyzKOJIua8RaiO41wYXJNWJ4=";
  };
  buildInputs = [ bash curl jq ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp dist/sophos-central.sh $out/bin/lxp-sophos-central
    wrapProgram $out/bin/lxp-sophos-central \
      --prefix PATH : ${lib.makeBinPath [ bash curl jq ]}
  '';
}
