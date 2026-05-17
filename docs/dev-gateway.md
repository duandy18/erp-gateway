# Local Dev Gateway

## Positioning

ERP Gateway is the local unified entry for ERP and registered business apps.

It provides:

- `/` for ERP Web.
- `/wms/`, `/pms/`, `/oms/`, `/procurement/`, `/logistics/` for built app frontend artifacts.
- `/api/erp`, `/api/wms`, `/api/pms`, `/api/oms`, `/api/procurement`, `/api/logistics` for backend API proxying.

ERP Gateway does not run business logic, does not read business databases, and does not replace each app.

## Prerequisites

- Docker
- pnpm
- ERP API and registered app backends running.
- ERP Web running on port 5170 in gateway mode.
- Built frontend artifacts for each registered app:
  - `../wms-web/dist`
  - `../pms-web/dist`
  - `../oms-web/dist`
  - `../procurement-web/dist`
  - `../logistics-web/dist`

The independent app frontend dev servers are not required for the normal gateway entry flow. Gateway serves their built `dist` artifacts.

## Start local backends

Run this from `erp-api`:

    cd ~/erp-api
    make local-backends-up

Expected backend ports:

| App | Port |
|---|---:|
| ERP API | 7990 |
| WMS API | 8000 |
| PMS API | 8005 |
| OMS API | 8010 |
| Procurement API | 8015 |
| Logistics API | 8020 |

## Start ERP Web

Run this from `erp-web`:

    cd ~/erp-web
    pnpm dev:gateway

ERP Web remains dev-proxied by Gateway at `/`.

## Build app frontend artifacts

Run this from `erp-gateway`:

    cd ~/erp-gateway
    make apps-build

This builds:

| App | Build base path | API base path | Dist mounted in Gateway |
|---|---|---|---|
| WMS | `/wms/` | `/api/wms` | `/srv/apps/wms` |
| PMS | `/pms/` | `/api/pms` | `/srv/apps/pms` |
| OMS | `/oms/` | `/api/oms` | `/srv/apps/oms` |
| Procurement | `/procurement/` | `/api/procurement` | `/srv/apps/procurement` |
| Logistics | `/logistics/` | `/api/logistics` | `/srv/apps/logistics` |

## Start Gateway

Run this from `erp-gateway`:

    cd ~/erp-gateway
    make lint
    make up

## Local entry

    http://127.0.0.1:7080/

Open ERP through Gateway. Do not use `5170` as the normal local entry.

## Smoke checks

Minimal Gateway smoke:

    make smoke

Full local entry smoke:

    make full-smoke

`make full-smoke` verifies:

- `/`
- `/wms/`
- `/pms/`
- `/oms/`
- `/procurement/`
- `/logistics/`
- `/api/erp/healthz`
- `/api/wms/healthz`
- `/api/pms/healthz`
- `/api/oms/healthz`
- `/api/procurement/healthz`
- `/api/logistics/healthz`

## Manual route checks

    curl -I http://127.0.0.1:7080/
    curl -I http://127.0.0.1:7080/wms/
    curl -I http://127.0.0.1:7080/pms/
    curl -I http://127.0.0.1:7080/oms/
    curl -I http://127.0.0.1:7080/procurement/
    curl -I http://127.0.0.1:7080/logistics/

    curl -fsS http://127.0.0.1:7080/api/erp/healthz
    curl -fsS http://127.0.0.1:7080/api/wms/healthz
    curl -fsS http://127.0.0.1:7080/api/pms/healthz
    curl -fsS http://127.0.0.1:7080/api/oms/healthz
    curl -fsS http://127.0.0.1:7080/api/procurement/healthz
    curl -fsS http://127.0.0.1:7080/api/logistics/healthz

## Stop Gateway

    cd ~/erp-gateway
    make down

## Stop local backends

Run this from `erp-api` only when the local backend stack should be stopped:

    cd ~/erp-api
    make local-backends-down
