{ config, pkgs, ... }: 

{
  imports = [
    ./hardware-configuration.nix
    ../modules/hardware.nix
    ../modules/ui.nix
    ../modules/apps.nix
    ../modules/remote.nix
  ];

  # --- FIX DOLPHIN / KDE 6 MENU ---
  # Isso cria o link simbólico que o Dolphin procura para saber abrir arquivos
  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # --- CORE DO NIXOS & CACHE ---
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [ "https://chaotic-nyx.cachix.org" ];
      trusted-public-keys = [ "chaotic-nyx.cachix.org-1:9v8H6S7xSdL6ES/Sj9ODpS4tD3dF0V+P9S0ZtXz/f6A=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # --- PERFORMANCE (Kernel & Scheduler) ---
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
  };

  # --- BOOTLOADER ---
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # --- REDE E IDENTIDADE ---
  networking.hostName = "nixos-tutis";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # --- USUÁRIO ---
  users.users.tutis = {
    isNormalUser = true;
    description = "tutis";
    extraGroups = [ "networkmanager" "wheel" "video" "lp" ];
    shell = pkgs.zsh;
  };

  # --- SERVIÇOS E AMBIENTE ---
  services.envfs.enable = true;
  services.flatpak.enable = true;

  # Garante que o Dolphin tenha os serviços necessários
  services.dbus.enable = true;
  programs.dconf.enable = true;

  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze"; # Ajuda a manter a consistência no Dolphin
  };

  # Pacotes necessários para o Fix do Dolphin e MIME
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kservice        # Fornece o kbuildsycoca6
    kdePackages.plasma-workspace # Fornece o menu original
    shared-mime-info            # Banco de dados de arquivos
    xdg-utils                   # xdg-mime e xdg-open
  ];

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";

  home-manager.backupFileExtension = "hm-backup";


  system.stateVersion = "25.11";
}
