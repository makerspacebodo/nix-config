{ config, pkgs, ... }:

# Configuration for systems connected to 3D-printers
{

  # high-performance Linux kernel to ensure timely operation of printer communicatio
  boot.kernelPackages = pkgs.linuxPackages_zen; 

  # Packages
  environment.systemPackages = with pkgs; [
    git
  ];

  # Long running processes
  ## 3D printer services
  services.octoprint = {
    enable = true;
    openFirewall = true;
    plugins = plugins: with plugins; [
      navbartemp
      bedlevelvisualizer
      displaylayerprogress
      mqtt
      printtimegenius
      resource-monitor
      simpleemergencystop
      dashboard
    ];
  };

  ## Remote shell for administration of systems without display
  services.openssh.enable = true;

  # Auto system update
  system.autoUpgrade = {
    enable = true;
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  ## Harden security
  # Disable CUPS printing server
  services.printing.enable = false;

}
