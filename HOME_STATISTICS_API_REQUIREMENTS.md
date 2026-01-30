# Home Screen Statistics API Requirements

## Overview
The home screen displays 4 statistics boxes showing transaction summaries:
1. **Success** - Total amount of successful transactions
2. **Commission** - Total commission earned
3. **Pending** - Total amount of pending transactions
4. **Failed** - Total amount of failed transactions

Currently, all values are hardcoded as `₹ 0.00` and need to be replaced with real API data.

---

## Required API

### Endpoint
```
GET /api/android/dashboard/statistics/
```

### Authentication
**Required:** Bearer Token (JWT)

### Headers
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Query Parameters (Optional)
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start_date` | string (YYYY-MM-DD) | No | Start date for filtering (default: current month start) |
| `end_date` | string (YYYY-MM-DD) | No | End date for filtering (default: today) |
| `period` | string | No | Quick filter: `today`, `week`, `month`, `year`, `all` (default: `month`) |

### Response (Success - 200 OK)
```json
{
  "success": true,
  "statistics": {
    "success": {
      "amount": "12500.50",
      "count": 45,
      "formatted": "₹12,500.50"
    },
    "commission": {
      "amount": "125.00",
      "count": 45,
      "formatted": "₹125.00"
    },
    "pending": {
      "amount": "2500.00",
      "count": 8,
      "formatted": "₹2,500.00"
    },
    "failed": {
      "amount": "500.00",
      "count": 3,
      "formatted": "₹500.00"
    }
  },
  "period": {
    "start_date": "2025-12-01",
    "end_date": "2025-12-17",
    "label": "This Month"
  },
  "message": "Statistics retrieved successfully"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Indicates if the request was successful |
| `statistics` | object | Statistics for each status |
| `statistics.success` | object | Success transaction statistics |
| `statistics.success.amount` | string (decimal) | Total amount of successful transactions |
| `statistics.success.count` | integer | Number of successful transactions |
| `statistics.success.formatted` | string | Formatted amount with currency symbol |
| `statistics.commission` | object | Commission statistics |
| `statistics.commission.amount` | string (decimal) | Total commission earned |
| `statistics.commission.count` | integer | Number of transactions with commission |
| `statistics.commission.formatted` | string | Formatted commission amount |
| `statistics.pending` | object | Pending transaction statistics |
| `statistics.pending.amount` | string (decimal) | Total amount of pending transactions |
| `statistics.pending.count` | integer | Number of pending transactions |
| `statistics.pending.formatted` | string | Formatted pending amount |
| `statistics.failed` | object | Failed transaction statistics |
| `statistics.failed.amount` | string (decimal) | Total amount of failed transactions |
| `statistics.failed.count` | integer | Number of failed transactions |
| `statistics.failed.formatted` | string | Formatted failed amount |
| `period` | object | Period information |
| `period.start_date` | string (YYYY-MM-DD) | Start date of the period |
| `period.end_date` | string (YYYY-MM-DD) | End date of the period |
| `period.label` | string | Human-readable period label |
| `message` | string | Success message |

### Error Responses

#### 401 Unauthorized
```json
{
  "success": false,
  "error": "Authentication required"
}
```

#### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Failed to fetch statistics: <error_message>"
}
```

---

## Implementation Details

### What Should Be Included

1. **Success Transactions:**
   - All transactions with status = "SUCCESS" or "COMPLETED"
   - Sum of transaction amounts
   - Count of transactions

2. **Commission:**
   - Total commission earned from all successful transactions
   - This should be the sum of commission/charges from successful transactions
   - Count of transactions that earned commission

3. **Pending Transactions:**
   - All transactions with status = "PENDING" or "PROCESSING"
   - Sum of transaction amounts
   - Count of transactions

4. **Failed Transactions:**
   - All transactions with status = "FAILED" or "CANCELLED"
   - Sum of transaction amounts
   - Count of transactions

### Date Filtering

- If no dates provided, default to current month (start of month to today)
- If `period` parameter is provided:
  - `today`: Today's transactions only
  - `week`: Last 7 days
  - `month`: Current month
  - `year`: Current year
  - `all`: All time transactions

### Database Queries (Suggested)

The API should query transaction tables (likely `RechargeTransaction`, `FundDebitCredit`, or similar) and aggregate by status:

```sql
-- Success
SELECT SUM(amount) as total, COUNT(*) as count 
FROM transactions 
WHERE user_id = ? AND status = 'SUCCESS' 
AND created_at BETWEEN ? AND ?

-- Commission
SELECT SUM(commission) as total, COUNT(*) as count 
FROM transactions 
WHERE user_id = ? AND status = 'SUCCESS' AND commission > 0
AND created_at BETWEEN ? AND ?

-- Pending
SELECT SUM(amount) as total, COUNT(*) as count 
FROM transactions 
WHERE user_id = ? AND status IN ('PENDING', 'PROCESSING')
AND created_at BETWEEN ? AND ?

-- Failed
SELECT SUM(amount) as total, COUNT(*) as count 
FROM transactions 
WHERE user_id = ? AND status IN ('FAILED', 'CANCELLED')
AND created_at BETWEEN ? AND ?
```

---

## cURL Example

```bash
curl -X GET "https://api.example.com/api/android/dashboard/statistics/?period=month" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

---

## Notes

- All amounts should be returned as strings with 2 decimal places
- Formatted amounts should include the currency symbol (₹)
- The API should use the authenticated user's ID to filter transactions
- Consider caching this data for better performance (refresh every 30 seconds or on pull-to-refresh)
- The statistics should reflect the user's own transactions only (not admin/aggregate data)

---

## Testing Checklist

- [ ] Returns correct success amount and count
- [ ] Returns correct commission amount and count
- [ ] Returns correct pending amount and count
- [ ] Returns correct failed amount and count
- [ ] Date filtering works correctly
- [ ] Period parameter works correctly
- [ ] Returns 401 for invalid/expired token
- [ ] Handles users with no transactions (returns 0.00)
- [ ] Amounts are formatted correctly with currency symbol

---

**Last Updated:** December 17, 2025

