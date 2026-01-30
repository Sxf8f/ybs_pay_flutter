# Report Endpoints - Complete List

This document lists all 8 report types and their API endpoints used in the Reports page.

## Base URL
All endpoints use the base path: `{apiBase}/api/android/reports/`

---

## 1. Recharge Report
**Endpoint:** `GET/POST /api/android/reports/recharge/`

**Query Parameters:**
- `operator_type` (int, optional)
- `operator` (int, optional)
- `status` (int, optional)
- `criteria` (int, optional)
- `search` (string, optional)
- `start_date` (string, optional) - Format: YYYY-MM-DD
- `end_date` (string, optional) - Format: YYYY-MM-DD
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/recharge/?start_date=2025-01-01&end_date=2025-01-31&limit=50
```

---

## 2. Ledger Report
**Endpoint:** `GET/POST /api/android/reports/ledger/`

**Query Parameters:**
- `start_date` (string, optional) - Format: YYYY-MM-DD
- `end_date` (string, optional) - Format: YYYY-MM-DD
- `transaction_id` (string, optional)
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/ledger/?start_date=2025-01-01&end_date=2025-01-31&transaction_id=TXN123&limit=50
```

---

## 3. Fund Order Report
**Endpoint:** `GET/POST /api/android/reports/fund-order/`

**Query Parameters:**
- `status` (int, optional)
- `transfer_mode` (int, optional)
- `criteria` (int, optional)
- `search` (string, optional)
- `from_date` (string, optional) - Format: YYYY-MM-DD
- `to_date` (string, optional) - Format: YYYY-MM-DD
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/fund-order/?from_date=2025-01-01&to_date=2025-01-31&limit=50
```

---

## 4. Complaint Report
**Endpoint:** `GET/POST /api/android/reports/complaint/`

**Query Parameters:**
- `refund_status` (string, optional)
- `operator` (int, optional)
- `status` (int, optional)
- `api` (int, optional)
- `search` (string, optional)
- `start_date` (string, optional) - Format: YYYY-MM-DD
- `end_date` (string, optional) - Format: YYYY-MM-DD
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/complaint/?start_date=2025-01-01&end_date=2025-01-31&limit=50
```

---

## 5. Fund Debit Credit Report
**Endpoint:** `GET/POST /api/android/reports/fund-debit-credit/`

**Query Parameters:**
- `wallet_type` (int, optional)
- `is_self` (bool, optional)
- `received_by` (int, optional)
- `type` (string, optional) - "credit" or "debit"
- `mobile` (string, optional)
- `start_date` (string, optional) - Format: YYYY-MM-DD
- `end_date` (string, optional) - Format: YYYY-MM-DD
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/fund-debit-credit/?start_date=2025-01-01&end_date=2025-01-31&type=credit&limit=50
```

---

## 6. User Daybook Report
**Endpoint:** `GET/POST /api/android/reports/user-daybook/`

**Query Parameters:**
- `phone_number` (string, optional)
- `start_date` (string, optional) - Format: YYYY-MM-DD
- `end_date` (string, optional) - Format: YYYY-MM-DD
- `operator` (dynamic, optional)
- `is_dmt` (bool, optional)
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/user-daybook/?start_date=2025-01-01&end_date=2025-01-31&limit=50
```

---

## 7. Commission Slab Report
**Endpoint:** `GET/POST /api/android/reports/commission-slab/`

**Query Parameters:**
- `commissionId` (string, optional)
- `operator_id` (int, optional)
- `operator_type` (string, optional)
- `search` (string, optional)
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/commission-slab/?limit=50&search=airtel
```

---

## 8. W2R Report (Wrong to Right)
**Endpoint:** `GET/POST /api/android/reports/w2r/`

**Query Parameters:**
- `status` (string, optional)
- `transaction_id` (string, optional)
- `start_date` (string, optional) - Format: YYYY-MM-DD
- `end_date` (string, optional) - Format: YYYY-MM-DD
- `limit` (int, optional) - Default: 50

**Example:**
```
GET /api/android/reports/w2r/?start_date=2025-01-01&end_date=2025-01-31&status=ACCEPTED&limit=50
```

---

## Authentication
All endpoints require authentication via Bearer token in the Authorization header:
```
Authorization: Bearer {access_token}
```

## Request Methods
- **Default:** GET (parameters sent as query string)
- **Alternative:** POST (parameters sent in request body as JSON)
- Controlled by `usePost` parameter in the repository methods

## Response Format
All endpoints return JSON responses with the following structure:
```json
{
  "success": true,
  "data": [...],
  "count": 100,
  "returned_count": 50,
  "filters": {...},
  "applied_filters": {...}
}
```

---

## Summary Table

| # | Report Type | Endpoint | Key Parameters |
|---|-------------|----------|----------------|
| 1 | Recharge | `/recharge/` | start_date, end_date, search, operator, status |
| 2 | Ledger | `/ledger/` | start_date, end_date, transaction_id |
| 3 | Fund Order | `/fund-order/` | from_date, to_date, search, status |
| 4 | Complaint | `/complaint/` | start_date, end_date, search, refund_status |
| 5 | Fund Debit Credit | `/fund-debit-credit/` | start_date, end_date, type, mobile |
| 6 | User Daybook | `/user-daybook/` | start_date, end_date, phone_number, operator |
| 7 | Commission Slab | `/commission-slab/` | search, operator_id, operator_type |
| 8 | W2R | `/w2r/` | start_date, end_date, transaction_id, status |

---

**Last Updated:** January 2025
**Base URL:** `https://trvpay.com/api/android/reports/`
