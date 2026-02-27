{ config, pkgs, inputs, ... }:

{
  # Aqui deixamos apenas o módulo do sistema, o home-manager cuida do resto
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true;

  # Teclado
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Otimização para a RX 580 no Hyprland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Ativa o dconf (vital para o DMS e temas)
  programs.dconf.enable = true;
}
