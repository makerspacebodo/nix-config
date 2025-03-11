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
  
  # networking config
  networking.firewall.allowedTCPPorts = [ 443 80 8123 ];

  # Home Assistant container
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [
        "home-assistant:/config"
        "/etc/nixos/nix-config/home-assistant:/config/extra"
      ];
      environment.TZ = "Europe/Oslo";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [ 
        "--network=host" 
        "--device=/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0018DF32C1-if00:/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0018DF32C1-if00"  # zigbee radio
      ];
    };
  };


  # Caddy reverse proxy
  services.caddy = {
    enable = true;
    virtualHosts."octoprint.lan".extraConfig = ''
      reverse_proxy http://localhost:5000
      tls internal
    '';
    virtualHosts."home-assistant.lan".extraConfig = ''
      reverse_proxy http://localhost:8123
      tls internal
    '';
  };


  # Performance tuning
  ## Automated tuning
  services.bpftune.enable = true;

  ## let processes get real-time scheduling on demand
  security.rtkit.enable = true;


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
