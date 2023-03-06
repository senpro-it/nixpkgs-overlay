{ config, pkgs, lib, ... }:

with lib;

let cfg = config.senpro; in {

  options.senpro = {
    oci-containers = {
      unifi-controller = {
        enable = mkEnableOption ''
          Whether to enable the unifi-controller pod.
        '';
        publicURL = mkOption {
          type = types.str;
          default = "unifi-controller.local";
          example = "unifi-controller.example.com";
          description = ''
            Public URL for unifi-controller. URL should point to the fully qualified, publicly accessible URL. Don't provide protocol, SSL is hardcoded. Subfolders are allowed.
          '';
        };
      };
    };
  };

  config = {
    virtualisation.oci-containers.containers = lib.mkIf (cfg.oci-containers != {}) (lib.mkMerge [
      (lib.mkIf cfg.oci-containers.unifi-controller.enable {
        unifi-controller = {
          image = "lscr.io/linuxserver/unifi-controller:latest";
          autoStart = true;
          ports = [
            "1900:1900/udp" "3478:3478/udp" "6789:6789/tcp" "8080:8080/tcp" "8443:8443/tcp" "10001:10001/udp"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            MEM_LIMIT = "1024";
            MEM_STARTUP = "1024";
          };
          volumes = [
            "unifi-controller:/config"
          ];
        };
      })
    ]);
  };

}
