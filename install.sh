#!/usr/bin/env bash
set -euo pipefail

# NixOS flake installer/apply helper
# Usage:
#   ./install.sh                # uses current hostname
#   ./install.sh --host desktop # uses explicit flake host
#   ./install.sh --boot         # nixos-rebuild boot instead of switch
#   ./install.sh --dry-run      # build only

HOST_OVERRIDE=""
MODE="switch"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST_OVERRIDE="${2:-}"
      shift 2
      ;;
    --boot)
      MODE="boot"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      cat <<USAGE
Usage: ./install.sh [--host <name>] [--boot] [--dry-run]

Options:
  --host <name>   Flake output hostname to use (e.g. desktop)
  --boot          Build and set for next boot (nixos-rebuild boot)
  --dry-run       Only build, do not switch/boot
USAGE
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v nixos-rebuild >/dev/null 2>&1; then
  echo "Erro: nixos-rebuild não encontrado. Rode isso em um NixOS." >&2
  exit 1
fi

if ! command -v hostname >/dev/null 2>&1; then
  echo "Erro: hostname não encontrado." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Erro: git não encontrado." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

HOST="${HOST_OVERRIDE:-$(hostname)}"
FLAKE_REF=".#$HOST"

echo "→ Repo: $ROOT_DIR"
echo "→ Host alvo: $HOST"

# Quick check whether host exists in flake outputs
if ! nix flake show --json 2>/dev/null | grep -q "\"$HOST\""; then
  echo "⚠️  Não achei host '$HOST' no flake outputs." >&2
  echo "    Passe manualmente: ./install.sh --host <nome-do-host>" >&2
  echo "    Hosts disponíveis (resumo):" >&2
  nix flake show 2>/dev/null | sed -n '/nixosConfigurations/,$p' | sed -n '1,80p' >&2 || true
  exit 1
fi

# Optional safety: show git status
if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠️  Há mudanças locais não commitadas no repo." >&2
  git status --short
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "→ Dry-run: nixos-rebuild build --flake $FLAKE_REF"
  sudo nixos-rebuild build --flake "$FLAKE_REF"
  exit 0
fi

echo "→ Executando: sudo nixos-rebuild $MODE --flake $FLAKE_REF"
sudo nixos-rebuild "$MODE" --flake "$FLAKE_REF"

echo "✅ Concluído com sucesso."
