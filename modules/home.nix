{ config, pkgs, inputs, lib, ... }: 

{
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  home.username = "tutis";
  home.homeDirectory = "/home/tutis";

  # --- DCONF: Essencial para gsettings persistir no NixOS ---
  dconf.enable = true;

  # --- CONSISTÊNCIA DE SYMLINKS ---
  # Usamos config.lib.file para acessar a função de symlink fora da store
  xdg.configFile."gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/DankMaterialShell/gtk-3.0.css";
  xdg.configFile."gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/DankMaterialShell/gtk-4.0.css";
  xdg.configFile."gtk-3.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/DankMaterialShell/gtk-3.0-settings.ini";
  xdg.configFile."gtk-4.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/DankMaterialShell/gtk-4.0-settings.ini";

  # --- CONFIGURAÇÃO DO DMS (DankMaterialShell) ---
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
    managePluginSettings = false;
  };

  # --- PACOTES DO USUÁRIO ---
  home.packages = with pkgs; [
    whitesur-gtk-theme
    whitesur-icon-theme
    dracula-theme
    adw-gtk3
    kdePackages.qt6ct
    glib  # Fornece o gsettings para o script
    gsettings-desktop-schemas
  ];

  # --- CURSOR (DMS desativa o cursor padrão do HM para não conflitar) ---
  home.pointerCursor = {
    enable = !config.programs.dank-material-shell.enable;
    gtk.enable = true;
    x11.enable = true;
    name = "Dracula-cursors";
    package = pkgs.dracula-theme;
    size = 24;
  };

  # Isso ajuda o gsettings a encontrar os esquemas no NixOS
  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS";
  };


  # --- SCRIPT DE TEMAS ---
  # Instala o script na sua home e torna executável
  home.file.".local/bin/dms-apply-theme" = {
    source = ../script/dms-apply-theme.sh;
    executable = true;
  };

  # --- SERVIÇO SYSTEMD USER ---
  # Aplica os temas do DMS automaticamente no login
  systemd.user.services.dms-apply-theme = lib.mkIf config.programs.dank-material-shell.enable {
    Unit = {
      Description = "Aplica temas do DMS no login";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/dms-apply-theme";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.stateVersion = "23.11";
}
