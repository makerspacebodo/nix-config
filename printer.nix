{ config, pkgs, ... }:

# Configuration for systems connected to 3D-printers

{
  # Low latency Linux kernel to ensure timely operation of printer communicatio
  boot.kernelPackages = pkgs.linuxPackages_zen; 

  # Packages
  environment.systemPackages = with pkgs; [
    git
  ];

  # networking config
  networking.firewall.allowedTCPPorts = [ 443 80 8123 ];

  # Containers
  virtualisation.oci-containers = {
    backend = "podman";

    # Home Assistant
    containers.homeassistant = {
      volumes = [
        "home-assistant:/config"
        "/etc/nixos/nix-config/home-assistant:/config/external"
      ];
      environment.TZ = "Europe/Oslo";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = ["127.0.0.1:8123:8123"];
      extraOptions = [ 
        "--pull=always" # always pull latest stable
        # "--network=host"
        "--cap-add=CAP_NET_RAW" # Allow for dhcp discovery
        "--device=/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0018DF32C1-if00:/dev/ttyUSB_zigbee_cc2531"  # zigbee radio
      ];
    };
    containers.octoprint-prusa-mk3s = {
      volumes = [
        "octoprint-mk3s:/octoprint"
        "/etc/nixos/nix-config/octoprint/config.yaml:/octoprint/config.yaml"
        "octoprint-common-data:/octoprint/octoprint/data"
        "octoprint-common-uploads:/octoprint/octoprint/uploads"
        "/etc/nixos/nix-config/octoprint/users.yaml:/octoprint/octoprint/users.yaml"
        "octoprint-common-plugins:/octoprint/plugins"
      ];
      image = "docker.io/octoprint/octoprint:latest";
      ports = ["127.0.0.1:5000:5000"];
      extraOptions = [
        "--device=/dev/serial/by-id/usb-Prusa_Research__prusa3d.com__Original_Prusa_i3_MK3_CZPX1118X004XC52597-if00:/dev/ttyACM0"
      ];
    };
    containers.octoprint-prusa-mk2 = {
      volumes = [
        "octoprint-mk2:/octoprint"
        "/etc/nixos/nix-config/octoprint/config.yaml:/octoprint/config.yaml"
        "octoprint-common-data:/octoprint/octoprint/data"
        "octoprint-common-uploads:/octoprint/octoprint/uploads"
        "/etc/nixos/nix-config/octoprint/users.yaml:/octoprint/octoprint/users.yaml"
        "octoprint-common-plugins:/octoprint/plugins"
      ];
      image = "docker.io/octoprint/octoprint:latest";
      ports = ["127.0.0.1:5001:5000"];
      extraOptions = [
        "--device=/dev/serial/by-id/usb-UltiMachine__ultimachine.com__RAMBo_5553933393735161A150-if00:/dev/ttyACM0"
      ];
    };
  };


  # Caddy reverse proxy
  services.caddy = {
    enable = true;
    virtualHosts."octoprint-mk3.lan".extraConfig = ''
      reverse_proxy http://localhost:5000
      tls internal
    '';
    virtualHosts."octoprint-mk2.lan".extraConfig = ''
      reverse_proxy http://localhost:5001
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
