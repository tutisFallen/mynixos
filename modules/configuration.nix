{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # MANTENHA ESTE ARQUIVO NA MESMA PASTA
    ./modules/hardware.nix
    ./modules/ui.nix
    ./modules/apps.nix
  ];

  # Bootloader e Kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # Kernel mais novo

  networking.hostName = "nixos-tutis";
  networking.networkmanager.enable = true;

  # Localização
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";

  # Usuário
  users.users.tutis = {
    isNormalUser = true;
    description = "tutis";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # NÃO REMOVA: Segurança do NixOS
  system.stateVersion = "25.11";
}
