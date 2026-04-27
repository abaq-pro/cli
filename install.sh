#!/bin/sh
# Instalador de abaq CLI
# Uso: curl -fsSL https://raw.githubusercontent.com/abaq-pro/cli/main/install.sh | sh
#
# Variables de entorno opcionales:
#   INSTALL_DIR   — directorio de instalación (default: ~/.local/bin)
#   VERSION       — versión específica (default: última release publicada)

set -e

REPO="abaq-pro/cli"
BINARY="abaq"
DEFAULT_INSTALL_DIR="$HOME/.local/bin"
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

# --- Detección de plataforma ---

detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "darwin" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) error "Sistema operativo no soportado: $(uname -s)" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) error "Arquitectura no soportada: $(uname -m)" ;;
  esac
}

# --- Utilidades ---

info() { printf '\033[0;32m%s\033[0m\n' "$1"; }
warn() { printf '\033[0;33m%s\033[0m\n' "$1"; }
error() { printf '\033[0;31mError: %s\033[0m\n' "$1" >&2; exit 1; }

check_command() {
  command -v "$1" >/dev/null 2>&1
}

# --- Resolución de versión ---
# Devuelve el tag con prefijo 'v' (p.ej. v0.0.1-rc1).

resolve_version() {
  if [ -n "$VERSION" ]; then
    echo "$VERSION"
    return
  fi

  if check_command gh; then
    gh release view --repo "$REPO" --json tagName -q '.tagName' 2>/dev/null && return
  fi

  if check_command curl; then
    curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest" 2>/dev/null \
      | grep -o 'v[0-9][^/]*$' || true
  elif check_command wget; then
    wget -q -O /dev/null --server-response "https://github.com/$REPO/releases/latest" 2>&1 \
      | grep -o 'v[0-9][^ ]*' | tail -1 || true
  fi
}

# --- Descarga ---

download() {
  url="$1"
  dest="$2"
  if check_command curl; then
    curl -fsSL -o "$dest" "$url" && return
  fi
  if check_command wget; then
    wget -q -O "$dest" "$url" && return
  fi
  error "Se necesita curl o wget para la descarga"
}

download_release_asset() {
  version="$1"
  filename="$2"
  dest="$3"

  if check_command gh; then
    gh release download "$version" --repo "$REPO" --pattern "$filename" --dir "$(dirname "$dest")" 2>/dev/null && return
  fi

  download "https://github.com/$REPO/releases/download/$version/$filename" "$dest"
}

# --- Verificación de checksum ---

verify_checksum() {
  archive="$1"
  checksums_file="$2"
  archive_name="$(basename "$archive")"

  expected=$(grep "$archive_name" "$checksums_file" | awk '{print $1}')
  if [ -z "$expected" ]; then
    warn "No se encontró checksum para $archive_name, saltando verificación"
    return
  fi

  if check_command sha256sum; then
    actual=$(sha256sum "$archive" | awk '{print $1}')
  elif check_command shasum; then
    actual=$(shasum -a 256 "$archive" | awk '{print $1}')
  else
    warn "sha256sum/shasum no disponible, saltando verificación de checksum"
    return
  fi

  if [ "$expected" != "$actual" ]; then
    error "Checksum no coincide para $archive_name (esperado $expected, obtenido $actual)"
  fi
}

# --- Instalación ---

main() {
  os=$(detect_os)
  arch=$(detect_arch)

  info "Detectado: ${os}/${arch}"

  version=$(resolve_version)
  if [ -z "$version" ]; then
    error "No se pudo determinar la última versión. Usa VERSION=v0.0.1 para especificar una."
  fi

  # GoReleaser produce nombres como `abaq_0.0.1_darwin_arm64.tar.gz`
  # (versión sin la 'v' inicial). El tag sí lleva la 'v'.
  version_no_v=${version#v}

  info "Instalando $BINARY $version..."

  ext="tar.gz"
  if [ "$os" = "windows" ]; then
    ext="zip"
  fi
  archive_name="${BINARY}_${version_no_v}_${os}_${arch}.${ext}"

  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT

  info "Descargando ${archive_name}..."
  download_release_asset "$version" "$archive_name" "$tmp_dir/$archive_name"
  download_release_asset "$version" "checksums.txt" "$tmp_dir/checksums.txt"

  verify_checksum "$tmp_dir/$archive_name" "$tmp_dir/checksums.txt"
  info "Checksum verificado correctamente"

  if [ "$ext" = "tar.gz" ]; then
    tar -xzf "$tmp_dir/$archive_name" -C "$tmp_dir"
  else
    unzip -q "$tmp_dir/$archive_name" -d "$tmp_dir"
  fi

  binary_in_archive="$BINARY"
  if [ "$os" = "windows" ]; then
    binary_in_archive="${BINARY}.exe"
  fi

  if [ ! -f "$tmp_dir/$binary_in_archive" ]; then
    error "El archivo descargado no contiene el binario $binary_in_archive"
  fi

  mkdir -p "$INSTALL_DIR"
  mv "$tmp_dir/$binary_in_archive" "$INSTALL_DIR/$binary_in_archive"
  chmod +x "$INSTALL_DIR/$binary_in_archive"

  info "$BINARY instalado en $INSTALL_DIR/$binary_in_archive"

  if ! echo "$PATH" | tr ':' '\n' | grep -q "^${INSTALL_DIR}$"; then
    warn ""
    warn "IMPORTANTE: $INSTALL_DIR no está en tu PATH."
    warn "Añade esta línea a tu ~/.bashrc, ~/.zshrc o equivalente:"
    warn ""
    warn "  export PATH=\"$INSTALL_DIR:\$PATH\""
    warn ""
  fi

  if "$INSTALL_DIR/$binary_in_archive" --version >/dev/null 2>&1; then
    installed_version=$("$INSTALL_DIR/$binary_in_archive" --version 2>&1 | awk '{print $NF}')
    info ""
    info "$BINARY $installed_version instalado correctamente."
    info ""
    info "Primeros pasos:"
    info "  $BINARY login              # Iniciar sesión con Google"
    info "  $BINARY whoami             # Confirmar identidad"
    info "  $BINARY describe           # Listar queries disponibles"
    info "  $BINARY update             # Actualizar a la última versión"
    info "  $BINARY --help             # Ver todos los comandos"
  else
    error "La instalación falló. El binario no se ejecuta correctamente."
  fi
}

main
