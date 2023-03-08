{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      grafana = {
        enable = mkEnableOption ''
          Whether to enable the grafana container stack.
        '';
        rootURL = mkOption {
          type = types.str;
          default = "grafana.local";
          example = "grafana.example.com";
          description = ''
            Public URL for grafana. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
        alertmanager = {
          publicURL = mkOption {
            type = types.str;
            default = "alertmanager.local";
            example = "alertmanager.example.com";
            description = ''
              URL of the alertmanager instance. Don't provide protocol, SSL is hardcoded.
            '';
          };
        };
        authProxy = {
          noc = {
            username = mkOption {
              type = types.str;
              default = "noc";
              example = "noc";
              description = ''
                Username for the NOC (Network Operations Center) user.
              '';
            };
            password = mkOption {
              type = types.str;
              default = "1HmuSzUoq1iAZfeF4zdRYuINYl0Poe5eXt43NokbAUK4SaoIOEMdwtqpPEMlwrK8";
              example = "C6HmQc7iybQc1Mms3tUpsXaxuR77sZqeTQ8V9AGnChYoNYaFCSkQWycCuwA1e2TS";
              description = ''
                Password for the NOC (Network Operations Center) user.
              '';
            };
          };
          whitelist = mkOption {
            type = types.str;
            default = "192.168.1.0/24";
            example = "192.168.1.0/24, 192.168.2.0/24";
            description = ''
              Whitelist of networks or hosts that allowed to use the auth proxy.
            '';
          };
        };
        influxdb = {
          publicURL = mkOption {
            type = types.str;
            default = "influxdb.local";
            example = "influxdb.example.com";
            description = ''
              URL of the InfluxDB instance. Don't provide protocol, SSL is hardcoded.
            '';
          };
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
          client = {
            secret = mkOption {
              type = types.str;
              example = "eofodff-sddsdwefdf-wefdswdff-dwsdfdds";
              description = ''
                Client secret for authentication against Keycloak.
              '';
            };
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
              TCP port which grafana will use to connect to the mail server.
            '';
          };
          from = mkOption {
            type = types.str;
            default = "grafana@mail.local";
            example = "grafana@example.com";
            description = ''
              SMTP FROM address grafana will send with.
            '';
          };
          username = mkOption {
            type = types.str;
            default = "user";
            example = "grafana@example.com";
            description = ''
              SMTP user grafana will use to login.
            '';
          };
          password = mkOption {
            type = types.str;
            default = "G34KFIYurjmi22ZJLpPkhx3DotdYDmj5W2mN0kRSQHoyeAPPp8eOL3Dxfw54XPnt";
            example = "V6nlydlhsY71giivyzhIqvNpUBqthWRG4rvtHSsj9Ijn4XUsobDHCeRoZJukaJIa";
            description = ''
              Password of the SMTP user grafana will use to login.
            '';
          };
          displayName = mkOption {
            type = types.str;
            default = "Grafana";
            example = "Grafana";
            description = ''
              Display name of the SMTP FROM address.
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.oci-containers.grafana.enable {
    virtualisation.oci-containers.containers = {
      grafana = {
        image = "docker.io/grafana/grafana:9.4.3";
        autoStart = true;
        dependsOn = [
          "grafana-influxdb"
        ];
        extraOptions = [
          "--net=proxy"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.grafana.tls=true"
          "--label=traefik.http.routers.grafana.entrypoints=https"
          "--label=traefik.http.routers.grafana.service=grafana"
          "--label=traefik.http.routers.grafana.rule=Host(`${cfg.oci-containers.grafana.rootURL}`)"
          "--label=traefik.http.services.grafana.loadBalancer.server.port=3000"
          "--label=traefik.http.middlewares.grafanaAuthProxy.basicAuth.users=${cfg.oci-containers.grafana.authProxy.noc.username}:${cfg.oci-containers.grafana.authProxy.noc.password}"
        ];
        environment = {
          GF_USERS_ALLOW_SIGN_UP = "false";
          GF_USERS_AUTO_ASSIGN_ORG = "true";
          GF_AUTH_DISABLE_LOGIN_FORM = "true";
          GF_AUTH_GENERIC_OAUTH_ENABLED = "true";
          GF_AUTH_GENERIC_OAUTH_NAME = "OAuth2";
          GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "true";
          GF_AUTH_GENERIC_OAUTH_CLIENT_ID = "grafana";
          GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = "${cfg.oci-containers.grafana.keycloak.client.secret}";
          GF_AUTH_GENERIC_OAUTH_SCOPES = "openid profile email";
          GF_AUTH_GENERIC_OAUTH_AUTH_URL = "https://${cfg.oci-containers.grafana.keycloak.provider}/realms/${cfg.oci-containers.grafana.keycloak.realm}/protocol/openid-connect/auth";
          GF_AUTH_GENERIC_OAUTH_TOKEN_URL = "https://${cfg.oci-containers.grafana.keycloak.provider}/realms/${cfg.oci-containers.grafana.keycloak.realm}/protocol/openid-connect/token";
          GF_AUTH_GENERIC_OAUTH_API_URL = "https://${cfg.oci-containers.grafana.keycloak.provider}/realms/${cfg.oci-containers.grafana.keycloak.realm}/protocol/openid-connect/userinfo";
          GF_AUTH_GENERIC_OAUTH_TLS_SKIP_VERIFY_INSECURE = "true";
          GF_AUTH_OAUTH_SKIP_ORG_ROLE_UPDATE_SYNC = "true";
          GF_SERVER_ROOT_URL = "https://${cfg.oci-containers.grafana.rootURL}";
          GF_PANELS_DISABLE_SANITIZE_HTML = "true";
          GF_FEATURE_TOGGLES_ENABLE = "internationalization";
          GF_SMTP_ENABLED = "true";
          GF_SMTP_HOST = "${cfg.oci-containers.grafana.smtp.host}:${toString cfg.oci-containers.grafana.smtp.port}";
          GF_SMTP_USER = "${cfg.oci-containers.grafana.smtp.username}";
          GF_SMTP_PASSWORD = "${cfg.oci-containers.grafana.smtp.password}";
          GF_SMTP_FROM_NAME = "${cfg.oci-containers.grafana.smtp.displayName}";
          GF_SMTP_FROM_ADDRESS = "${cfg.oci-containers.grafana.smtp.from}";
          GF_AUTH_PROXY_ENABLED = "true";
          GF_AUTH_PROXY_HEADER_NAME = "X-WEBAUTH-USER";
          GF_AUTH_PROXY_HEADER_PROPERTY = "username";
          GF_AUTH_PROXY_AUTO_SIGN_UP = "true";
          GF_AUTH_PROXY_WHITELIST = "${cfg.oci-containers.grafana.authProxy.whitelist}";
        };
        volumes = [
          "grafana:/etc/grafana/provisioning"
          "grafana-data:/var/lib/grafana"
        ];
      };
      grafana-alertmanager = {
        image = "ghcr.io/senpro-it/alertmanager:main";
        autoStart = true;
        extraOptions = [
          "--net=proxy"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.grafana-alertmanager.tls=true"
          "--label=traefik.http.routers.grafana-alertmanager.entrypoints=https"
          "--label=traefik.http.routers.grafana-alertmanager.service=grafana-alertmanager"
          "--label=traefik.http.routers.grafana-alertmanager.rule=Host(`${cfg.oci-containers.grafana.alertmanager.publicURL}`)"
          "--label=traefik.http.services.grafana-alertmanager.loadBalancer.server.port=9093"
        ];
        volumes = [
          "grafana-alertmanager-data:/alertmanager"
        ];
      };
      grafana-influxdb = {
        image = "docker.io/library/influxdb:2.6";
        autoStart = true;
        extraOptions = [
          "--net=proxy"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.grafana-influxdb.tls=true"
          "--label=traefik.http.routers.grafana-influxdb.entrypoints=https"
          "--label=traefik.http.routers.grafana-influxdb.service=grafana-influxdb"
          "--label=traefik.http.routers.grafana-influxdb.rule=Host(`${cfg.oci-containers.grafana.influxdb.publicURL}`)"
          "--label=traefik.http.services.grafana-influxdb.loadBalancer.server.port=8086"
        ];
        volumes = [
          "grafana-influxdb:/etc/influxdb2"
          "grafana-influxdb-data:/var/lib/influxdb2"
        ];
      };
    };
  };

}
