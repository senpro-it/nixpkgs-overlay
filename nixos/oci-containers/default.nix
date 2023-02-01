{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      grafana = {
        enable = mkEnableOption ''
          Whether to enable the homer container stack.
        '';
        rootURL = mkOption {
          type = types.str;
          default = "grafana.local";
          example = "grafana.example.com";
          description = ''
            Public URL for grafana. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
        keycloak = {
          provider = mkOption {
            type = types.str;
            default = "keycloak.local";
            example = "keycloak.example.com";
            description = ''
              URL of the Keycloak OpenID provider. Don't provide protocol, SSL is hardcoded.
            '';
          };
          realm = mkOption {
            type = types.str;
            default = "master";
            example = "grafana";
            description = ''
              Realm to use for authentication against Keycloak.
            '';
          };
        };
      };
      keycloak = {
        enable = mkEnableOption ''
          Whether to enable the homer container stack.
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
          default = "grafana.local";
          example = "grafana.example.com";
          description = ''
            Public URL for grafana. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
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
      outline = {
        enable = mkEnableOption ''
          Whether to enable the outline container stack.
        '';
        secret = mkOption {
          type = types.str;
          default = "25e3054f0c1659248f8c41e6ea679c1287a90f5f9c3bef532305ffbe05f02d0a";
          example = "f39a6d934d46797ad71a76423e79c5c44695557390e20d46c9c9282255a274f9";
          description = ''
            Generate a hex-encoded 32-byte random key. You should use `openssl rand -hex 32` in your terminal to generate a random value.
          '';
        };
        utils_secret = mkOption {
          type = types.str;
          default = "15e36e6b1bb569792dbcf9a77e35a37f53f475fec696a6d9eb7d5147549a2e24";
          example = "da372e088bd54e72419d04ea53d89a595863ca792169d4108aefcd65061bebe7";
          description = ''
            Generate a unique random key. The format is not important but you could still use `openssl rand -hex 32` in your terminal to produce this.
          '';
        };
        publicURL = mkOption {
          type = types.str;
          default = "outline.local";
          example = "outline.example.com";
          description = ''
            Public URL for outline. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
        minio = {
          password = mkOption {
            type = types.str;
            default = "6e57eac19a0978b574bdc12b16b92aa3abd2ba8283d891ec4a3046ff6da8f3c0";
            example = "6c3c18d7c7f1a95af2dee9949582b55ba3e3361118f600b0c9d518d6d217e597";
            description = ''
              Password for the accessing the minio data storage. 
            '';
          };
          adminConsoleURL = mkOption {
            type = types.str;
            default = "admin.minio.local";
            example = "admin.minio.example.com";
            description = ''
              Admin console URL of minio. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded.
            '';
          };
          uploadBucketURL = mkOption {
            type = types.str;
            default = "minio.local";
            example = "minio.example.com";
            description = ''
              Upload Bucket URL of minio. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded.
            '';
          };
        };
        postgres = {
          password = mkOption {
            type = types.str;
            default = "19ca4fb81ae676c2f4b46fe03688348b0aa0ce160360e72856ccc8e45cc2009b";
            example = "ed2fca67ff7730576ea626b63b0cf7d313450a934f651562c18bd6d8f035fb89";
            description = ''
              Password for the accessing the PostgreSQL database. 
            '';
          };
        };
        smtp = {
          host = mkOption {
            type = types.str;
            default = "mail.local";
            example = "mail.example.com";
            description = ''
              FQDN of the SMTP mail server for sending mails.
            '';
          };
          port = mkOption {
            type = types.port;
            default = 465;
            example = 587;
            description = ''
              TCP port which outline will use to connect to the mail server.
            '';
          };
          from = mkOption {
            type = types.str;
            default = "outline@mail.local";
            example = "example@example.com";
            description = ''
              SMTP FROM address outline will send with.
            '';
          };
          username = mkOption {
            type = types.str;
            default = "user";
            example = "example@example.com";
            description = ''
              SMTP user outline will use to login.
            '';
          };
          password = mkOption {
            type = types.str;
            default = "Unn8QwQqKN42kzR6ZRRlMNfv1L9J0WerTz00bw8eSZVdA84N0cJ1IFUr52EwQniN";
            example = "AJD7mmpqEApBCcDMqMH1fGdzc96JAlyBuqgXumFfhzmAevvyPhxRkfyVT33F4vUk";
            description = ''
              Password of the SMTP user outline will use to login.
            '';
          };
        };
      };
      vaultwarden = {
        enable = mkEnableOption ''
          Whether to enable the homer container stack.
        '';
        adminToken = mkOption {
          type = types.str;
          example = "YOUR_ADMIN_TOKEN";
          description = ''
            Admin token for the vaultwarden admin page. Should be a very strong password, because accessing this page you have full control over vaultwarden.
          '';
        };
        hibpApiKey = mkOption {
          type = types.str;
          example = "YOUR_API_KEY";
          description = ''
            API key for vaultwarden to connect to HIBP (haveibeenpwned.com).
          '';
        };
        publicURL = mkOption {
          type = types.str;
          default = "grafana.local";
          example = "grafana.example.com";
          description = ''
            Public URL for vaultwarden. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
        smtp = {
          host = mkOption {
            type = types.str;
            default = "mail.local";
            example = "mail.example.com";
            description = ''
              FQDN of the SMTP mail server for sending mails.
            '';
          };
          port = mkOption {
            type = types.port;
            default = 465;
            example = 587;
            description = ''
              TCP port which vaultwarden will use to connect to the mail server.
            '';
          };
          from = mkOption {
            type = types.str;
            default = "vaultwarden@mail.local";
            example = "vaultwarden@example.com";
            description = ''
              SMTP FROM address vaultwarden will send with.
            '';
          };
          username = mkOption {
            type = types.str;
            default = "user";
            example = "vaultwarden@example.com";
            description = ''
              SMTP user vaultwarden will use to login.
            '';
          };
          password = mkOption {
            type = types.str;
            default = "ZsCuGfqr1QGSVnYNBsgpONELlwC1kRnVgH5dqPOGXlRKp2Hkqld2htIVDHZJogBg";
            example = "WsVWW1ix80QX06Wi50zoCQZIE5cpNGhIq3thkA2zjFx7yC63iRhlBqFupRsukiCe";
            description = ''
              Password of the SMTP user vaultwarden will use to login.
            '';
          };
          displayName = mkOption {
            type = types.str;
            default = "Vaultwarden";
            example = "Vaultwarden";
            description = ''
              Display name of the SMTP FROM address.
            '';
          };
        };
      };
    };
  };

  config = {
    services.traefik = lib.mkIf (cfg.oci-containers != {}) {
      enable = true;
      group = "podman";
      staticConfigOptions = {
        entryPoints = {
          http2-tcp = {
            address = ":80/tcp";
            http = {
              redirections = {
                entryPoint = {
                  to = "https2-tcp";
                  scheme = "https";
                };
              };
            };
          };
          https2-tcp = {
            address = ":443/tcp";
          };
        };
        experimental = {
          http3 = true;
        };
        providers = {
          docker = {
            endpoint = "unix:///run/podman/podman.sock";
          };
        };
      };
      dynamicConfigOptions = {
        http = {
          middlewares = {
            httpsSec = {
              headers = {
                browserXssFilter = true;
                contentTypeNosniff = true;
                frameDeny = true;
                sslRedirect = true;
                stsIncludeSubdomains = true;
                stsPreload = true;
                stsSeconds = 31536000;
                customFrameOptionsValue = "SAMEORIGIN";
              };
            };
          };
        };
        tls = {
          options = {
            default = {
              cipherSuites = [
                "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
                "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
                "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
                "TLS_AES_128_GCM_SHA256"
                "TLS_AES_256_GCM_SHA384"
                "TLS_CHACHA20_POLY1305_SHA256"
              ];
              curvePreferences = [
                "CurveP521"
                "CurveP384"
              ];
              minVersion = "VersionTLS12";
            };
          };
        };
      };
    };
    systemd.services = lib.mkIf (cfg.oci-containers != {}) {
      "podman-network-proxy" = {
        serviceConfig.Type = "oneshot";
          wantedBy = [ "traefik.service" ];
          script = ''
            ${pkgs.podman}/bin/podman network inspect proxy > /dev/null 2>&1 || ${pkgs.podman}/bin/podman network create --ipv6 --gateway fd01::1 --subnet fd01::/80 \
              --gateway 10.90.0.1 --subnet 10.90.0.0/16 proxy
          '';
      };
    };
    virtualisation.oci-containers.containers = lib.mkIf (cfg.oci-containers != {}) (lib.mkMerge [
      (lib.mkIf cfg.oci-containers.grafana.enable {
        grafana = {
          image = "docker.io/grafana/grafana:latest";
          autoStart = true;
          user = "104:104";
          dependsOn = [
            "grafana-influxdb"
          ];
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.grafana.tls=true"
            "--label=traefik.http.routers.grafana.entrypoints=https2-tcp"
            "--label=traefik.http.routers.grafana.service=grafana"
            "--label=traefik.http.routers.grafana.rule=Host(`${cfg.oci-containers.grafana.rootURL}`)"
            "--label=traefik.http.services.outline.loadBalancer.server.port=3000"
          ];
          environment = {
            GF_USERS_ALLOW_SIGN_UP = "true";
            GF_USERS_AUTO_ASSIGN_ORG = "true";
            GF_USERS_AUTO_ASSIGN_ORG_ROLE = "Viewer";
            GF_AUTH_DISABLE_LOGIN_FORM = "true";
            GF_AUTH_GENERIC_OAUTH_ENABLED = "true";
            GF_AUTH_GENERIC_OAUTH_NAME = "OAuth2";
            GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "false";
            GF_AUTH_GENERIC_OAUTH_CLIENT_ID = "";
            GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = "";
            GF_AUTH_GENERIC_OAUTH_SCOPES = "email profile offline_access roles";
            GF_AUTH_GENERIC_OAUTH_AUTH_URL = "https://${cfg.oci-containers.grafana.keycloak.provider}/realms/${cfg.oci-containers.grafana.keycloak.realm}/protocol/openid-connect/auth";
            GF_AUTH_GENERIC_OAUTH_TOKEN_URL = "https://${cfg.oci-containers.grafana.keycloak.provider}/realms/${cfg.oci-containers.grafana.keycloak.realm}/protocol/openid-connect/token";
            GF_AUTH_GENERIC_OAUTH_API_URL = "https://${cfg.oci-containers.grafana.keycloak.provider}/realms/${cfg.oci-containers.grafana.keycloak.realm}/protocol/openid-connect/userinfo";
            GF_SERVER_ROOT_URL = "https://${cfg.oci-containers.grafana.rootURL}";
            GF_PANELS_DISABLE_SANITIZE_HTML = "true";
            GF_FEATURE_TOGGLES_ENABLE = "internationalization";
          };
          volumes = [
            "grafana:/etc/grafana/provisioning"
            "grafana-data:/var/lib/grafana"
          ];
        };
        grafana-influxdb = {
          image = "docker.io/library/influxdb:latest";
          autoStart = true;
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.grafana-influxdb.tls=true"
            "--label=traefik.http.routers.grafana-influxdb.entrypoints=https2-tcp"
            "--label=traefik.http.routers.grafana-influxdb.service=grafana-influxdb"
            "--label=traefik.http.routers.grafana-influxdb.rule=Host(`${cfg.oci-containers.grafana.influxdb.publicURL}`)"
            "--label=traefik.http.services.outline-minio.loadBalancer.server.port=8086"
          ];
          volumes = [
            "grafana-influxdb:/etc/influxdb2"
            "grafana-influxdb-data:/var/lib/influxdb2"
          ];
        };
      })
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
      (lib.mkIf cfg.oci-containers.outline.enable {
        outline = {
          image = "docker.io/outlinewiki/outline:latest";
          autoStart = true;
          user = "root";
          cmd = [ "yarn" "start" "--env=production-ssl-disabled" ];
          dependsOn = [
            "outline-minio"
            "outline-redis"
            "outline-postgres"
          ];
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.outline.tls=true"
            "--label=traefik.http.routers.outline.entrypoints=https2-tcp"
            "--label=traefik.http.routers.outline.service=outline"
            "--label=traefik.http.routers.outline.rule=Host(`${cfg.oci-containers.outline.publicURL}`)"
            "--label=traefik.http.services.outline.loadBalancer.server.port=3000"
          ];
          environment = {
            SECRET_KEY = "${cfg.oci-containers.outline.secret}";
            UTILS_SECRET = "${cfg.oci-containers.outline.utils_secret}";
            PGSSLMODE = "disable";
            DATABASE_URL = "postgres://outline:${cfg.oci-containers.outline.postgres.password}@outline-postgres:5432/outline";
            REDIS_URL = "redis://outline-redis:6379";
            URL = "https://${cfg.oci-containers.outline.publicURL}";
            PORT = "3000";
            FORCE_HTTPS = "false";
            AWS_ACCESS_KEY_ID = "minio";
            AWS_REGION = "eu-west-1";
            AWS_SECRET_ACCESS_KEY = "${cfg.oci-containers.outline.minio.password}";
            AWS_S3_UPLOAD_BUCKET_URL = "https://${cfg.oci-containers.outline.minio.uploadBucketURL}";
            AWS_S3_UPLOAD_BUCKET_NAME = "outline";
            AWS_S3_UPLOAD_MAX_SIZE = "26214400";
            AWS_S3_FORCE_PATH_STYLE = "true";
            AWS_S3_ACL = "private";
            SMTP_HOST = "${cfg.oci-containers.outline.smtp.host}";
            SMTP_PORT = "${toString cfg.oci-containers.outline.smtp.port}";
            SMTP_USERNAME = "${cfg.oci-containers.outline.smtp.username}";
            SMTP_PASSWORD = "${cfg.oci-containers.outline.smtp.password}";
            SMTP_FROM_EMAIL = "${cfg.oci-containers.outline.smtp.from}";
          };
        };
        outline-minio = {
          image = "quay.io/minio/minio:latest";
          autoStart = true;
          cmd = [ "server" "/data" "--console-address" ":9001" ];
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.outline-minio.tls=true"
            "--label=traefik.http.routers.outline-minio.entrypoints=https2-tcp"
            "--label=traefik.http.routers.outline-minio.service=outline-minio"
            "--label=traefik.http.routers.outline-minio.rule=Host(`${cfg.oci-containers.outline.minio.uploadBucketURL}`)"
            "--label=traefik.http.services.outline-minio.loadBalancer.server.port=9000"
            "--label=traefik.http.routers.outline-minio-console.tls=true"
            "--label=traefik.http.routers.outline-minio-console.entrypoints=https2-tcp"
            "--label=traefik.http.routers.outline-minio-console.service=outline-minio-console"
            "--label=traefik.http.routers.outline-minio-console.rule=Host(`${cfg.oci-containers.outline.minio.adminConsoleURL}`)"
            "--label=traefik.http.services.outline-minio-console.loadBalancer.server.port=9001"
          ];
          environment = {
            MINIO_ROOT_USER = "minio";
            MINIO_ROOT_PASSWORD = "${cfg.oci-containers.outline.minio.password}";
            MINIO_BROWSER_REDIRECT_URL = "https://${cfg.oci-containers.outline.minio.adminConsoleURL}";
          };
          volumes = [ "outline-minio-data:/data" ];
        };
        outline-redis = {
          image = "docker.io/library/redis:latest";
          autoStart = true;
          extraOptions = [ "--net=proxy" ];
        };
        outline-postgres = {
          image = "docker.io/library/postgres:latest";
          autoStart = true;
          extraOptions = [ "--net=proxy" ];
          environment = {
            POSTGRES_DB = "outline";
            POSTGRES_USER = "outline";
            POSTGRES_PASSWORD = "${cfg.oci-containers.outline.postgres.password}";
          };
          volumes = [ "outline-postgres-data:/var/lib/postgresql/data" ];
        };
      })
      (lib.mkIf cfg.oci-containers.vaultwarden.enable {
        vaultwarden = {
          image = "docker.io/vaultwarden/server:latest";
          autoStart = true;
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.vaultwarden.tls=true"
            "--label=traefik.http.routers.vaultwarden.entrypoints=https2-tcp"
            "--label=traefik.http.routers.vaultwarden.service=vaultwarden"
            "--label=traefik.http.routers.vaultwarden.rule=Host(`${cfg.oci-containers.vaultwarden.publicURL}`)"
            "--label=traefik.http.services.vaultwarden.loadBalancer.server.port=80"
          ];
          environment = {
            ORG_EVENTS_ENABLED = "true";
            ORG_GROUPS_ENABLED = "true";
            HIBP_API_KEY = "${cfg.vaultwarden.hibpApiKey}";
            DOMAIN = "https://${cfg.oci-containers.vaultwarden.publicURL}";
            SIGNUPS_ALLOWED = "false";
            SMTP_HOST = "${cfg.vaultwarden.smtp.host}";
            SMTP_PORT = "${toString cfg.vaultwarden.smtp.port}";
            SMTP_FROM = "${cfg.vaultwarden.smtp.from}";
            SMTP_FROM_NAME = "${cfg.vaultwarden.smtp.displayName}";
            SMTP_SECURITY = "${cfg.vaultwarden.smtp.security}";
            SMTP_USERNAME = "${cfg.vaultwarden.smtp.username}";
            SMTP_PASSWORD = "${cfg.vaultwarden.smtp.password}";
            WEBSOCKET_ENABLED = "true";
            ADMIN_TOKEN = "${cfg.vaultwarden.adminToken}";
            DATABASE_URL = "postgresql://vaultwarden:${cfg.oci-containers.vaultwarden.postgres.password}@vaultwarden-postgres:5432/vaultwarden";
          };
          volumes = [ "vaultwarden-data:/data" ];
        };
        vaultwarden-postgres = {
          image = "docker.io/library/postgres:latest";
          autoStart = true;
          extraOptions = [
            "--net=proxy"
          ];
          environment = {
            POSTGRES_DB = "vaultwarden";
            POSTGRES_USER = "vaultwarden";
            POSTGRES_PASSWORD = "${cfg.oci-containers.vaultwarden.postgres.password}";
          };
          volumes = [ "vaultwarden-postgres-data:/var/lib/postgresql/data" ];
        };
      })
    ]);
  };

}