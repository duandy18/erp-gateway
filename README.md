# erp-gateway

ERP local gateway and reverse proxy contracts.

ERP Gateway 是统一入口，不承载业务逻辑，不读业务数据库，不替代各业务系统。

## Local entry

    http://127.0.0.1:7080

## Current routes

    /                -> erp-web:5170
    /wms             -> wms-web:5173
    /pms             -> pms-web:5174
    /oms             -> oms-web:5175
    /procurement     -> procurement-web:5176
    /logistics       -> logistics-web:5177

    /api/erp         -> erp-api:7990
    /api/wms         -> wms-api:8000
    /api/pms         -> pms-api:8005
    /api/oms         -> oms-api:8010
    /api/procurement -> procurement-api:8015
    /api/logistics   -> logistics-api:8020

## Run

Start local backends first:

    cd ~/erp-api
    make local-backends-up

Start erp-web in gateway mode:

    cd ~/erp-web
    VITE_API_BASE_URL=/api/erp pnpm dev

Start gateway:

    cd ~/erp-gateway
    make lint
    make up
    make smoke

Then open:

    http://127.0.0.1:7080/
