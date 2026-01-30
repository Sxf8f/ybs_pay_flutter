# Backend Issue: Missing `upi_url` in Add Money API Response

## Problem

The "Pay with UPI App" button is not functional because the backend is **not including the `upi_url` field** in the Add Money API response.

## Current API Response

```json
{
  "success": true,
  "message": "Payment gateway order created successfully. Redirect to payment URL.",
  "transaction_id": "f6ea00b409",
  "live_id": 147775024,
  "amount": "1.00",
  "payment_url": "https://qrstuff.me/gateway/pay/75a85bf2e5a3cd53d5fcb9be569559a9",
  "status": "PENDING",
  "redirect": true,
  "gateway_name": "UPIGATEWAY",
  "operator": "upi_collect"
}
```

**Missing field:** `upi_url`

## Expected API Response

```json
{
  "success": true,
  "message": "Payment gateway order created successfully. Redirect to payment URL.",
  "transaction_id": "f6ea00b409",
  "live_id": 147775024,
  "amount": "1.00",
  "payment_url": "https://qrstuff.me/gateway/pay/75a85bf2e5a3cd53d5fcb9be569559a9",
  "upi_url": "upi://pay?pa=merchant@upi&pn=YBS%20Pay&am=1.00&cu=INR&tn=Wallet%20Recharge%20-%20f6ea00b409",
  "status": "PENDING",
  "redirect": true,
  "gateway_name": "UPIGATEWAY",
  "operator": "upi_collect"
}
```

## Required Field

- **Field name:** `upi_url`
- **Type:** `string` (nullable)
- **Format:** UPI payment URL starting with `upi://pay?`
- **Example:** `upi://pay?pa=merchant@upi&pn=YBS%20Pay&am=1.00&cu=INR&tn=Wallet%20Recharge%20-%20TXN_ID`

## UPI URL Format

The `upi_url` should follow this format:
```
upi://pay?pa=<MERCHANT_UPI_ID>&pn=<MERCHANT_NAME>&am=<AMOUNT>&cu=INR&tn=<TRANSACTION_NOTE>
```

### Parameters:
- `pa`: Merchant UPI ID (e.g., `merchant@paytm`, `merchant@upi`)
- `pn`: Merchant display name (URL-encoded, e.g., `YBS%20Pay`)
- `am`: Transaction amount (e.g., `1.00`)
- `cu`: Currency code (always `INR`)
- `tn`: Transaction note/description (URL-encoded, e.g., `Wallet%20Recharge%20-%20TXN_ID`)

## When to Include `upi_url`

The `upi_url` should be included in the response when:
- `operator` is `"upi_collect"` OR
- `operator` is `"upi_intent"` OR
- `operator` contains `"upi"` (case-insensitive)

## Backend Configuration

According to previous documentation, the backend should have:
1. `MERCHANT_UPI_ID` configured in Django settings
2. `MERCHANT_NAME` configured in Django settings
3. UPI URL generation function implemented in `core/android_views.py`

## Current Status

- ✅ Flutter app is ready to receive and use `upi_url`
- ✅ Button is displayed (but disabled when `upi_url` is missing)
- ❌ Backend is not sending `upi_url` in the response

## Action Required

1. **Verify backend configuration:**
   - Check if `MERCHANT_UPI_ID` is set in `settings.py`
   - Check if `MERCHANT_NAME` is set in `settings.py`
   - Verify UPI URL generation code is active

2. **Check backend logs:**
   - Look for messages like "UPI operator detected - Generating UPI URL..."
   - Verify merchant UPI ID is found
   - Check if UPI URL is being generated

3. **Test the API:**
   - Make a request with `operator: "upi_collect"`
   - Verify the response includes `upi_url` field
   - Ensure the `upi_url` is properly formatted

## Flutter App Behavior

- **When `upi_url` is provided:** Button is enabled and opens UPI app chooser
- **When `upi_url` is missing:** Button is disabled (grayed out) and shows a warning message

## Test Request

```bash
POST /api/android/wallet/add-money/
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": "1.00",
  "operator": "upi_collect"
}
```

## Expected Response (with upi_url)

```json
{
  "success": true,
  "transaction_id": "...",
  "amount": "1.00",
  "payment_url": "https://...",
  "upi_url": "upi://pay?pa=merchant@upi&pn=YBS%20Pay&am=1.00&cu=INR&tn=...",
  "operator": "upi_collect",
  ...
}
```

---

**Last Updated:** December 26, 2025
**Status:** Waiting for backend fix

