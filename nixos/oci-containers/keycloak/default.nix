{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      keycloak = {
        enable = mkEnableOption ''
          Whether to enable the keycloak container stack.
        '';
        admin = {
          username = mkOption {
            type = types.str;
            default = "admin";
            example = "admin";
            description = ''
              Username for the Keycloak admin.
            '';
          };
          password = mkOption {
            type = types.str;
            default = "rfu5Y9V3MMVec0KL0o3HQCJWyCCr2q5X5E5gwlBFPgtDz76jK2yl8n5nWIUCxBj4";
            example = "9FMEsaVjZKRBDUgHTSkAqtJiEGcpS5xrnAV12QuWFSjd8lZYYuf8Q7EZlHup07QF";
            description = ''
              Password for the Keycloak admin. Note that the password is stored world-readable in the nix-store!
            '';
          };
        };
        publicURL = mkOption {
          type = types.str;
          default = "keycloak.local";
          example = "keycloak.example.com";
          description = ''
            Public URL for keycloak. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
        postgres = {
          password = mkOption {
            type = types.str;
            default = "br5IKE3bHtsPFgZoVloNe83fDCh6qMMTSlVFE7J4v6MTBuzQaIZxXgJM5qb9149B";
            example = "q45wwFdmPkmbE0nMV71KDe31YxLl7WPKarKynG25r906wJVRN6eNVwNpiwkrWv1u";
            description = ''
              Password for the PostgreSQL database user. A length of at least 16 characters is strongly recommended.
            '';
          };
        };
      };
    };
  };

  config = {
    virtualisation.oci-containers.containers = lib.mkIf (cfg.oci-containers != {}) (lib.mkMerge [
      (lib.mkIf cfg.oci-containers.keycloak.enable {
        keycloak = {
          image = "quay.io/keycloak/keycloak:latest";
          autoStart = true;
          cmd = [ "start" "--auto-build" ];
          dependsOn = [
            "keycloak-postgres"
          ];
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.keycloak.tls=true"
            "--label=traefik.http.routers.keycloak.entrypoints=https2-tcp"
            "--label=traefik.http.routers.keycloak.service=keycloak"
            "--label=traefik.http.routers.keycloak.rule=Host(`${cfg.oci-containers.keycloak.publicURL}`)"
            "--label=traefik.http.services.keycloak.loadBalancer.server.port=8080"
          ];
          environment = {
            KC_DB = "postgres";
            KC_DB_URL = "jdbc:postgresql://keycloak-postgres:5432/keycloak";
            KC_DB_USER = "keycloak";
            KC_DB_SCHEMA = "public";
            KC_DB_PASSWORD = "${cfg.oci-containers.keycloak.postgres.password}";
            KC_HOSTNAME = "${cfg.oci-containers.keycloak.publicURL}";
            KEYCLOAK_ADMIN = "${cfg.oci-containers.keycloak.admin.username}";
            KEYCLOAK_ADMIN_PASSWORD = "${cfg.oci-containers.keycloak.admin.password}";
            KC_PROXY = "edge";
          };
        };
        keycloak-postgres = {
          image = "docker.io/library/postgres:latest";
          autoStart = true;
          extraOptions = [
            "--net=proxy"
          ];
          environment = {
            POSTGRES_DB = "keycloak";
            POSTGRES_USER = "keycloak";
            POSTGRES_PASSWORD = "${cfg.oci-containers.keycloak.postgres.password}";
          };
          volumes = [ "keycloak-postgres-data:/var/lib/postgresql/data" ];
        };
      })
    ]);
  };

}
