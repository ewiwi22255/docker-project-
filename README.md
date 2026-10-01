# ERP 系統 Docker 部署包

[![smoke-test](https://github.com/ewiwi22255/docker-project-/actions/workflows/smoke-test.yml/badge.svg)](https://github.com/ewiwi22255/docker-project-/actions/workflows/smoke-test.yml)

這個 repo **只負責部署**：不含原始碼，直接下載已經打包好的 Docker 映像來啟動 ERP 系統（React 前端 + FastAPI 後端 + SQLite 資料庫）。

映像來源：[ewiwi22255/docker-project-test](https://github.com/ewiwi22255/docker-project-test)（原始碼在那裡，每次更新會自動建置並發布到 GitHub Container Registry）。

```text
瀏覽器 ──► web（nginx，對外 80 埠）
             ├─ /         → React 前端
             └─ /api/     → api（FastAPI :8000）
                              └─ 資料庫存在 Docker volume「erp-data」
```

## 檔案說明

| 檔案 | 用途 |
|---|---|
| `docker-compose.yml` | 定義要啟動的服務與使用的映像 |
| `.env.docker.example` | 設定範本（埠號、示範模式、AI 金鑰） |
| `start.sh` | 一鍵啟動：建立設定檔 → 下載映像 → 啟動 |
| `.devcontainer/` | GitHub Codespaces 設定 |
| `.github/workflows/smoke-test.yml` | 在 GitHub 上自動測試能否正常啟動 |

## 方法一：在 GitHub 上直接執行（Codespaces）

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ewiwi22255/docker-project-?quickstart=1)

1. 點上方按鈕（或在 repo 頁面按綠色 **Code** → **Codespaces** → **Create codespace on main**）。
2. Codespace 開好後，在下方終端機執行：

   ```bash
   bash start.sh
   ```

   不用建置，只要下載映像，約 1–2 分鐘。看到「ERP 已啟動」就完成了。
3. 到下方 **PORTS（連接埠）** 分頁，點 `8080` 旁的地球圖示開啟網頁。
4. 用 `admin / admin` 登入。

> [!TIP]
> Codespace 開啟時也會自動執行一次 `start.sh`，再手動執行不會衝突。用完記得到 https://github.com/codespaces 停止或刪除，避免耗用免費時數。

## 方法二：在自己的電腦或伺服器執行

### 1. 安裝 Docker

需要 **Docker Engine** 與 **Docker Compose v2**（指令是 `docker compose`，中間是空格）。

- Windows / macOS：安裝 [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Ubuntu：照 [官方教學](https://docs.docker.com/engine/install/ubuntu/) 安裝 `docker-ce` 與 `docker-compose-plugin`

> [!NOTE]
> Ubuntu 內建的 `docker.io` + 舊版 `docker-compose`（中間是減號）不支援這個 compose 檔的語法，請用官方套件。

### 2. 下載並啟動

```bash
git clone https://github.com/ewiwi22255/docker-project-.git
cd docker-project-
bash start.sh
```

Linux 上若出現 `permission denied`，改用 `sudo bash start.sh`，或執行 `sudo usermod -aG docker $USER` 後重新登入。

不想用腳本，也可以手動執行：

```bash
cp .env.docker.example .env.docker
docker compose --env-file .env.docker pull
docker compose --env-file .env.docker up -d
```

### 3. 開啟網頁

瀏覽器開 `http://localhost`，其他電腦則用 `http://<主機 IP>`（Linux 用 `hostname -I` 查詢）。

示範帳號（帳號密碼相同）：

| 帳號 | 角色 |
|---|---|
| `admin` | 系統管理員 |
| `viewer` | 風險觀測員 |
| `planner` | 供應鏈規劃員 |
| `approver` | 採購核准主管 |

## 常用指令

| 動作 | 指令 |
|---|---|
| 查看狀態 | `docker compose ps` |
| 看即時紀錄 | `docker compose logs -f api` |
| 停止 | `docker compose down` |
| 更新到最新版 | `bash start.sh`（會重新下載最新映像） |
| **清除所有資料** | `docker compose down -v`（刪除資料庫，無法復原） |

## 設定

編輯 `.env.docker`（第一次執行 `start.sh` 時會自動從範本建立）：

| 設定 | 說明 | 預設 |
|---|---|---|
| `ERP_HTTP_PORT` | 對外埠號 | `80` |
| `ERP_DEMO_MODE` | 建立示範帳號與資料，**公開網路請改 false** | `true` |
| `ERP_BACKEND_IMAGE` / `ERP_WEB_IMAGE` | 指定映像版本 | `latest` |
| `LLM_MODEL` + `GEMINI_API_KEY` / `OPENAI_API_KEY` | 啟用 AI 分析 | 未設定 |

改完設定後執行 `bash start.sh` 套用。

## 常見問題

- **80 埠被占用**：把 `.env.docker` 的 `ERP_HTTP_PORT` 改成 `8080`，網址改為 `http://localhost:8080`。
- **`env_file` 相關錯誤**：Compose 版本太舊，請升級到 v2.24 以上。
- **Codespace 出現 recovery mode**：按 `Ctrl + Shift + P` → **Codespaces: Rebuild Container**。
