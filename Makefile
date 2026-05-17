.RECIPEPREFIX := >

COMPOSE ?= docker compose
NGINX_IMAGE ?= nginx:1.27-alpine
GATEWAY_BASE_URL ?= http://127.0.0.1:7080
PNPM ?= pnpm

WMS_WEB_DIR ?= ../wms-web
PMS_WEB_DIR ?= ../pms-web
OMS_WEB_DIR ?= ../oms-web
PROCUREMENT_WEB_DIR ?= ../procurement-web
LOGISTICS_WEB_DIR ?= ../logistics-web

.PHONY: lint up down restart ps logs smoke apps-build full-smoke

lint:
> docker run --rm --add-host=host.docker.internal:host-gateway -v "$$(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" -v "$$(pwd)/nginx/conf.d:/etc/nginx/conf.d:ro" $(NGINX_IMAGE) nginx -t

up:
> $(COMPOSE) up -d

down:
> $(COMPOSE) down

restart:
> $(COMPOSE) down
> $(COMPOSE) up -d

ps:
> $(COMPOSE) ps

logs:
> $(COMPOSE) logs -f erp-gateway

smoke:
> @for i in $$(seq 1 20); do \
>   if curl -fsS "$(GATEWAY_BASE_URL)/healthz" >/dev/null 2>/dev/null; then \
>     echo "gateway healthz OK"; \
>     break; \
>   fi; \
>   if [ "$$i" = "20" ]; then \
>     echo "gateway healthz FAILED" >&2; \
>     exit 1; \
>   fi; \
>   sleep 0.5; \
> done
> curl -fsS "$(GATEWAY_BASE_URL)/healthz"
> curl -fsS "$(GATEWAY_BASE_URL)/api/erp/healthz"

apps-build:
> cd $(WMS_WEB_DIR) && VITE_APP_BASE_PATH=/wms/ VITE_API_BASE_URL=/api/wms $(PNPM) build
> cd $(PMS_WEB_DIR) && VITE_APP_BASE_PATH=/pms/ VITE_API_BASE_URL=/api/pms $(PNPM) build
> cd $(OMS_WEB_DIR) && VITE_APP_BASE_PATH=/oms/ VITE_OMS_API_BASE_URL=/api/oms $(PNPM) build
> cd $(PROCUREMENT_WEB_DIR) && VITE_APP_BASE_PATH=/procurement/ VITE_PROCUREMENT_API_BASE_URL=/api/procurement $(PNPM) build
> cd $(LOGISTICS_WEB_DIR) && VITE_APP_BASE_PATH=/logistics/ VITE_API_BASE_URL=/api/logistics $(PNPM) build

full-smoke:
> @set -eu; \
> for i in $$(seq 1 20); do \
>   if curl -fsS "$(GATEWAY_BASE_URL)/healthz" >/dev/null 2>/dev/null; then \
>     echo "gateway healthz OK"; \
>     break; \
>   fi; \
>   if [ "$$i" = "20" ]; then \
>     echo "gateway healthz FAILED" >&2; \
>     exit 1; \
>   fi; \
>   sleep 0.5; \
> done; \
> for path in / /wms/ /pms/ /oms/ /procurement/ /logistics/; do \
>   code=$$(curl -sS -o /tmp/erp-gateway-full-smoke-body.txt -w "%{http_code}" "$(GATEWAY_BASE_URL)$$path"); \
>   echo "web $$path $$code"; \
>   test "$$code" = "200"; \
> done; \
> for path in /api/erp/healthz /api/wms/healthz /api/pms/healthz /api/oms/healthz /api/procurement/healthz /api/logistics/healthz; do \
>   echo "api $$path"; \
>   curl -fsS "$(GATEWAY_BASE_URL)$$path" >/dev/null; \
> done; \
> echo "full-smoke OK"
