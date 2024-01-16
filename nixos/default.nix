{ config, ... }:

{

  imports = [
    ./monitoring
    ./oci-containers
  ];

  system.activationScripts = {
    senpro.backup_config = ''
      echo "[TODO] Config backup goes here..."
    '';
  };
}
