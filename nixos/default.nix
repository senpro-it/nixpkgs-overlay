{ system, config, lib, ... }:

{

  imports = [
    ./monitoring
    ./oci-containers
  ];

  config = {
    system.activationScripts = {
      senpro_backupConfig = ''
        echo "[TODO] Config backup goes here..."
      '';
    };

    # Disable auto upgrades; we do tem ourself.
    system.autoUpgrade.enable = false;

    # Do not run this.
    nix.gc.automatic = false;
  };
}
