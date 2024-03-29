{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      heimdall = {
        enable = mkEnableOption ''
          Whether to enable the heimdall container stack.
        '';
        publicURL = mkOption {
          type = types.str;
          default = "heimdall.local";
          example = "heimdall.example.com";
          description = ''
            Public URL for heimdall. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
      };
    };
  };

  config = mkIf cfg.oci-containers.heimdall.enable {
    virtualisation.oci-containers.containers = {
      heimdall = {
        image = "lscr.io/linuxserver/heimdall:latest";
        autoStart = true;
        extraOptions = [
          "--net=proxy"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.heimdall.tls=true"
          "--label=traefik.http.routers.heimdall.tls.certresolver=letsencrypt"
          "--label=traefik.http.routers.heimdall.entrypoints=https"
          "--label=traefik.http.routers.heimdall.service=heimdall"
          "--label=traefik.http.routers.heimdall.rule=Host(`${cfg.oci-containers.heimdall.publicURL}`)"
          "--label=traefik.http.services.heimdall.loadBalancer.server.port=80"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Berlin";
        };
        volumes = [
          "heimdall:/config"
        ];
      };
    };
  };

}
