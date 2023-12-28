# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "aiden";
    homeDirectory = "/home/aiden";
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
    ANKI_WAYLAND = 1;
  };


  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs;
    [
      swaynotificationcenter
      google-chrome
      firefox
      freerdp
      tofi
      moonlight-qt
      networkmanagerapplet
      unstable.anki-bin
      thunderbird
      slack
      webcord #discord
      unstable.ticktick
      unstable.vscode
    ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      g = "git";
    };
    initExtraFirst = ''
      if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtra = ''
      bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
      bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
    '';
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.unstable.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh-you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      }
    ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "MesloLGS NF";
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      exec-once =
        [
          "asusctl profile -P \"Quiet\""
          "waybar"
          "swaync"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "rog-control-center"
          "nm-applet"
          "1password --silent"
          "webcord"
        ];
      bind =
        [
          "$mod, q, killactive"
          "$mod, t, togglefloating"
          "$mod, f, fullscreen, 0"
          "$mod CTRL SHIFT ALT, q, exit"

          "$mod, r, exec, tofi-run | xargs hyprctl dispatch exec --"

          "$mod, x, exec, alacritty"
          "$mod, b, exec, google-chrome-stable"


          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"
        ];
    };
  };
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      modules-center = [ "hyprland/window" ];
      modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
      modules-right = [ "tray" "pulseaudio" "cpu" "memory" "temperature" "battery" "clock" "custom/notification"];
      "custom/notification" = {
        tooltip = false;
        format = "{} {icon}";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "sleep 0.2 && swaync-client -t -sw";
        on-click-right = "sleep 0.2 && swaync-client -d -sw";
        escape = true;
      };
    }];
    style = builtins.readFile ./waybar/style.css;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
	IdentityAgent ~/.1password/agent.sock
    '';
  };
  programs.gpg.enable = true; 
  programs.git = {
    userName = "Aiden Madaffri";
    userEmail = "contact@aidenmadaffri.com";
    signing.signByDefault = true;
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATkTtlMGDuOr/jBC5FC1oJ30HanKIYJ4wzD86V607c2";
    aliases = {
      co = "checkout";
      con = "checkout -b";
      b = "branch";
      s = "status";
      a = "add";
      m = "merge";
      cm = "commit";
      cma = "commit -a";
    };
    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${./git/allowed_signers}";
      "gpg \"ssh\"".program = "op-ssh-sign";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
