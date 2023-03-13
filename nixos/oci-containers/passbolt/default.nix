{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      passbolt = {
        enable = mkEnableOption ''
          Whether to enable the passbolt container stack.
        '';
        publicURL = mkOption {
          type = types.str;
          default = "passbolt.local";
          example = "passbolt.example.com";
          description = ''
            Public URL for passbolt. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded.
          '';
        };
        mariadb = {
          password = mkOption {
            type = types.str;
            default = "lGkR3PiyLUZJdFdBn343L0BkZFpnbQGzbZealUbpZtMdhVqZJDhIXGA5MxjLIWj4";
            example = "O7TYYBvANNTZoAfETc5jDgPaFQrqtmhQbrM1KJ1eUfjZJCBIrTeABjYeDAPfcYI7";
            description = ''
              Password for the MariaDB database passbolt should connect to.
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
              TCP port which passbolt will use to connect to the mail server.
            '';
          };
          from = mkOption {
            type = types.str;
            default = "passbolt@mail.local";
            example = "example@example.com";
            description = ''
              SMTP FROM address passbolt will send with.
            '';
          };
          username = mkOption {
            type = types.str;
            default = "user";
            example = "example@example.com";
            description = ''
              SMTP user passbolt will use to login.
            '';
          };
          password = mkOption {
            type = types.str;
            default = "Unn8QwQqKN42kzR6ZRRlMNfv1L9J0WerTz00bw8eSZVdA84N0cJ1IFUr52EwQniN";
            example = "AJD7mmpqEApBCcDMqMH1fGdzc96JAlyBuqgXumFfhzmAevvyPhxRkfyVT33F4vUk";
            description = ''
              Password of the SMTP user passbolt will use to login.
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.oci-containers.passbolt.enable {
    virtualisation.oci-containers.containers = {
      passbolt = {
        image = "docker.io/passbolt/passbolt:3.11.1-1-ce";
        autoStart = true;
        dependsOn = [
          "passbolt-mariadb"
        ];
        extraOptions = [
          "--net=proxy"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.passbolt.tls=true"
          "--label=traefik.http.routers.passbolt.entrypoints=https"
          "--label=traefik.http.routers.passbolt.service=passbolt"
          "--label=traefik.http.routers.passbolt.rule=Host(`${cfg.oci-containers.passbolt.publicURL}`)"
          "--label=traefik.http.services.passbolt.loadBalancer.server.port=80"
        ];
        environment = {
          APP_FULL_BASE_URL = "https://${cfg.oci-containers.passbolt.publicURL}";
          DATASOURCES_DEFAULT_HOST = "passbolt-mariadb";
          DATASOURCES_DEFAULT_DATABASE = "passbolt";
          DATASOURCES_DEFAULT_USERNAME = "passbolt";
          DATASOURCES_DEFAULT_PASSWORD = "${cfg.oci-containers.passbolt.mariadb.password}";
          EMAIL_DEFAULT_FROM = "${cfg.oci-containers.passbolt.smtp.from}";
          EMAIL_TRANSPORT_DEFAULT_HOST = "${cfg.oci-containers.passbolt.smtp.host}";
          EMAIL_TRANSPORT_DEFAULT_PORT = "${toString cfg.oci-containers.passbolt.smtp.port}";
          EMAIL_TRANSPORT_DEFAULT_USERNAME = "${cfg.oci-containers.passbolt.smtp.username}";
          EMAIL_TRANSPORT_DEFAULT_PASSWORD = "${cfg.oci-containers.passbolt.smtp.password}";
          EMAIL_TRANSPORT_DEFAULT_TLS = "true";          
        };
        volumes = [ "passbolt-data-gpg:/etc/passbolt/gpg" "passbolt-data-jwt:/etc/passbolt/jwt" ];
      };
      passbolt-mariadb = {
        image = "docker.io/library/mariadb:10.3";
        autoStart = true;
        extraOptions = [
          "--net=proxy"
        ];
        environment = {
          MYSQL_RANDOM_ROOT_PASSWORD = "true";
          MYSQL_DATABASE = "passbolt";
          MYSQL_USER = "passbolt";
          MYSQL_PASSWORD = "https://${cfg.oci-containers.passbolt.mariadb.password}";
        };
        volumes = [ "passbolt-mariadb-data:/var/lib/mysql" ];
      };
    };
  };

}
