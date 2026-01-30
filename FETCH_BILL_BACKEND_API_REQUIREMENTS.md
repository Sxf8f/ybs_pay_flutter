# Fetch Bill Button - Backend API Requirements

## Issue
The fetch bill button is not displaying in the Flutter app even though it's configured for some operators.

## Current Status
From the logs, when operator ID 10 is selected:
- `fetchBillButton: false` ❌ (should be `true`)
- `fetchBillEndpoint: ""` ❌ (should be `/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/`)

## What Flutter App Expects

### API Endpoint
`GET /api/android/operator-form-config/?operator_id={OPERATOR_ID}`

### Required Fields in Response

The Flutter app expects the following fields in the API response:

```json
{
  "operator_id": 10,
  "operator_name": "Operator Name",
  "fetch_bill_button": true,  // ✅ REQUIRED: Must be true to show button
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/",  // ✅ REQUIRED: Must be non-empty
  "bill_fetch_mode": "both",  // ✅ REQUIRED: "both", "fetch_only", or "manual_only"
  "require_bill_fetch_first": false,  // Optional: Default false
  "amount_editable_after_fetch": true,  // Optional: Default true
  "fields": [...],
  "amount": {...},
  ...
}
```

### Field Mapping

| Flutter Field | API Field Name | Type | Required | Default |
|---------------|----------------|------|----------|---------|
| `fetchBillButton` | `fetch_bill_button` | Boolean | ✅ Yes | `false` |
| `fetchBillEndpoint` | `fetch_bill_endpoint` | String | ✅ Yes | `""` (empty) |
| `billFetchMode` | `bill_fetch_mode` | String | ✅ Yes | `"both"` |
| `requireBillFetchFirst` | `require_bill_fetch_first` | Boolean | No | `false` |
| `amountEditableAfterFetch` | `amount_editable_after_fetch` | Boolean | No | `true` |

## Button Display Logic

The fetch bill button will be shown when **ALL** of these conditions are met:

1. ✅ `fetch_bill_button === true`
2. ✅ `fetch_bill_endpoint` is non-empty (not `""`)
3. ✅ `bill_fetch_mode !== "manual_only"`

## Backend Configuration

According to the documentation, fetch bill is configured using:

- **Model**: `OperatorFormFeature`
- **Feature Type**: `fetch_bill`
- **Enabled**: `is_enabled = True`
- **Label**: Custom label (e.g., "Fetch Bill", "Get Bill Details")

## Questions for Backend Team

### 1. Is `fetch_bill_button` being set correctly?

**Check**: When `OperatorFormFeature` with `feature_type="fetch_bill"` and `is_enabled=True` exists for an operator, does the API return `fetch_bill_button: true`?

**Expected**: If fetch bill feature is enabled for operator ID 10, the API should return:
```json
{
  "fetch_bill_button": true,
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/"
}
```

### 2. Is `fetch_bill_endpoint` being populated?

**Check**: Does the API return the endpoint URL in `fetch_bill_endpoint` field?

**Expected**: The endpoint should be:
```
/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/
```

Or it can be constructed from the `OperatorFormFeature.function` field.

### 3. API Response Structure

**Question**: What is the exact structure of the API response for `/api/android/operator-form-config/?operator_id=10`?

**Please provide**:
- Full JSON response for an operator that has fetch bill enabled
- Or confirm if the fields are named differently (e.g., `fetchBillButton` instead of `fetch_bill_button`)

### 4. Feature Configuration

**Question**: How is fetch bill configured in the backend?

- Is it configured at the **operator level** using `OperatorFormFeature`?
- Or is it configured at the **operator type level**?
- Or both?

### 5. Endpoint Construction

**Question**: How should `fetch_bill_endpoint` be constructed?

- Is it a static value: `/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/`?
- Or is it stored in `OperatorFormFeature.function`?
- Or is it constructed from other fields?

## Testing

### Test Case 1: Operator with Fetch Bill Enabled

**Operator ID**: 10 (or any operator with fetch bill enabled)

**Expected API Response**:
```json
{
  "operator_id": 10,
  "operator_name": "Airtel Postpaid",
  "fetch_bill_button": true,
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/",
  "bill_fetch_mode": "both",
  "require_bill_fetch_first": false,
  "amount_editable_after_fetch": true,
  ...
}
```

**Expected Flutter Behavior**: ✅ Fetch Bill button should be visible

### Test Case 2: Operator without Fetch Bill

**Operator ID**: Any operator without fetch bill enabled

**Expected API Response**:
```json
{
  "operator_id": 1,
  "operator_name": "Airtel Prepaid",
  "fetch_bill_button": false,
  "fetch_bill_endpoint": "",
  ...
}
```

**Expected Flutter Behavior**: ❌ Fetch Bill button should NOT be visible

### Test Case 3: Manual Only Mode

**Operator ID**: Any operator with `bill_fetch_mode: "manual_only"`

**Expected API Response**:
```json
{
  "operator_id": 5,
  "fetch_bill_button": true,
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/",
  "bill_fetch_mode": "manual_only",
  ...
}
```

**Expected Flutter Behavior**: ❌ Fetch Bill button should NOT be visible (manual_only mode hides the button)

## Debug Logging

The Flutter app now includes detailed debug logging. When you test, check the logs for:

```
🔍 OPERATOR FORM CONFIG REPOSITORY: Fetching config for operator 10...
   📋 Raw API Bill Fetch Settings:
   🔘 Raw API Fetch Bill Button Settings:
      - fetch_bill_button: true/false
      - fetch_bill_endpoint: "..."
   📋 Full API Response Keys: [...]
   📄 Full API Response: {...}
```

This will help identify if:
- The fields are missing from the API response
- The fields have different names
- The values are incorrect

## Next Steps

1. **Backend Team**: Please verify the API response includes `fetch_bill_button` and `fetch_bill_endpoint` fields
2. **Backend Team**: Please confirm the field names match exactly (snake_case: `fetch_bill_button`, not camelCase)
3. **Backend Team**: Please provide a sample API response for an operator with fetch bill enabled
4. **Flutter Team**: Will test once backend confirms the API response structure

## Related Files

- **Flutter Model**: `lib/core/models/authModels/userModel.dart` (line 127-131)
- **Flutter Repository**: `lib/core/repository/operatorFormConfigRepository/operatorFormConfigRepo.dart`
- **Flutter UI Logic**: `lib/View/testRechargePage.dart` (line 4867-4886)

---

**Last Updated**: January 2026
**Status**: ⚠️ Waiting for backend API response verification
