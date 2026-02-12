#!/bin/bash
# ============================================================
#  Remote Battery Monitor — Instalador rápido
#  Uso:  chmod +x install.sh && ./install.sh
# ============================================================

set -e

# ── Colores ──────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLASMOID_DIR="$SCRIPT_DIR/plasmoid"
WIDGET_ID="org.kde.remote.battery"

# ── Funciones de utilidad ────────────────────────────────────
info()    { printf "${CYAN}[INFO]${NC}  %s\n" "$1"; }
success() { printf "${GREEN}[  OK]${NC}  %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

header() {
    echo ""
    printf "${BOLD}╔══════════════════════════════════════════════╗${NC}\n"
    printf "${BOLD}║   🔋  Remote Battery Monitor — Instalador   ║${NC}\n"
    printf "${BOLD}╚══════════════════════════════════════════════╝${NC}\n"
    echo ""
}

# ── Verificar dependencias ───────────────────────────────────
check_deps() {
    missing=""

    if ! command -v python3 >/dev/null 2>&1; then
        missing="$missing python3"
    fi

    # Detectar herramienta de instalación de paquetes Plasma
    if command -v kpackagetool6 >/dev/null 2>&1; then
        KPKG="kpackagetool6"
    elif command -v kpackagetool5 >/dev/null 2>&1; then
        KPKG="kpackagetool5"
    else
        missing="$missing kpackagetool6/5"
    fi

    if [ -n "$missing" ]; then
        error "Faltan dependencias:$missing"
        echo "  Instálalas con:  sudo apt install python3 (y asegúrate de tener KDE Plasma)"
        exit 1
    fi

    success "Dependencias OK  (python3, $KPKG)"
}

# ── Abrir puerto en el firewall ──────────────────────────────
open_firewall() {
    if command -v ufw >/dev/null 2>&1; then
        if sudo ufw status | grep -q "5555/udp.*ALLOW"; then
            success "Puerto UDP 5555 ya está abierto en UFW"
        else
            info "Abriendo puerto UDP 5555 en UFW..."
            sudo ufw allow 5555/udp
            success "Puerto UDP 5555 abierto"
        fi
    else
        warn "UFW no detectado. Asegúrate de que el puerto UDP 5555 esté abierto manualmente."
    fi
}

# ── Instalar el plasmoid ─────────────────────────────────────
install_plasmoid() {
    info "Instalando widget de KDE Plasma..."

    # Intentar desinstalar primero de forma limpia (ignorar fallos si no existe)
    $KPKG -t Plasma/Applet -r "$WIDGET_ID" >/dev/null 2>&1 || true

    # Si la carpeta sigue existiendo en rutas comunes, borrarlas manualmente (fuerza la reinstalación)
    PLASMOID_DEST="$HOME/.local/share/plasma/plasmoids/$WIDGET_ID"
    GHOST_DEST="$HOME/.local/share/$WIDGET_ID"
    
    if [ -d "$PLASMOID_DEST" ]; then
        warn "Limpiando archivos antiguos en $PLASMOID_DEST..."
        rm -rf "$PLASMOID_DEST"
    fi
    if [ -d "$GHOST_DEST" ]; then
        warn "Limpiando archivos antiguos en $GHOST_DEST..."
        rm -rf "$GHOST_DEST"
    fi

    # Intentar instalar
    if $KPKG -t Plasma/Applet -i "$PLASMOID_DIR" >/dev/null 2>&1; then
        success "Widget '${BOLD}Remote Battery Monitor${NC}' instalado correctamente"
    else
        # Si falla el 'install', probar con 'upgrade' (a veces es necesario en Plasma 6)
        info "Probando actualización (upgrade)..."
        if $KPKG -t Plasma/Applet -u "$PLASMOID_DIR" >/dev/null 2>&1; then
            success "Widget '${BOLD}Remote Battery Monitor${NC}' actualizado correctamente"
        else
            error "No se pudo instalar el widget."
            echo "  Intenta manualmente:  $KPKG -t Plasma/Applet -i $PLASMOID_DIR"
            exit 1
        fi
    fi
}

# ── Mostrar instrucciones finales ────────────────────────────
show_summary() {
    MY_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

    echo ""
    printf "${BOLD}╔══════════════════════════════════════════════╗${NC}\n"
    printf "${BOLD}║           ✅  Instalación completa           ║${NC}\n"
    printf "${BOLD}╚══════════════════════════════════════════════╝${NC}\n"
    echo ""
    printf "  ${BOLD}¡Listo!${NC} El servidor se iniciará automáticamente al añadir el widget.\n"
    echo ""
    printf "  ${BOLD}Próximos pasos:${NC}\n"
    echo ""
    printf "  ${CYAN}1.${NC} Añadir el widget al panel:\n"
    printf "     Clic derecho en el panel → Añadir Widgets → busca 'Remote Battery Monitor'\n"
    echo ""
    printf "  ${CYAN}2.${NC} En tu laptop real, ejecuta el sender:\n"
    printf "     ${BOLD}python3 battery_sender.py ${MY_IP:-<IP_DE_ESTA_PC>}${NC}\n"
    echo ""
    printf "  ${CYAN}3.${NC} (Opcional) Cambiar intervalo de envío (ej: cada 10s):\n"
    printf "     python3 battery_sender.py ${MY_IP:-<IP>} --interval 10\n"
    echo ""
}


# ── Main ─────────────────────────────────────────────────────
header
check_deps
open_firewall
install_plasmoid
show_summary
