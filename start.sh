#!/usr/bin/env bash
# 一鍵啟動：建立設定檔（如果還沒有）→ 下載最新映像 → 啟動並等到服務正常。
# 用法：bash start.sh          （預設 80 埠）
#       ERP_HTTP_PORT=8080 bash start.sh
set -euo pipefail
cd "$(dirname "$0")"

# Codespace 開啟時會自動跑一次；手動同時再跑時，等前一次跑完再接著做
exec 9>/tmp/erp-start.lock
if ! flock -n 9; then
  echo "另一個啟動程序正在執行，等它完成..."
  flock 9
fi

test -f .env.docker || cp .env.docker.example .env.docker

for _ in $(seq 60); do
  docker info >/dev/null 2>&1 && break
  sleep 1
done

docker compose --env-file .env.docker pull
docker compose --env-file .env.docker up -d --wait

echo ""
echo "ERP 已啟動：瀏覽器開 http://localhost:${ERP_HTTP_PORT:-$(grep -E '^ERP_HTTP_PORT=' .env.docker | cut -d= -f2 || echo 80)}"
echo "示範帳號：admin / admin"
