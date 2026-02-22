{
  lib,
  config,
  ...
}: {
  options.eros.security = {
    hardening.enable = lib.mkEnableOption "security hardening baseline";
    hardening.requireSudoPassword = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Require password for sudo to reduce unattended privilege escalation.";
    };
    hardening.sudoTimeoutMinutes = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Sudo timestamp timeout in minutes.";
    };
  };

  config = lib.mkIf config.eros.security.hardening.enable {
    security.sudo = {
      enable = true;
      wheelNeedsPassword = config.eros.security.hardening.requireSudoPassword;
      extraConfig = ''
        Defaults timestamp_timeout=${toString config.eros.security.hardening.sudoTimeoutMinutes}
        Defaults passwd_tries=3
      '';
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };

    security.auditd.enable = lib.mkDefault true;

    boot.kernel.sysctl = {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
    };
  };
}
