{ stdenv
, lib
, fetchFromGitHub
, bash, curl, jq
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "line-exporters";
  version = "2023-04-03";
  src = fetchFromGitHub {
    owner = "senpro-it";
    repo = "line-exporters";
    rev = "870cff6a05fe39b7f7a5dd103bc33a4283289461";
    sha256 = "sha256-qbfJX3Fj64uDByO/4Ztwg2HLI+wCD8nOJXlDyhTrt0U=";
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
