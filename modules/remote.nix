{ config, pkgs, ... }:

{
  # --- 1. TAILSCALE (O Túnel Seguro) ---
  services.tailscale.enable = true;

  # --- 2. FIREWALL MODERNO (NFTABLES) ---
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    # Confia na interface do Tailscale para tráfego interno
    trustedInterfaces = [ "tailscale0" ];

    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [
      22    # SSH (Terminal)
      3389  # RDP (Desktop Remoto)
      5900  # VNC
    ];

    # CORREÇÃO CRÍTICA: Permite tráfego de retorno para Exit Nodes e Tailscale
    checkReversePath = "loose";
  };

  # --- 3. FIX DE DNS E RESOLUÇÃO DE NOMES ---
  # Resolve o problema do link de login não aparecer e do DNS travar
  services.resolved.enable = true;
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # --- 4. OTIMIZAÇÕES DE SERVIÇO ---
  # Força o Tailscale a usar nftables e evita esperas desnecessárias no boot
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  # --- 5. ACESSO VIA TERMINAL (SSH) ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # --- 6. ACESSO GRÁFICO (XRDP) ---
  services.xrdp = {
    enable = true;
    defaultWindowManager = "Hyprland";
  };
}
