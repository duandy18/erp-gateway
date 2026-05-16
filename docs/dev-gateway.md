# Local Dev Gateway

## Prerequisites

- Docker
- ERP API running on 7990
- ERP Web running on 5170 with `VITE_API_BASE_URL=/api/erp`
- App backends running when their API paths are used:
  - WMS API: 8000
  - PMS API: 8005
  - OMS API: 8010
  - Procurement API: 8015
  - Logistics API: 8020
- App web frontends running when entering their web paths:
  - WMS Web: 5173
  - PMS Web: 5174
  - OMS Web: 5175
  - Procurement Web: 5176
  - Logistics Web: 5177

## Start

    cd ~/erp-gateway
    make lint
    make up

## Local entry

    http://127.0.0.1:7080/

## Smoke checks

    curl -fsS http://127.0.0.1:7080/healthz
    curl -fsS http://127.0.0.1:7080/api/erp/healthz
    curl -I http://127.0.0.1:7080/

## App route checks

Run these only when the corresponding app frontend/backend is running.

    curl -I http://127.0.0.1:7080/wms/
    curl -I http://127.0.0.1:7080/pms/
    curl -I http://127.0.0.1:7080/oms/
    curl -I http://127.0.0.1:7080/procurement/
    curl -I http://127.0.0.1:7080/logistics/

    curl -fsS http://127.0.0.1:7080/api/wms/healthz
    curl -fsS http://127.0.0.1:7080/api/pms/healthz
    curl -fsS http://127.0.0.1:7080/api/oms/healthz
    curl -fsS http://127.0.0.1:7080/api/procurement/healthz
    curl -fsS http://127.0.0.1:7080/api/logistics/healthz

## Stop

    make down
