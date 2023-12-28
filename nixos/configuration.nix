# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  disabledModules = 
    [ 
      "services/hardware/asusd.nix" 
      "services/hardware/supergfxd.nix"
    ];
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    inputs.hardware.nixosModules.asus-zephyrus-gu603h

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    outputs.nixosModules.supergfxctl
    outputs.nixosModules.asusctl
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  # Hardware
  services.supergfxd.enable = true;
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.asusd.profileConfig = "Quiet";

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Fix shebangs by populating /bin
  services.envfs.enable = true;

  # Networking
  networking.hostName = "aiden-laptop";
  networking.networkmanager.enable = true;

  # Time and Localization
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-hyprland
  ];

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
    '';
  };

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.zsh.enable = true;

  users.users = {
    aiden = {
      isNormalUser = true;
      description = "Aiden Madaffri";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = ["wheel" "networkmanager"];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    killall
    polkit_gnome
    xdg-desktop-portal-hyprland
    xdg-utils
  ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "aiden" ];
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services."1password".enableGnomeKeyring = true;

  fonts.packages = with pkgs; [
    meslo-lgs-nf
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users.aiden = import ../home-manager/home.nix;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
