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
    system.autoUpgrade.enable = lib.mkDefault false;

    # Do not run this.
    nix.gc.automatic = lib.mkDefault false;
  };
}
