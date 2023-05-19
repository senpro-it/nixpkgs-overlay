{ ... }:

{

  imports = [
    ./grafana
    ./heimdall
    ./keycloak
    ./outline
    ./passbolt
    ./traefik
    ./unifi-controller
    ./vaultwarden
  ];

  virtualisation.oci-containers.backend = "docker";

}
