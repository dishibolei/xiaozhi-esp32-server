# 本地服务启动指南

## 服务总览

| 服务 | 目录 | 技术栈 | 默认端口 | 说明 |
|------|------|--------|---------|------|
| xiaozhi-server | main/xiaozhi-server | Python | 8000 (WebSocket) / 8003 (HTTP) | 核心对话服务 |
| manager-api | main/manager-api | Java Spring Boot | 8002 | 后台 API（OTA、用户管理） |
| manager-web | main/manager-web | Vue.js | 8001 | 智控台 Web 管理界面 |
| manager-mobile | main/manager-mobile | Vue/UniApp | Vite 默认 | 智控台 H5 移动端 |
| digital-human | main/digital-human | Python | 8006 | 音频交互测试工具 |

## 启动顺序

推荐顺序：
1. MySQL + Redis（manager-api 依赖）
2. manager-api（提供后端 API）
3. xiaozhi-server
4. manager-web
5. manager-mobile
6. digital-human（可选，独立运行）

---

## 1. manager-api（Java 后端 API）

端口: 8002

前置依赖: JDK 21, Maven 3.8+, MySQL 8.0+, Redis 5.0+

启动:

\`\`\`bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/manager-api
mvn spring-boot:run
\`\`\`

验证: curl http://localhost:8002/xiaozhi/doc.html

说明: 提供 OTA 接口 /xiaozhi/ota/，设备/用户/智能体管理接口

---

## 2. xiaozhi-server（Python 核心对话服务）

端口: 8000 (WebSocket) / 8003 (HTTP)

前置依赖: Python 3.10, FFmpeg

首次安装依赖:

\`\`\`bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/xiaozhi-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
\`\`\`

启动:

\`\`\`bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/xiaozhi-server
python app.py
\`\`\`

验证: curl http://localhost:8003/health

HTTP 服务端口 8003，WebSocket 服务端口 8000。

---

## 3. manager-web（Vue.js 智控台 Web）

端口: 8001

前置依赖: Node.js

首次安装: cd main/manager-web && npm install

启动:

\`\`\`bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/manager-web
npm run serve
\`\`\`

验证: curl http://localhost:8001/

内置 proxy: /xiaozhi -> localhost:8002

---

## 4. manager-mobile（H5 移动端）

端口: Vite 默认（通常 5173）

前置依赖: Node.js, pnpm

首次安装: cd main/manager-mobile && pnpm install

启动:

\`\`\`bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/manager-mobile
npm run dev
\`\`\`

---

## 5. digital-human（音频交互测试工具）

端口: 8006

前置依赖: Python 3

启动:

\`\`\`bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/digital-human
python start.py
\`\`\`

验证: curl http://localhost:8006/

独立运行，不依赖其他服务。

---

## 快捷启动（最小组合）

终端 1:
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/xiaozhi-server && python app.py

终端 2:
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/manager-web && npm run serve

终端 3（可选）:
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/manager-api && mvn spring-boot:run

---

## 端口被占用

lsof -i :8000 或 lsof -i :8001 查看占用，kill -9 PID 释放。

## Python 虚拟环境

新开终端启动前先激活: cd main/xiaozhi-server && source venv/bin/activate

## 停止服务

全部前台进程，Ctrl+C 优雅关闭。
