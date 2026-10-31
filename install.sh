#!/bin/bash
# Install (or remove) omarchy-lock-external-monitor.
#
#   ./install.sh              install / upgrade
#   ./install.sh --uninstall  restore the stock script and remove everything
#
# Run as your normal user; the steps that touch /usr and /etc go through sudo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT=/usr/share/omarchy/bin/omarchy-brightness-display
PATCH_BIN=/usr/local/bin/omarchy-dpms-patch
HOOK=/etc/pacman.d/hooks/zz-omarchy-lock-external-monitor.hook
OLD_HOOK=/etc/pacman.d/hooks/zz-omarchy-dpms-patch.hook

step() { printf '\n==> %s\n' "$*"; }

uninstall() {
  step "Removing hook and patch"
  sudo rm -f "$HOOK" "$OLD_HOOK" "$PATCH_BIN"
  if grep -q ddc-dim-external "$TARGET_SCRIPT" 2>/dev/null && [[ -e $TARGET_SCRIPT.orig ]]; then
    step "Restoring stock $TARGET_SCRIPT"
    sudo mv "$TARGET_SCRIPT.orig" "$TARGET_SCRIPT"
  fi
  echo "Done."
}

install_all() {
  command -v ddcutil >/dev/null || { echo "ddcutil is required: sudo pacman -S ddcutil" >&2; exit 1; }
  [[ -f $TARGET_SCRIPT ]] || { echo "Omarchy script not found: $TARGET_SCRIPT" >&2; exit 1; }

  step "Installing patch and pacman hook"
  sudo install -m 755 "$REPO_DIR/bin/omarchy-dpms-patch" "$PATCH_BIN"
  sudo rm -f "$OLD_HOOK"
  sudo install -m 644 "$REPO_DIR/pacman/zz-omarchy-lock-external-monitor.hook" "$HOOK"

  step "Applying patch"
  sudo "$PATCH_BIN"
  echo "Installed. Lock with Super+Ctrl+L to test."
}

case "${1:-}" in
  --uninstall) uninstall ;;
  "") install_all ;;
  *) echo "usage: $0 [--uninstall]" >&2; exit 2 ;;
esac
