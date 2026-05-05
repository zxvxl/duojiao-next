# Dujiao-Next Source Deploy

这套部署文件用于二开场景：Docker Compose 会从当前工作区的 `api`、`user`、`admin` 源码构建镜像。

## 启动

```bash
cd /Users/zz/Documents/zwp/dujiao-next/deploy
DOCKER_BUILDKIT=0 docker compose --env-file .env -f docker-compose.source.sqlite.yml up -d --build
```

## 查看状态

```bash
docker compose --env-file .env -f docker-compose.source.sqlite.yml ps
docker compose --env-file .env -f docker-compose.source.sqlite.yml logs -f api
```

## 本机访问

- API: http://127.0.0.1:8080/health
- User: http://127.0.0.1:8081
- Admin: http://127.0.0.1:8082

## 服务器访问

容器端口只绑定到 `127.0.0.1`，生产环境建议用宿主机 Nginx 反代。示例见 `nginx.example.conf`。

如果你要复用旧服务器 `/opt/dujiao-next/config/config.yml`，至少需要补齐当前版本新增字段：

- `app.secret_key`
- `app.totp_issuer`
- `order.max_refund_days`
- `web.admin_path`

同时建议把 `server.mode` 改为 `release`，并确保 `database.dsn` 在 Docker 中使用 `/app/db/dujiao.db`。
