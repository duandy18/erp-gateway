.RECIPEPREFIX := >

COMPOSE ?= docker compose
NGINX_IMAGE ?= nginx:1.27-alpine

.PHONY: lint up down restart ps logs smoke

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
>   if curl -fsS http://127.0.0.1:7080/healthz >/dev/null 2>/dev/null; then \
>     echo "gateway healthz OK"; \
>     break; \
>   fi; \
>   if [ "$$i" = "20" ]; then \
>     echo "gateway healthz FAILED" >&2; \
>     exit 1; \
>   fi; \
>   sleep 0.5; \
> done
> curl -fsS http://127.0.0.1:7080/healthz
> curl -fsS http://127.0.0.1:7080/api/erp/healthz
