# Local Dev Gateway

## Prerequisites

- Docker
- erp-api running on 7990
- erp-web running on 5170 with VITE_API_BASE_URL=/api/erp

## Start

    cd ~/erp-gateway
    make lint
    make up

## Smoke checks

    curl -fsS http://127.0.0.1:7080/healthz
    curl -fsS http://127.0.0.1:7080/api/erp/healthz
    curl -I http://127.0.0.1:7080/

## Stop

    make down
