# erp-gateway

ERP local gateway and reverse proxy contracts.

ERP Gateway 是统一入口，不承载业务逻辑，不读业务数据库，不替代各业务系统。

## Local entry

    http://127.0.0.1:7080/

## Current routes

    /                -> erp-web:5170 dev proxy

    /wms             -> static dist ../wms-web/dist
    /pms             -> static dist ../pms-web/dist
    /oms             -> static dist ../oms-web/dist
    /procurement     -> static dist ../procurement-web/dist
    /logistics       -> static dist ../logistics-web/dist

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

Start ERP Web in gateway mode:

    cd ~/erp-web
    pnpm dev:gateway

Build registered app frontend artifacts:

    cd ~/erp-gateway
    make apps-build

Start Gateway:

    cd ~/erp-gateway
    make lint
    make up

Run smoke checks:

    make smoke
    make full-smoke

Then open:

    http://127.0.0.1:7080/

## Notes

- Use Gateway as the normal local entry.
- Do not use `5170` as the normal ERP entry.
- Independent app frontend dev servers are not required for the normal Gateway entry flow.
- Gateway serves WMS / PMS / OMS / Procurement / Logistics from their built `dist` artifacts.
- Re-run `make apps-build` after changing any registered app frontend.
