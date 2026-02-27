{ config, pkgs, ... }:

{
  # --- MONTAGEM AUTOMÁTICA DE DISCOS ---

  # SSD de 240GB (sda1) - FORMATO EXT4
  fileSystems."/mnt/SSD" = {
    device = "/dev/sda1";
    fsType = "ext4";
    options = [ "nofail" ]; # ext4 usa permissões de sistema, não precisa de uid/umask aqui
  };

  # HD de 1TB (sdc1) - Mantemos as opções se for NTFS
  fileSystems."/mnt/HD_1T" = {
    device = "/dev/sdc1";
    fsType = "auto";
    options = [ "nofail" "uid=1000" "gid=100" "rw" "user" "exec" "umask=000" ];
  };

  # --- CORREÇÃO WIFI/BT (Sincronização e Estabilidade) ---
  boot.initrd.kernelModules = [ "iwlwifi" ];
  boot.kernelModules = [ "iwlwifi" "iwlmvm" ];

  # 11n_disable=1 ajuda a estabilizar a Intel 7260 em algumas redes
  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=1 swcrypto=1
  '';

  # --- GRÁFICOS E FIRMWARE ---
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Vital para jogos e Wine (WoW)
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # --- BLUETOOTH ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # --- NIX-LD (Para rodar binários de fora da Nix Store) ---
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXi
    libglvnd vulkan-loader stdenv.cc.cc
    pkgsi686Linux.xorg.libX11 pkgsi686Linux.libglvnd pkgsi686Linux.vulkan-loader
  ];

  # --- ÁUDIO (Pipewire) ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Suporte a NTFS (Caso seus discos usem esse formato)
  environment.systemPackages = with pkgs; [ ntfs3g ];
}
