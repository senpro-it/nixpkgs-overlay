{ ... }:

{

  imports = [
    ./grafana
    ./heimdall
    ./traefik
    ./unifi-controller
  ];

  virtualisation.oci-containers.backend = "docker";

}
