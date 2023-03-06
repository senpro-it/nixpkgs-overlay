{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      vaultwarden = {
        enable = mkEnableOption ''
          Whether to enable the vaultwarden container stack.
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
        mariadb = {
          password = mkOption {
            type = types.str;
            default = "tqRD58vxHIZXlRPelUqSCloiBVN3XMAvtQLmt2t4RP21hHlcH4ooJLRUKc3Ywy6x";
            example = "isWDkwROM9fmYjdZZmnQy8lGE8Wv9D6rjlxgCxOy7sJ6c61OkNudy6EwvifAcFxy";
            description = ''
              Password for accessing the MariaDB database.
            '';
          };
          rootPassword = mkOption {
            type = types.str;
            default = "el6UtF1ACSfqeTLia7YZ2jTynuYmUQaiVvxedBf5gfPfkZriVk4sDmWhglvClABz";
            example = "z9QcJv83WYshZzVFhrEC9W0RcCYhSABDS9Be3lpPPrcq9g7k7a6BaLWTe9CL0EG5";
            description = ''
              Root password for the MariaDB database.
            '';
          };
        };
        postgres = {
          password = mkOption {
            type = types.str;
            default = "ymjnfiatqpbjiqgd97nl9mb5dyjoldeh4b6lsp63veahp2wjpq6nhkafd3p59ph4";
            example = "ymjnfiatqpbjiqgd97nl9mb5dyjoldeh4b6lsp63veahp2wjpq6nhkafd3p59ph4";
            description = ''
              Password for accessing the PostgreSQL database.
            '';
          };
        };
        publicURL = mkOption {
          type = types.str;
          default = "vaultwarden.local";
          example = "vaultwarden.example.com";
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
          tlsPolicy = mkOption {
            type = types.enum [ "force_tls" "starttls" "off" ];
            default = "force_tls";
            description = ''
              Whether vaultwarden should use implicit or explicit TLS or not use TLS encryption at all.
              See <https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration> for further explanations about the possible values.
            '';
          };
        };
      };
    };
  };

  config = {
    systemd.services = lib.mkIf (cfg.oci-containers != {}) {
      "podman-vaultwarden-healthcheck" = lib.mkIf cfg.oci-containers.vaultwarden.enable {
        serviceConfig.Type = "oneshot";
          script = ''
            ${pkgs.podman}/bin/podman healthcheck run vaultwarden
          '';
      };
    };
    systemd.timers."podman-vaultwarden-healthcheck" = lib.mkIf cfg.oci-containers.vaultwarden.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/1";
        Unit = "podman-vaultwarden-healthcheck.service";
      };
    };
    virtualisation.oci-containers.containers = lib.mkIf (cfg.oci-containers != {}) (lib.mkMerge [
      (lib.mkIf cfg.oci-containers.vaultwarden.enable {
        vaultwarden = {
          image = "docker.io/vaultwarden/server:latest";
          autoStart = true;
          dependsOn = [
            "vaultwarden-postgres"
          ];
          extraOptions = [
            "--net=proxy"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.vaultwarden.tls=true"
            "--label=traefik.http.routers.vaultwarden.tls.certresolver=letsEncrypt"
            "--label=traefik.http.routers.vaultwarden.entrypoints=https2-tcp"
            "--label=traefik.http.routers.vaultwarden.service=vaultwarden"
            "--label=traefik.http.routers.vaultwarden.rule=Host(`${cfg.oci-containers.vaultwarden.publicURL}`)"
            "--label=traefik.http.services.vaultwarden.loadBalancer.server.port=80"
            "--label=traefik.http.routers.vaultwarden-websocket.tls=true"
            "--label=traefik.http.routers.vaultwarden-websocket.entrypoints=https2-tcp"
            "--label=traefik.http.routers.vaultwarden-websocket.service=vaultwarden-websocket"
            "--label=traefik.http.routers.vaultwarden-websocket.rule=Host(`${cfg.oci-containers.vaultwarden.publicURL}`) && Path(`/notifications/hub`)"
            "--label=traefik.http.services.vaultwarden-websocket.loadBalancer.server.port=3012"
            "--healthcheck-retries=10"
            "--healthcheck-interval=60s"
            "--healthcheck-start-period=1m"
            "--healthcheck-command=curl http://localhost:80/alive || exit 1"
          ];
          environment = {
            HIBP_API_KEY = "${cfg.oci-containers.vaultwarden.hibpApiKey}";
            DOMAIN = "https://${cfg.oci-containers.vaultwarden.publicURL}";
            SIGNUPS_ALLOWED = "false";
            SMTP_HOST = "${cfg.oci-containers.vaultwarden.smtp.host}";
            SMTP_PORT = "${toString cfg.oci-containers.vaultwarden.smtp.port}";
            SMTP_FROM = "${cfg.oci-containers.vaultwarden.smtp.from}";
            SMTP_FROM_NAME = "${cfg.oci-containers.vaultwarden.smtp.displayName}";
            SMTP_SECURITY = "${cfg.oci-containers.vaultwarden.smtp.tlsPolicy}";
            SMTP_USERNAME = "${cfg.oci-containers.vaultwarden.smtp.username}";
            SMTP_PASSWORD = "${cfg.oci-containers.vaultwarden.smtp.password}";
            WEBSOCKET_ENABLED = "true";
            ADMIN_TOKEN = "${cfg.oci-containers.vaultwarden.adminToken}";
            DATABASE_URL = "/data/db.sqlite3";
          };
          volumes = [ "vaultwarden-data:/data" ];
        };
        vaultwarden-mariadb = {
          image = "docker.io/library/mariadb:latest";
          autoStart = true;
          extraOptions = [
            "--net=proxy"
          ];
          environment = {
            MARIADB_DATABASE = "vaultwarden";
            MARIADB_USER = "vaultwarden";
            MARIADB_PASSWORD = "${cfg.oci-containers.vaultwarden.mariadb.password}";
            MARIADB_ROOT_PASSWORD = "${cfg.oci-containers.vaultwarden.mariadb.rootPassword}";
          };
          volumes = [ "vaultwarden-mariadb-data:/var/lib/mysql" ];
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
