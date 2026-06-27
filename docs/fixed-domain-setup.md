# 固定域名访问配置

## 概述

通过 Cloudflare Tunnel 将本地多个服务映射到固定域名 `leibo-tech.online`，重启后 IP 变化不影响域名访问。

## 服务端口映射

| 本地服务 | 端口 | 域名路径 |
|---------|------|---------|
| 管理平台 (vue dev server) | 8001 | `leibo-tech.online/` |
| xiaozhi-server WebSocket | 8000 | `leibo-tech.online/xiaozhi/v1/*` |
| xiaozhi-server OTA (通过 vue proxy) | 8002 | `leibo-tech.online/xiaozhi/ota/` |

## 前提条件

- 域名 `leibo-tech.online` 已托管到 Cloudflare
- Cloudflare Tunnel 已创建 (本机 tunnel 名: `my-home`)
- 本地已安装 `cloudflared`

## 配置文件

`~/.cloudflared/config.yml`:

```yaml
tunnel: my-home
credentials-file: /Users/bl/.cloudflared/2d2c08db-5452-45ac-a041-5c1190e2ed62.json

ingress:
  - hostname: leibo-tech.online
    path: /xiaozhi/v1/*
    service: http://localhost:8000
  - hostname: leibo-tech.online
    service: http://localhost:8001
  - service: http_status:404
```

## 管理平台 Host 校验

`manager-web/vue.config.js` 需要在 `devServer` 中添加:

```js
allowedHosts: 'all',
```

已配置，无需重复操作。

## 手动启动

### 启动本地服务

**终端 1 — xiaozhi-server**:

```bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/xiaozhi-server
# 启动 xiaozhi-server，确认 8000 和 8002 端口已监听
```

**终端 2 — 管理平台**:

```bash
cd /Users/bl/Documents/workplace/desk-bot/xiaozhi-esp32-server/main/manager-web
npm run serve
```

### 启动 tunnel

```bash
/tmp/cloudflared tunnel --config ~/.cloudflared/config.yml run my-home
```

### 验证

```bash
curl https://leibo-tech.online/                    # 管理平台
curl https://leibo-tech.online/xiaozhi/ota/        # OTA
curl -i -N -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  https://leibo-tech.online/xiaozhi/v1/            # WebSocket
```

## 开机自启

### 安装 LaunchDaemon

plist 文件位置: `~/Library/LaunchAgents/com.cloudflared.tunnel.plist`

```bash
cp /tmp/com.cloudflared.plist ~/Library/LaunchAgents/com.cloudflared.plist
launchctl load ~/Library/LaunchAgents/com.cloudflared.plist
```

之后 Mac 重启 tunnel 自动拉起。

### 停止自启

```bash
launchctl unload ~/Library/LaunchAgents/com.cloudflared.plist
```

### 手动启停 tunnel

```bash
# 启动
launchctl load ~/Library/LaunchAgents/com.cloudflared.plist

# 停止
launchctl unload ~/Library/LaunchAgents/com.cloudflared.plist

# 查看状态
launchctl list | grep cloudflared

# 查看日志
tail -f /tmp/cloudflared.log
tail -f /tmp/cloudflared.err
```

## 编辑 Tunnel 配置

更新 ingress 路由后重载 tunnel:

```bash
# 1. 编辑配置文件
vim ~/.cloudflared/config.yml

# 2. 重启 tunnel（不需要卸载，直接 load 会重载）
launchctl unload ~/Library/LaunchAgents/com.cloudflared.plist
launchctl load ~/Library/LaunchAgents/com.cloudflared.plist
```
