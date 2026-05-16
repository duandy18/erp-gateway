# ERP Gateway URL Contract

## Current routes

| App | Web Path | Web Target | API Path | API Target |
|---|---|---|---|---|
| ERP | / | erp-web:5170 | /api/erp | erp-api:7990 |
| WMS | /wms | wms-web:5173 | /api/wms | wms-api:8000 |
| PMS | /pms | pms-web:5174 | /api/pms | pms-api:8005 |
| OMS | /oms | oms-web:5175 | /api/oms | oms-api:8010 |
| Procurement | /procurement | procurement-web:5176 | /api/procurement | procurement-api:8015 |
| Logistics | /logistics | logistics-web:5177 | /api/logistics | logistics-api:8020 |

## Contract

- ERP Gateway is the local unified entry.
- My Apps should open `web_path`, not `local_web_url`.
- `local_web_url` and `local_api_url` are kept for local debugging and configuration display.
- Backend API routes strip the `/api/<app>` prefix before proxying to each backend.
- Web routes preserve app path prefixes such as `/wms` and `/pms`.
