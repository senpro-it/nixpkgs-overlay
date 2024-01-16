{ system, config, ... }:

{

  imports = [
    ./monitoring
    ./oci-containers
  ];

  config.system.activationScripts = {
    senpro_backupConfig = ''
      echo "[TODO] Config backup goes here..."
    '';
  };
}
