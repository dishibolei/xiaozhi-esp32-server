#!/bin/bash
#
# xiaozhi-esp32-server 本地服务交互式启动器
# 引导用户逐个选择并启动服务，每个服务在独立终端窗口中运行

set -euo pipefail

BASE_DIR="/Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server"

info()  { echo -e "\033[36m[I]\033[0m $1"; }
ok()    { echo -e "\033[32m[V]\033[0m $1"; }
warn()  { echo -e "\033[33m[!]\033[0m $1"; }
err()   { echo -e "\033[31m[X]\033[0m $1"; }
title() { echo -e "\n\033[1;34m==== $1 ====\033[0m\n"; }

IDX_MANAGER_API=0
IDX_XIAOZHI=1
IDX_MANAGER_WEB=2
IDX_MOBILE=3
IDX_DIGITAL_HUMAN=4

SERVICE_NAMES=("manager-api" "xiaozhi-server" "manager-web" "manager-mobile" "digital-human")
SERVICE_DIRS=(
  "main/manager-api"
  "main/xiaozhi-server"
  "main/manager-web"
  "main/manager-mobile"
  "main/digital-human"
)
SERVICE_TECH=("Java Spring Boot" "Python" "Vue.js" "Vue/UniApp" "Python")
SERVICE_PORTS=("8002" "8000/8003" "8001" "Vite udefault" "8006")
SERVICE_CMDS=(
  "mvn spring-boot:run"
  "source venv/bin/activate && python app.py"
  "npm run serve"
  "npm run dev"
  "python start.py"
)
SERVICE_DEPS=(
  "JDK 21, Maven 3.8+, MySQL 8.0+, Redis 5.0+"
  "Python 3.10, FFmpeg"
  "Node.js"
  "Node.js, pnpm"
  "Python 3"
)

open_terminal() {
  local workdir="$1" cmd="$2" title="$3"
  local escaped_cmd
  escaped_cmd=$(printf '%s' "$cmd" | sed 's/"/\\"/g')
  osascript <<EOF
tell application "Terminal"
  activate
  tell application "System Events" to keystroke "t" using command down
  delay 0.3
  do script "clear && echo '=== $title ===' && cd \"$workdir\" && $escaped_cmd" in front window
end tell
EOF
}

start_service() {
  local name="$1" idx="" dir="" tech="" port="" cmd="" deps=""
  for i in "${!SERVICE_NAMES[@]}"; do
    if [[ "${SERVICE_NAMES[$i]}" == "$name" ]]; then
      idx=$i
      dir="${SERVICE_DIRS[$i]}"
      tech="${SERVICE_TECH[$i]}"
      port="${SERVICE_PORTS[$i]}"
      cmd="${SERVICE_CMDS[$i]}"
      deps="${SERVICE_DEPS[$i]}"
      break
    fi
  done
  if [[ -z "$idx" ]]; then err "unknown service: $name"; return; fi

  title "Launch $name"
  echo "  dir : $BASE_DIR/$dir"
  echo "  port: $port"
  echo "  tech: $tech"
  echo "  deps: $deps"
  echo ""

  read -r -p "  Press Enter to start (or type s to skip) " choice
  if [[ "$choice" == "s" || "$choice" == "S" ]]; then
    warn "skipped $name"
    return
  fi

  open_terminal "$BASE_DIR/$dir" "$cmd" "$name"
  ok "$name started in new terminal window"
  sleep 1
}

check_port() {
  local port="$1" label="$2"
  if lsof -i :"$port" >/dev/null 2>&1; then
    ok "$label (port $port) running"
  else
    warn "$label (port $port) not running"
  fi
}

show_status() {
  title "Port Status"
  check_port 8000 "xiaozhi WS"
  check_port 8001 "manager-web"
  check_port 8002 "manager-api"
  check_port 8003 "xiaozhi HTTP"
  check_port 8006 "digital-human"
}

start_all() {
  info "Starting services in dependency order..."
  start_service "manager-api"
  start_service "xiaozhi-server"
  start_service "manager-web"
  start_service "manager-mobile"
  start_service "digital-human"
  show_status
}

menu() {
  while true; do
    title "xiaozhi-esp32-server Service Launcher"
    echo "  Available services:"
    for i in "${!SERVICE_NAMES[@]}"; do
      printf "  [%d] %-16s %-10s %s\n" $((i+1)) "${SERVICE_NAMES[$i]}" "(${SERVICE_PORTS[$i]})" "${SERVICE_TECH[$i]}"
    done
    echo "  [a] Start all (in dependency order)"
    echo "  [s] Check port status"
    echo "  [q] Quit"
    echo ""
    read -r -p "  Choose (1-5 / a / s / q): " c
    echo ""

    case "$c" in
      1) start_service "manager-api" ;;
      2) start_service "xiaozhi-server" ;;
      3) start_service "manager-web" ;;
      4) start_service "manager-mobile" ;;
      5) start_service "digital-human" ;;
      a|A) start_all ;;
      s|S) show_status ;;
      q|Q) info "bye"; exit 0 ;;
      *) warn "invalid: $c" ;;
    esac
    echo ""
    read -r -p "  Press Enter to return to menu..."
  done
}

menu
