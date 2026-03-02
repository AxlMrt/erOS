{
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  options.eros.virtualization.enable = lib.mkEnableOption "KVM/libvirt virtualization";

  config = lib.mkIf config.eros.virtualization.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virt-manager
      qemu_kvm
      libvirt
      cloud-utils
    ];

    users.users.${username}.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    networking.bridges = {
      br-vm-int.interfaces = [];
      br-vm-dmz.interfaces = [];
    };

    networking.interfaces.br-vm-int.ipv4.addresses = [
      {
        address = "10.90.0.1";
        prefixLength = 24;
      }
    ];

    networking.interfaces.br-vm-dmz.ipv4.addresses = [
      {
        address = "10.91.0.1";
        prefixLength = 24;
      }
    ];

    networking.firewall.trustedInterfaces = [
      "br-vm-int"
      "br-vm-dmz"
    ];
  };
}
