# ERP Gateway URL Contract

## Local entry

    http://127.0.0.1:7080/

## Current routes

| App | Web Path | Web Target | API Path | API Target |
|---|---|---|---|---|
| ERP | `/` | `erp-web:5170` dev proxy | `/api/erp` | `erp-api:7990` |
| WMS | `/wms` | static dist `/srv/apps/wms` | `/api/wms` | `wms-api:8000` |
| PMS | `/pms` | static dist `/srv/apps/pms` | `/api/pms` | `pms-api:8005` |
| OMS | `/oms` | static dist `/srv/apps/oms` | `/api/oms` | `oms-api:8010` |
| Procurement | `/procurement` | static dist `/srv/apps/procurement` | `/api/procurement` | `procurement-api:8015` |
| Logistics | `/logistics` | static dist `/srv/apps/logistics` | `/api/logistics` | `logistics-api:8020` |

## Web path contract

- ERP Gateway is the local unified entry.
- My Apps should open `web_path`, not `local_web_url`.
- `local_web_url` and `local_api_url` are kept for local debugging and configuration display.
- ERP Web currently remains dev-proxied from port 5170.
- Registered app web routes are served from built `dist` artifacts.
- Registered app web routes preserve app path prefixes such as `/wms`, `/pms`, `/oms`, `/procurement`, and `/logistics`.
- Each registered app must be built with its own base path before Gateway serves it.

## API path contract

- Backend API routes strip the `/api/<app>` prefix before proxying to each backend.
- `/api/erp` proxies to ERP API on port 7990.
- `/api/wms` proxies to WMS API on port 8000.
- `/api/pms` proxies to PMS API on port 8005.
- `/api/oms` proxies to OMS API on port 8010.
- `/api/procurement` proxies to Procurement API on port 8015.
- `/api/logistics` proxies to Logistics API on port 8020.
- Unknown `/api/*` routes return a Gateway 404.

## Build contract

| App | Build env |
|---|---|
| WMS | `VITE_APP_BASE_PATH=/wms/ VITE_API_BASE_URL=/api/wms pnpm build` |
| PMS | `VITE_APP_BASE_PATH=/pms/ VITE_API_BASE_URL=/api/pms pnpm build` |
| OMS | `VITE_APP_BASE_PATH=/oms/ VITE_OMS_API_BASE_URL=/api/oms pnpm build` |
| Procurement | `VITE_APP_BASE_PATH=/procurement/ VITE_API_BASE_URL=/api/procurement pnpm build` |
| Logistics | `VITE_APP_BASE_PATH=/logistics/ VITE_API_BASE_URL=/api/logistics pnpm build` |

Use this shortcut from `erp-gateway`:

    make apps-build

## Smoke contract

Minimal Gateway smoke:

    make smoke

Full local entry smoke:

    make full-smoke
