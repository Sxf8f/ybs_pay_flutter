# Backend API Update Requirements for UPI Intent Links

## 📋 Quick Summary

### **Which API Needs Update?**

**ONLY ONE API:** `POST /api/android/wallet/add-money/`

### **What Needs to be Changed?**

**Add ONE new field** to the response: `upi_intent` (object)

### **What's Inside `upi_intent`?**

```json
{
  "bhim_link": "upi://pay?...",
  "phonepe_link": "phonepe://pay?...",
  "paytm_link": "paytmmp://pay?...",
  "gpay_link": "tez://upi/pay?..."
}
```

### **Where Does This Data Come From?**

From the **Payment Gateway (PG) response** → `pg_response['data']['upi_intent']`

### **Quick Action Items:**

1. ✅ Extract `upi_intent` from PG response
2. ✅ Add `upi_intent` object to API response
3. ✅ Keep existing `upi_url` field (for backward compatibility)
4. ✅ Handle null cases (if PG doesn't provide `upi_intent`)

---

## Current Situation

**Current API Response** (`POST /api/android/wallet/add-money/`):
```json
{
  "success": true,
  "message": "Redirecting to payment gateway...",
  "payment_url": "https://qrstuff.me/gateway/pay/...",
  "transaction_id": "90d8137ba6",
  "live_id": 149564667,
  "amount": 10.0,
  "charge": 1.5,
  "net_amount": 8.5,
  "charge_type": "Fixed",
  "gateway_name": "UPIGATEWAY",
  "redirect": true,
  "upi_url": "upi://pay?pa=paytmqr14t9t4ysbp%40paytm&pn=Lalu%20V%20S&am=10.00&cu=INR&tn=Wallet%20Recharge%20-%2090d8137ba6"
}
```

**Payment Gateway (PG) Response** (what the backend receives):
```json
{
  "status": true,
  "msg": "Order Created",
  "data": {
    "order_id": 149564667,
    "payment_url": "https://qrstuff.me/gateway/pay/...",
    "upi_id_hash": "...",
    "upi_intent": {
      "bhim_link": "upi://pay?pa=paytmqr14t9t4ysbp@paytm&pn=VSM%20POWERSYSTEM&am=10&tn=20261772133999&tr=20261772133999",
      "phonepe_link": "phonepe://pay?pa=paytmqr14t9t4ysbp@paytm&pn=VSM%20POWERSYSTEM&am=10&tn=20261772133999&tr=20261772133999",
      "paytm_link": "paytmmp://pay?pa=paytmqr14t9t4ysbp@paytm&pn=VSM%20POWERSYSTEM&am=10&tn=20261772133999&tr=20261772133999",
      "gpay_link": "tez://upi/pay?pa=paytmqr14t9t4ysbp@paytm&pn=VSM%20POWERSYSTEM&am=10&tn=20261772133999&tr=20261772133999"
    }
  }
}
```

## Problem

The backend is **NOT** extracting and passing the `upi_intent` object from the PG response to the Android API response. This means:
- The app cannot use specific UPI app links (which are more reliable)
- The app has to use a generic `upi_url` and try to open apps manually
- This causes issues with Google Pay and other apps not being detected properly

## 🔧 Required Backend Changes

### **API Endpoint to Update:**

**`POST /api/android/wallet/add-money/`**

This is the **ONLY** API endpoint that needs to be updated.

---

### **Step-by-Step Update Instructions:**

#### **Step 1: Locate the Endpoint Handler**

Find your backend code that handles the `POST /api/android/wallet/add-money/` endpoint. This is typically:
- Django: A view function or class-based view
- Flask: A route handler
- Node.js/Express: A route handler
- Other frameworks: The corresponding handler function

#### **Step 2: Extract `upi_intent` from PG Response**

In the code where you receive the Payment Gateway (PG) response, extract the `upi_intent` object:

```python
# Example Python/Django code
# After calling PG API and receiving pg_response

# Extract upi_intent from PG response
upi_intent = None
if pg_response and pg_response.get('data'):
    pg_data = pg_response.get('data', {})
    if pg_data.get('upi_intent'):
        upi_intent = pg_data['upi_intent']
        print(f"✅ Extracted upi_intent: {upi_intent}")  # Debug log
    else:
        print("⚠️ upi_intent not found in PG response")
else:
    print("⚠️ PG response structure unexpected")
```

#### **Step 3: Add `upi_intent` to API Response**

Update your response dictionary/JSON to include the `upi_intent` object:

```python
# In your add-money endpoint handler
# BEFORE (Current Response):
response_data = {
    "success": True,
    "message": "Redirecting to payment gateway...",
    "payment_url": pg_response['data']['payment_url'],
    "transaction_id": transaction_id,
    "live_id": order_id,
    "amount": amount,
    "charge": charge,
    "net_amount": net_amount,
    "charge_type": charge_type,
    "gateway_name": gateway_name,
    "redirect": True,
    "upi_url": upi_url,  # Existing field - keep this
}

# AFTER (Updated Response - ADD upi_intent):
response_data = {
    "success": True,
    "message": "Redirecting to payment gateway...",
    "payment_url": pg_response['data']['payment_url'],
    "transaction_id": transaction_id,
    "live_id": order_id,
    "amount": amount,
    "charge": charge,
    "net_amount": net_amount,
    "charge_type": charge_type,
    "gateway_name": gateway_name,
    "redirect": True,
    "upi_url": upi_url,  # Keep existing generic UPI URL for backward compatibility
    
    # ⬇️ ADD THIS NEW FIELD ⬇️
    "upi_intent": {
        "bhim_link": upi_intent.get('bhim_link') if upi_intent else None,
        "phonepe_link": upi_intent.get('phonepe_link') if upi_intent else None,
        "paytm_link": upi_intent.get('paytm_link') if upi_intent else None,
        "gpay_link": upi_intent.get('gpay_link') if upi_intent else None,
    } if upi_intent else None,  # Can be null if PG doesn't provide it
}
```

#### **Step 4: Handle Null Cases**

Make sure to handle cases where `upi_intent` might be null or missing:

```python
# Safe extraction with fallback
if upi_intent:
    upi_intent_data = {
        "bhim_link": upi_intent.get('bhim_link'),
        "phonepe_link": upi_intent.get('phonepe_link'),
        "paytm_link": upi_intent.get('paytm_link'),
        "gpay_link": upi_intent.get('gpay_link'),
    }
else:
    upi_intent_data = None  # or {} for empty object

response_data["upi_intent"] = upi_intent_data
```

#### **Step 5: Complete Example (Django/Python)**

```python
# Example Django view
from django.http import JsonResponse
import requests

def add_money(request):
    # ... your existing code to get amount, operator, etc.
    
    # Call Payment Gateway API
    pg_response = requests.post(pg_api_url, data=pg_request_data).json()
    
    # Extract upi_intent from PG response
    upi_intent = None
    if pg_response.get('data') and pg_response['data'].get('upi_intent'):
        upi_intent = pg_response['data']['upi_intent']
    
    # Build response
    response_data = {
        "success": True,
        "message": "Redirecting to payment gateway...",
        "payment_url": pg_response['data']['payment_url'],
        "transaction_id": transaction_id,
        "live_id": pg_response['data']['order_id'],
        "amount": float(amount),
        "charge": charge_amount,
        "net_amount": net_amount,
        "charge_type": "Fixed",
        "gateway_name": "UPIGATEWAY",
        "redirect": True,
        "upi_url": upi_url,  # Existing field
        
        # NEW: Add upi_intent
        "upi_intent": {
            "bhim_link": upi_intent.get('bhim_link') if upi_intent else None,
            "phonepe_link": upi_intent.get('phonepe_link') if upi_intent else None,
            "paytm_link": upi_intent.get('paytm_link') if upi_intent else None,
            "gpay_link": upi_intent.get('gpay_link') if upi_intent else None,
        } if upi_intent else None,
    }
    
    return JsonResponse(response_data)
```

### 3. Expected API Response Format

After the update, the API should return:

```json
{
  "success": true,
  "message": "Redirecting to payment gateway...",
  "payment_url": "https://qrstuff.me/gateway/pay/...",
  "transaction_id": "90d8137ba6",
  "live_id": 149564667,
  "amount": 10.0,
  "charge": 1.5,
  "net_amount": 8.5,
  "charge_type": "Fixed",
  "gateway_name": "UPIGATEWAY",
  "redirect": true,
  "upi_url": "upi://pay?pa=...",
  "upi_intent": {
    "bhim_link": "upi://pay?pa=...",
    "phonepe_link": "phonepe://pay?pa=...",
    "paytm_link": "paytmmp://pay?pa=...",
    "gpay_link": "tez://upi/pay?pa=..."
  }
}
```

## Benefits

1. **More Reliable**: Specific app links (`phonepe://`, `paytmmp://`, `tez://`) are more reliable than generic `upi://` links
2. **Better User Experience**: Apps open directly without needing chooser dialogs
3. **Google Pay Support**: The `gpay_link` (using `tez://` scheme) works better for Google Pay
4. **Backward Compatible**: The app still falls back to generic `upi_url` if `upi_intent` is not available

## ✅ Testing Checklist

After implementing the backend changes:

1. **Make a test payment request** to `POST /api/android/wallet/add-money/`
2. **Check the API response** includes `upi_intent` object
3. **Verify all four links** are present:
   - `bhim_link` (should start with `upi://`)
   - `phonepe_link` (should start with `phonepe://`)
   - `paytm_link` (should start with `paytmmp://`)
   - `gpay_link` (should start with `tez://`)
4. **Test opening each UPI app** from the payment screen in the Android app
5. **Verify backward compatibility**: If `upi_intent` is null, the app should still work with `upi_url`

## 📝 Summary of Changes

| Item | Details |
|------|---------|
| **API Endpoint** | `POST /api/android/wallet/add-money/` |
| **Change Type** | Add new field to response |
| **New Field** | `upi_intent` (object) |
| **Fields Inside `upi_intent`** | `bhim_link`, `phonepe_link`, `paytm_link`, `gpay_link` |
| **Backward Compatible** | ✅ Yes - `upi_url` still required |
| **Required** | ✅ Yes - Frontend expects this field |
| **Can be null** | ✅ Yes - If PG doesn't provide it, can be `null` |

## Frontend Status

✅ **Frontend is already updated** to:
- Parse `upi_intent` from API response
- Use specific app links when available
- Fall back to generic `upi_url` if specific links are not available
- Support all four UPI apps (BHIM, PhonePe, Paytm, Google Pay)

The frontend will automatically start using the specific links once the backend includes them in the response.

