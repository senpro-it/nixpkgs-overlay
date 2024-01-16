{ system, config, ... }:

{

  imports = [
    ./monitoring
    ./oci-containers
  ];

  config.system.activationScripts = {
    senpro = {
      backup_config = ''
        echo "[TODO] Config backup goes here..."
      '';
    };
  };
}
