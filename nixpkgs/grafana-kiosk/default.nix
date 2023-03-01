{ lib
, buildGoModule
, fetchFromGitHub
, chromium, makeWrapper
}:

buildGoModule rec {
  pname = "grafana-kiosk";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "grafana-kiosk";
    rev = "v${version}";
    sha256 = "N3iSfUEuk7VaNi40oLbBcSSmwKdrjr3v69LUVGRAIDY=";
  };
  vendorSha256 = "sha256-EISfSQHro8hDHN+UR6uS15Lsd158r+RkvmPEi3F6dfo=";

  subPackages = [ "./pkg/cmd/grafana-kiosk" ];

  buildInputs = [ makeWrapper ];
  nativebuildInputs = [ chromium ];

  postInstall = ''
    wrapProgram $out/bin/grafana-kiosk \
      --prefix PATH : ${lib.makeBinPath [ chromium ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/grafana/grafana-kiosk";
    description = " Kiosk Utility for Grafana";
    changelog = "https://github.com/grafana/grafana-kiosk/blob/main/CHANGELOG.md";
    license = licenses.asl20;
  };
}
