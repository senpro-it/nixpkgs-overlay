{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      traefik = {
        enable = mkEnableOption ''
          Whether to enable the `traefik` oci-container.
        '';
        configuration = {
          static = {
            certificatesResolvers = {
              letsEncrypt = {
                acme = {
                  email = mkOption {
                    example = "example@example.com";
                    type = types.str;
                    description = lib.mdDoc "Mail address for alerts regarding expiring certificates.";
                  };
                  dnsChallenge = {
                    provider = mkOption {
                      example = "ionos";
                      type = types.str;
                      description = lib.mdDoc "Provider code for the ACME DNS challenge. Don't forget to provide eventually needed environment variables through ";
                    };
                  };
                };
              };
            };
          };
          dynamic = mkOption {
            default = "";
            type = types.lines;
            description = lib.mdDoc "Additional, user-provided dynamic configuration for Traefik.";
          };
          environment = mkOption {
            type = with types; attrsOf str;
            default = {};
            description = lib.mdDoc "Environment variables to set for the Traefik container.";
            example = literalExpression ''
              {
                IONOS_API_KEY = "43swm2sdxiamsa0djssd6435ccss";
              }
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.oci-containers.traefik.enable {
    boot.kernel.sysctl."net.core.rmem_max" = 2500000;
    systemd.services.podman-traefik-provisioning = {
      enable = true;
      description = "Configuration provisioning for the Traefik container.";
      requiredBy = [ "podman-traefik.service" ];
      restartIfChanged = true;
      preStart = ''
        ${pkgs.coreutils-full}/bin/mkdir /var/lib/containers/storage/volumes/traefik/_data/conf.d
        ${pkgs.coreutils-full}/bin/printf "%s\n" \
          "http:" \
          "  middlewares:" \
          "    httpSecurity:" \
          "      headers:" \
          "        browserXssFilter: true" \
          "        contentTypeNosniff: true" \
          "        frameDeny: true" \
          "        sslRedirect: true" \
          "        stsIncludeSubdomains: true" \
          "        stsPreload: true" \
          "        stsSeconds: 31536000" \
          "        customFrameOptionsValue: SAMEORIGIN" \
          "tls:" \
          "  options:" \
          "    default:" \
          "      cipherSuites:" \
          "      - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" \
          "      - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" \
          "      - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305" \
          "      - TLS_AES_128_GCM_SHA256" \
          "      - TLS_AES_256_GCM_SHA384" \
          "      - TLS_CHACHA20_POLY1305_SHA256" \
          "      curvePreferences:" \
          "      - CurveP521" \
          "      - CurveP384" \
          "      minVersion: VersionTLS12" > /var/lib/containers/storage/volumes/traefik/_data/conf.d/main.yml
          ${pkgs.coreutils-full}/bin/printf "%s\n" "${cfg.oci-containers.traefik.configuration.dynamic}" > /var/lib/containers/storage/volumes/traefik/_data/conf.d/cust.yml
      '';
      serviceConfig = {
        ExecStart = ''
          ${pkgs.coreutils-full}/bin/tail -f /var/lib/containers/storage/volumes/traefik/_data/conf.d/main.yml
        '';
      };
      postStop = ''
        ${pkgs.coreutils-full}/bin/rm -rf /var/lib/containers/storage/volumes/traefik/_data/conf.d
      '';
    };
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "docker.io/library/traefik:v2.10";
        autoStart = true;
        ports = [
          "80:80/tcp" "443:443/tcp" "443:443/udp"
        ];
        extraOptions = [
          "--net=proxy"
        ];
        cmd = [
          "--providers.docker=true"
          "--providers.docker.exposedbydefault=false"
          "--providers.file.directory=/etc/traefik/conf.d"
          "--entrypoints.http.address=:80/tcp"
          "--entrypoints.http.http.redirections.entrypoint.to=https"
          "--entrypoints.http.http.redirections.entrypoint.scheme=https"
          "--entrypoints.https.address=:443"
          "--entrypoints.https.http3.advertisedport=443"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,9.9.9.9:53,8.8.8.8:53"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=${cfg.oci-containers.traefik.configuration.static.certificatesResolvers.letsEncrypt.acme.dnsChallenge.provider}"
          "--certificatesresolvers.letsencrypt.acme.email=${cfg.oci-containers.traefik.configuration.static.certificatesResolvers.letsEncrypt.acme.email}"
          "--certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme.json"
          "--experimental.http3=true"
        ];
        environment = cfg.oci-containers.traefik.configuration.environment;
        volumes = [
          "traefik:/etc/traefik"
          "/run/podman/podman.sock:/var/run/docker.sock"
        ];
      };
    };
  };

}
