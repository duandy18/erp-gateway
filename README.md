# erp-gateway

ERP local gateway and reverse proxy contracts.

ERP Gateway 是统一入口，不承载业务逻辑，不读业务数据库，不替代各业务系统。

## Local entry

    http://127.0.0.1:7080

## Current routes

    /         -> erp-web:5170
    /api/erp  -> erp-api:7990

## Run

Start erp-api first:

    cd ~/erp-api
    make uvicorn

Start erp-web in gateway mode:

    cd ~/erp-web
    VITE_API_BASE_URL=/api/erp pnpm dev

Start gateway:

    cd ~/erp-gateway
    make lint
    make up
    make smoke
