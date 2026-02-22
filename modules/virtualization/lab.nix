{
  lib,
  config,
  username,
  ...
}: {
  options.eros.lab.virtualization.enable = lib.mkEnableOption "KVM/libvirt lab mode";

  config = lib.mkIf config.eros.lab.virtualization.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    users.users.${username}.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    networking.bridges = {
      br-lab-int.interfaces = [];
      br-lab-dmz.interfaces = [];
    };

    networking.interfaces.br-lab-int.ipv4.addresses = [
      {
        address = "10.90.0.1";
        prefixLength = 24;
      }
    ];

    networking.interfaces.br-lab-dmz.ipv4.addresses = [
      {
        address = "10.91.0.1";
        prefixLength = 24;
      }
    ];

    networking.firewall.trustedInterfaces = [
      "br-lab-int"
      "br-lab-dmz"
    ];
  };
}
