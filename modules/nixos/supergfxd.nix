{ config, lib, pkgs, ... }:

let
  cfg = config.services.supergfxd;
  json = pkgs.formats.json { };
in
{
  options = {
    services.supergfxd = {
      enable = lib.mkEnableOption (lib.mdDoc "the supergfxd service");

      settings = lib.mkOption {
        type = lib.types.nullOr json.type;
        default = null;
        description = lib.mdDoc ''
          The content of /etc/supergfxd.conf.
          See https://gitlab.com/asus-linux/supergfxctl/#config-options-etcsupergfxdconf.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.unstable.supergfxctl ];

    environment.etc."supergfxd.conf" = lib.mkIf (cfg.settings != null) {
      source = json.generate "supergfxd.conf" cfg.settings;
      mode = "0644";
    };

    services.dbus.enable = true;

    systemd.packages = [ pkgs.unstable.supergfxctl ];
    systemd.services.supergfxd.wantedBy = [ "multi-user.target" ];
    systemd.services.supergfxd.path = [ pkgs.kmod pkgs.pciutils ];

    services.dbus.packages = [ pkgs.unstable.supergfxctl ];
    services.udev.packages = [ pkgs.unstable.supergfxctl ];
  };

  meta.maintainers = pkgs.supergfxctl.meta.maintainers;
}
