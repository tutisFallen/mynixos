{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Essenciais de Sistema ---
    kdePackages.qt6ct
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    pciutils

    # --- Shell e Terminal ---
    zsh
    nitch
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    git
    neovim
    wget
    kitty
    libnotify
    sunshine

    # --- Gaming e Wine ---
    wineWowPackages.stagingFull
    winetricks
    bottles
    mangohud
    gamemode

    # --- Editor ---
    vscode

    # --- Monitoramento ---
    btop
    amdgpu_top
    fastfetch
    pavucontrol

    # --- Extra ---
    blueman
  ];

  # --- CONFIGURAÇÃO DO ZSH ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Atalhos de Sistema
      rb = "nix-up"; # Agora o 'rb' faz a manutenção completa!
      conf = "cd ~/nixos-config";
      limpar = "sudo nix-collect-garbage -d && nix store optimise";
      atualizar = "sudo nix flake update";

      # Atalhos Rápidos de Edição (ajuste para seu editor, usei nvim)
      edit-config = "nvim ~/nixos-config/system/configuration.nix";
      edit-apps = "nvim ~/nixos-config/modules/apps.nix";
      edit-flake = "nvim ~/nixos-config/flake.nix";

      # Atalhos de Apps
      n = "nitch";
      f = "fastfetch";
      gpu = "amdgpu_top";
    };

    interactiveShellInit = ''
      # Mostrar o nitch ao abrir
      nitch

      # Função de Manutenção do Tutis
      nix-up() {
        echo "🚀 Iniciando manutenção do sistema..."
        cd ~/nixos-config || return

        echo "📦 Sincronizando com o Git..."
        git add .

        echo "🛠️  Fazendo o Rebuild..."
        sudo nixos-rebuild switch --flake .#nixos-tutis --option eval-cache false

        if [ $? -eq 0 ]; then
          echo "🧹 Limpando gerações antigas (7 dias)..."
          sudo nix-collect-garbage --delete-older-than 7d
          echo "💾 Otimizando a store..."
          nix store optimise
          echo "✅ Sistema atualizado e limpo!"
        else
          echo "❌ Erro no rebuild. Manutenção abortada."
        fi
      }
    '';
  };

  # --- CONFIGURAÇÃO DE FONTES ---
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];

  services.flatpak.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
