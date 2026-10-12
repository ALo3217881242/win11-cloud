#!/usr/bin/env bash
# win11-cloud: tải + cài + bật Windows tiny11 core 25H2 và Remote Desktop trên trình duyệt.
#
#   bash start.sh          bật (tự chạy mỗi khi codespace khởi động)
#   bash start.sh status   xem trạng thái + đường link
#   bash start.sh logs     xem log cài đặt Windows
#   bash start.sh stop     tắt Windows an toàn
set -euo pipefail
shopt -u patsub_replacement 2>/dev/null || true   # bash 5.2: '&' trong thay thế chuỗi là ký tự thường
cd "$(dirname "$0")"

RUNTIME=".runtime"
ENV_FILE="$RUNTIME/win.env"
GUAC_DIR="$RUNTIME/guacamole"

say()  { printf '\033[1;36m[win11-cloud]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[win11-cloud] LỖI:\033[0m %s\n' "$*" >&2; exit 1; }

xml_escape() {
  local s="$1"
  s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"
  s="${s//\"/&quot;}"; s="${s//\'/&apos;}"
  printf '%s' "$s"
}

port_url() {
  if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
    printf 'https://%s-%s.%s' "$CODESPACE_NAME" "$1" "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
  else
    printf 'http://localhost:%s' "$1"
  fi
}

load_credentials() {
  # Ưu tiên: Codespaces secret WIN_PASSWORD -> mật khẩu đã lưu lần trước -> hỏi trực tiếp
  local secret_pw="${WIN_PASSWORD:-}" secret_user="${WIN_USER:-}"
  if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
  fi
  [ -n "$secret_pw" ] && WIN_PASSWORD="$secret_pw"
  [ -n "$secret_user" ] && WIN_USER="$secret_user"
  WIN_USER="${WIN_USER:-Admin}"

  if [ -z "${WIN_PASSWORD:-}" ]; then
    if [ -t 0 ]; then
      read -rsp "Nhập mật khẩu cho Windows (user $WIN_USER): " WIN_PASSWORD; echo
      [ -n "$WIN_PASSWORD" ] || fail "Mật khẩu không được để trống."
    else
      say "Chưa có mật khẩu (secret WIN_PASSWORD). Mở Terminal và chạy:  bash start.sh"
      exit 0
    fi
  fi

  mkdir -p "$RUNTIME"; chmod 700 "$RUNTIME"
  ( umask 077; printf 'WIN_USER=%q\nWIN_PASSWORD=%q\n' "$WIN_USER" "$WIN_PASSWORD" > "$ENV_FILE" )
  export WIN_USER WIN_PASSWORD
}

write_guacamole_config() {
  local u p
  u="$(xml_escape "$WIN_USER")"; p="$(xml_escape "$WIN_PASSWORD")"
  mkdir -p "$GUAC_DIR"; chmod 755 "$GUAC_DIR"
  cat > "$GUAC_DIR/user-mapping.xml" <<EOF
<user-mapping>
  <authorize username="$u" password="$p">
    <connection name="Windows tiny11">
      <protocol>rdp</protocol>
      <param name="hostname">windows</param>
      <param name="port">3389</param>
      <param name="username">$u</param>
      <param name="password">$p</param>
      <param name="security">any</param>
      <param name="ignore-cert">true</param>
      <param name="resize-method">display-update</param>
      <param name="timezone">Asia/Ho_Chi_Minh</param>
      <param name="enable-wallpaper">false</param>
      <param name="enable-theming">false</param>
      <param name="enable-font-smoothing">false</param>
      <param name="enable-full-window-drag">false</param>
      <param name="enable-desktop-composition">false</param>
      <param name="enable-menu-animations">false</param>
      <param name="enable-drive">true</param>
      <param name="drive-name">ChuyenFile</param>
      <param name="drive-path">/tmp/guac-drive</param>
      <param name="create-drive-path">true</param>
    </connection>
  </authorize>
</user-mapping>
EOF
  chmod 644 "$GUAC_DIR/user-mapping.xml"
}

wait_for_docker() {
  local i
  for i in $(seq 1 90); do
    docker info >/dev/null 2>&1 && return 0
    sleep 2
  done
  fail "Docker chưa chạy. Thử: Ctrl+Shift+P -> 'Codespaces: Rebuild Container'."
}

check_devices() {
  [ -e /dev/kvm ] || fail "Máy Codespaces này không có /dev/kvm (ảo hóa). Hãy xóa codespace và tạo lại với máy 4-core."
  if [ ! -e /dev/net/tun ]; then
    sudo mkdir -p /dev/net
    sudo mknod /dev/net/tun c 10 200
    sudo chmod 666 /dev/net/tun
  fi
}

show_links() {
  echo
  say "Trang cài đặt (xem tiến trình, lần đầu ~15-25 phút):  $(port_url 8006)"
  say "Remote Desktop (dùng sau khi cài xong):             $(port_url 8080)"
  say "Đăng nhập: user '$WIN_USER' + mật khẩu bạn đã đặt.  Mở cũng được ở tab PORTS."
  echo
}

cmd="${1:-start}"
case "$cmd" in
  start)
    load_credentials
    write_guacamole_config
    mkdir -p storage
    wait_for_docker
    check_devices
    say "Đang tải image và bật Windows + Remote Desktop..."
    docker compose up -d --pull missing --remove-orphans
    show_links
    ;;
  status)
    load_credentials
    docker compose ps
    show_links
    ;;
  logs)
    load_credentials
    docker compose logs -f --tail 100 windows
    ;;
  stop)
    load_credentials
    say "Đang tắt Windows an toàn (tối đa 2 phút)..."
    docker compose down
    ;;
  *)
    echo "Dùng: bash start.sh [start|status|logs|stop]"; exit 1
    ;;
esac
