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

.PHONY: lint up down restart ps logs
.PHONY: smoke full-smoke
.PHONY: apps-build build-apps
.PHONY: build-wms build-pms build-oms build-procurement build-logistics
.PHONY: check-dist check-wms-dist check-pms-dist check-oms-dist check-procurement-dist check-logistics-dist
.PHONY: check-app-dists apps-dist-check
.PHONY: smoke-web smoke-wms-web smoke-pms-web smoke-oms-web smoke-procurement-web smoke-logistics-web smoke-app-webs
.PHONY: smoke-api smoke-wms-api smoke-pms-api smoke-oms-api smoke-procurement-api smoke-logistics-api smoke-app-apis

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
>     false; \
>   fi; \
>   sleep 0.5; \
> done
> curl -fsS "$(GATEWAY_BASE_URL)/healthz"
> curl -fsS "$(GATEWAY_BASE_URL)/api/erp/healthz"

build-wms:
> cd $(WMS_WEB_DIR) && VITE_APP_BASE_PATH=/wms/ VITE_API_BASE_URL=/api/wms $(PNPM) build

build-pms:
> cd $(PMS_WEB_DIR) && VITE_APP_BASE_PATH=/pms/ VITE_API_BASE_URL=/api/pms $(PNPM) build

build-oms:
> cd $(OMS_WEB_DIR) && VITE_APP_BASE_PATH=/oms/ VITE_OMS_API_BASE_URL=/api/oms $(PNPM) build

build-procurement:
> cd $(PROCUREMENT_WEB_DIR) && VITE_APP_BASE_PATH=/procurement/ VITE_API_BASE_URL=/api/procurement $(PNPM) build

build-logistics:
> cd $(LOGISTICS_WEB_DIR) && VITE_APP_BASE_PATH=/logistics/ VITE_API_BASE_URL=/api/logistics $(PNPM) build

apps-build: build-wms build-pms build-oms build-procurement build-logistics

build-apps: apps-build

check-dist:
> @set -eu; \
> case "$(APP)" in \
>   wms) APP_NAME="WMS"; WEB_DIR="$(WMS_WEB_DIR)"; BASE_PATH="/wms";; \
>   pms) APP_NAME="PMS"; WEB_DIR="$(PMS_WEB_DIR)"; BASE_PATH="/pms";; \
>   oms) APP_NAME="OMS"; WEB_DIR="$(OMS_WEB_DIR)"; BASE_PATH="/oms";; \
>   procurement) APP_NAME="Procurement"; WEB_DIR="$(PROCUREMENT_WEB_DIR)"; BASE_PATH="/procurement";; \
>   logistics) APP_NAME="Logistics"; WEB_DIR="$(LOGISTICS_WEB_DIR)"; BASE_PATH="/logistics";; \
>   *) echo "APP must be one of: wms, pms, oms, procurement, logistics" >&2; false;; \
> esac; \
> INDEX="$$WEB_DIR/dist/index.html"; \
> DIST="$$WEB_DIR/dist"; \
> echo "checking $$APP_NAME dist: $$INDEX base=$$BASE_PATH"; \
> test -f "$$INDEX"; \
> grep -Eq "src=\"$$BASE_PATH/assets|href=\"$$BASE_PATH/assets" "$$INDEX"; \
> if grep -Eq 'src="/assets|href="/assets' "$$INDEX"; then \
>   echo "FAILED: $$APP_NAME dist contains root /assets references" >&2; \
>   false; \
> fi; \
> ASSETS=$$(grep -o "$$BASE_PATH"'/assets/[^"]*' "$$INDEX" | sort -u); \
> test -n "$$ASSETS"; \
> for asset in $$ASSETS; do \
>   rel="$${asset#$$BASE_PATH/}"; \
>   if [ ! -f "$$DIST/$$rel" ]; then \
>     echo "FAILED: $$APP_NAME dist missing asset $$asset -> $$DIST/$$rel" >&2; \
>     false; \
>   fi; \
> done; \
> echo "$$APP_NAME dist base path OK"

check-wms-dist:
> @$(MAKE) check-dist APP=wms

check-pms-dist:
> @$(MAKE) check-dist APP=pms

check-oms-dist:
> @$(MAKE) check-dist APP=oms

check-procurement-dist:
> @$(MAKE) check-dist APP=procurement

check-logistics-dist:
> @$(MAKE) check-dist APP=logistics

check-app-dists: check-wms-dist check-pms-dist check-oms-dist check-procurement-dist check-logistics-dist

apps-dist-check: check-app-dists

smoke-web:
> @set -eu; \
> case "$(APP)" in \
>   wms) APP_NAME="WMS"; BASE_PATH="/wms";; \
>   pms) APP_NAME="PMS"; BASE_PATH="/pms";; \
>   oms) APP_NAME="OMS"; BASE_PATH="/oms";; \
>   procurement) APP_NAME="Procurement"; BASE_PATH="/procurement";; \
>   logistics) APP_NAME="Logistics"; BASE_PATH="/logistics";; \
>   *) echo "APP must be one of: wms, pms, oms, procurement, logistics" >&2; false;; \
> esac; \
> BODY="/tmp/erp-gateway-$${APP:-app}-web-smoke.html"; \
> CODE=$$(curl -sS -o "$$BODY" -w "%{http_code}" "$(GATEWAY_BASE_URL)$$BASE_PATH/"); \
> echo "web $$APP_NAME $$BASE_PATH/ $$CODE"; \
> test "$$CODE" = "200"; \
> grep -Eq "src=\"$$BASE_PATH/assets|href=\"$$BASE_PATH/assets" "$$BODY"; \
> if grep -Eq 'src="/assets|href="/assets' "$$BODY"; then \
>   echo "FAILED: $$APP_NAME gateway HTML contains root /assets references" >&2; \
>   false; \
> fi; \
> ASSETS=$$(grep -o "$$BASE_PATH"'/assets/[^"]*' "$$BODY" | sort -u); \
> test -n "$$ASSETS"; \
> for asset in $$ASSETS; do \
>   code=$$(curl -sS -o /tmp/erp-gateway-asset-smoke-body.txt -w "%{http_code}" "$(GATEWAY_BASE_URL)$$asset"); \
>   echo "asset $$asset $$code"; \
>   test "$$code" = "200"; \
> done; \
> echo "$$APP_NAME gateway web smoke OK"

smoke-wms-web:
> @$(MAKE) smoke-web APP=wms

smoke-pms-web:
> @$(MAKE) smoke-web APP=pms

smoke-oms-web:
> @$(MAKE) smoke-web APP=oms

smoke-procurement-web:
> @$(MAKE) smoke-web APP=procurement

smoke-logistics-web:
> @$(MAKE) smoke-web APP=logistics

smoke-app-webs: smoke-wms-web smoke-pms-web smoke-oms-web smoke-procurement-web smoke-logistics-web

smoke-api:
> @set -eu; \
> case "$(APP)" in \
>   wms) APP_NAME="WMS"; API_PATH="/api/wms/healthz";; \
>   pms) APP_NAME="PMS"; API_PATH="/api/pms/healthz";; \
>   oms) APP_NAME="OMS"; API_PATH="/api/oms/healthz";; \
>   procurement) APP_NAME="Procurement"; API_PATH="/api/procurement/healthz";; \
>   logistics) APP_NAME="Logistics"; API_PATH="/api/logistics/healthz";; \
>   *) echo "APP must be one of: wms, pms, oms, procurement, logistics" >&2; false;; \
> esac; \
> echo "api $$APP_NAME $$API_PATH"; \
> curl -fsS "$(GATEWAY_BASE_URL)$$API_PATH" >/dev/null; \
> echo "$$APP_NAME gateway api smoke OK"

smoke-wms-api:
> @$(MAKE) smoke-api APP=wms

smoke-pms-api:
> @$(MAKE) smoke-api APP=pms

smoke-oms-api:
> @$(MAKE) smoke-api APP=oms

smoke-procurement-api:
> @$(MAKE) smoke-api APP=procurement

smoke-logistics-api:
> @$(MAKE) smoke-api APP=logistics

smoke-app-apis: smoke-wms-api smoke-pms-api smoke-oms-api smoke-procurement-api smoke-logistics-api

full-smoke: smoke smoke-app-webs smoke-app-apis
> @echo "full-smoke OK"
