{ config, pkgs, ... }:

# Configuration for systems connected to 3D-printers
{
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
    ];
  };
  ## Remote shell for administration of systems without display
  services.openssh.enable = true;
}
