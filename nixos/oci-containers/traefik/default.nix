{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      traefik = {
        enable = mkEnableOption ''
          Whether to enable the `traefik` oci-container.
        '';
        configuration = mkOption {
          default = "";
          type = types.lines;
          description = lib.mdDoc "Additional configuration for Traefik beside the default config";
        };
      };
    };
  };

  config = mkIf cfg.oci-containers.traefik.enable {
    boot.kernel.sysctl."net.core.rmem_max" = 2500000;
    systemd.services.podman-traefik-dynamic = {
      enable = true;
      description = "Dynamic config provisioning for Traefik";
      after = [ "podman-traefik.service" ];
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
          ${pkgs.coreutils-full}/bin/printf "%s\n" "${cfg.oci-containers.traefik.configuration}" > /var/lib/containers/storage/volumes/traefik/_data/conf.d/cust.yml
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
        image = "docker.io/library/traefik:v2.9";
        autoStart = true;
        ports = [
          "80:80/tcp" "443:443/tcp" "443:443/udp"
        ];
        extraOptions = [
          "--net=proxy"
        ];
        environment = {
          TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_HTTPCHALLENGE_ENTRYPOINT = "http";
          TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS = ":80/tcp";
          TRAEFIK_ENTRYPOINTS_HTTP_HTTP_REDIRECTIONS_ENTRYPOINT_SCHEME = "https";
          TRAEFIK_ENTRYPOINTS_HTTP_HTTP_REDIRECTIONS_ENTRYPOINT_TO = "https";
          TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS = ":443";
          TRAEFIK_ENTRYPOINTS_HTTPS_HTTP3_ADVERTISEDPORT = "443";
          TRAEFIK_EXPERIMENTAL_HTTP3 = "true";
          TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT = "false";
          TRAEFIK_PROVIDERS_FILE_DIRECTORY = "/etc/traefik/conf.d";
        };
        volumes = [
          "traefik:/etc/traefik"
          "/run/podman/podman.sock:/var/run/docker.sock"
        ];
      };
    };
  };

}
