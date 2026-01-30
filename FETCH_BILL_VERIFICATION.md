# Fetch Bill Button - Verification & Testing Guide

## ✅ Backend Fix Confirmed

The backend team has fixed the API issue. The API now:
- ✅ Checks `config.get('features', [])` first (primary check)
- ✅ Falls back to database query if not found in config
- ✅ Sets `fetch_bill_endpoint` if the feature exists
- ✅ Sets `fetch_bill_button` based on whether the endpoint is set

## ✅ Flutter Code Verification

The Flutter code is **already correctly configured** to handle the backend response:

### Field Mapping (Snake Case → Camel Case)

**File**: `lib/core/models/authModels/userModel.dart` (line 127-131)

```dart
fetchBillButton: json['fetch_bill_button'] ?? false,  // ✅ Correct mapping
fetchBillEndpoint: json['fetch_bill_endpoint'] ?? '',  // ✅ Correct mapping
```

✅ **Status**: Correctly maps `fetch_bill_button` → `fetchBillButton`  
✅ **Status**: Correctly maps `fetch_bill_endpoint` → `fetchBillEndpoint`

### Button Visibility Logic

**File**: `lib/View/testRechargePage.dart` (line 4867-4879)

```dart
final showFetchBillButton =
    currentLayout.fetchBillButton &&                    // ✅ Check flag
    currentLayout.fetchBillEndpoint.isNotEmpty &&      // ✅ Check endpoint
    billFetchMode != "manual_only";                     // ✅ Check mode
```

✅ **Status**: All three conditions are correctly checked

## Expected Behavior

### When Fetch Bill is Enabled

**API Response**:
```json
{
  "fetch_bill_button": true,
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/",
  "bill_fetch_mode": "both"
}
```

**Flutter Behavior**:
- ✅ `fetchBillButton` = `true`
- ✅ `fetchBillEndpoint` = `"/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/"` (non-empty)
- ✅ `billFetchMode` = `"both"` (not "manual_only")
- ✅ **Result**: Fetch Bill button **SHOULD BE VISIBLE** ✅

### When Fetch Bill is Disabled

**API Response**:
```json
{
  "fetch_bill_button": false,
  "fetch_bill_endpoint": "",
  "bill_fetch_mode": "both"
}
```

**Flutter Behavior**:
- ❌ `fetchBillButton` = `false`
- ❌ `fetchBillEndpoint` = `""` (empty)
- ✅ **Result**: Fetch Bill button **SHOULD NOT BE VISIBLE** ✅

### When `bill_fetch_mode` is "manual_only"

**API Response**:
```json
{
  "fetch_bill_button": true,
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/",
  "bill_fetch_mode": "manual_only"
}
```

**Flutter Behavior**:
- ✅ `fetchBillButton` = `true`
- ✅ `fetchBillEndpoint` = `"/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/"` (non-empty)
- ❌ `billFetchMode` = `"manual_only"` (hides button)
- ✅ **Result**: Fetch Bill button **SHOULD NOT BE VISIBLE** ✅

## Testing Steps

### 1. Test with Operator that has Fetch Bill Enabled

1. **Select an operator** that has fetch bill enabled (e.g., operator ID 10)
2. **Check Flutter logs** for:
   ```
   🔘 [BUILD_BUTTONS] Fetch Bill Button Check:
      🔘 fetchBillButton: true
      🔘 fetchBillEndpoint: "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/" (empty: false)
      🔘 billFetchMode: "both"
      ✅ Will show fetchBillButton: true
   ```
3. **Verify UI**: Fetch Bill button should be visible ✅

### 2. Test Fetch Bill Functionality

1. **Enter mobile/consumer number** in the form
2. **Click "Fetch Bill" button**
3. **Check API call**:
   ```
   🔍 [FETCH_BILL] URL: http://trvpay.com/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/
   ```
4. **Verify response**: Should return bill details with `success: true`
5. **Verify amount prefilling**: Amount field should be prefilled with bill amount

### 3. Test with Operator without Fetch Bill

1. **Select an operator** that doesn't have fetch bill enabled
2. **Check Flutter logs** for:
   ```
   🔘 [BUILD_BUTTONS] Fetch Bill Button Check:
      🔘 fetchBillButton: false
      🔘 fetchBillEndpoint: "" (empty: true)
      ✅ Will show fetchBillButton: false
   ```
3. **Verify UI**: Fetch Bill button should NOT be visible ✅

### 4. Test Manual Only Mode

1. **Select an operator** with `bill_fetch_mode: "manual_only"`
2. **Check Flutter logs** for:
   ```
   🔘 [BUILD_BUTTONS] Fetch Bill Button Check:
      🔘 fetchBillButton: true
      🔘 fetchBillEndpoint: "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/" (empty: false)
      🔘 billFetchMode: "manual_only"
      ✅ Will show fetchBillButton: false
   ```
3. **Verify UI**: Fetch Bill button should NOT be visible ✅

## Debug Logging

The Flutter app includes comprehensive debug logging. When testing, check for:

### Operator Form Config API Response

```
🔍 OPERATOR FORM CONFIG REPOSITORY: Fetching config for operator 10...
   📋 Raw API Bill Fetch Settings:
   🔘 Raw API Fetch Bill Button Settings:
      - fetch_bill_button: true
      - fetch_bill_endpoint: "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/"
   📋 Full API Response Keys: [...]
   📄 Full API Response: {...}
```

### Button Visibility Check

```
🔘 [BUILD_BUTTONS] Fetch Bill Button Check:
   🔘 fetchBillButton: true
   🔘 fetchBillEndpoint: "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/" (empty: false)
   🔘 billFetchMode: "both"
   ✅ Will show fetchBillButton: true
```

## Troubleshooting

### Issue: Button Still Not Showing

**Check 1**: Verify API Response
- Test the API endpoint: `GET /api/android/operator-form-config/?operator_id=10`
- Verify `fetch_bill_button: true` and `fetch_bill_endpoint` is non-empty

**Check 2**: Verify Flutter Logs
- Check if `fetchBillButton` is `true` in logs
- Check if `fetchBillEndpoint` is non-empty in logs
- Check if `billFetchMode` is not `"manual_only"`

**Check 3**: Verify Operator Configuration
- Confirm fetch bill is enabled for the operator in backend
- Check `OperatorFormFeature` exists with `feature_type="fetch_bill"` and `is_enabled=True`

### Issue: Button Shows But Doesn't Work

**Check 1**: Verify Endpoint URL
- Check if `fetchBillEndpoint` contains the correct URL pattern
- Verify mobile/operator are being substituted correctly

**Check 2**: Verify API Call
- Check Flutter logs for `🔍 [FETCH_BILL] URL: ...`
- Verify the URL is correctly constructed
- Check API response status code

## Summary

✅ **Backend**: Fixed - API now returns correct values  
✅ **Flutter Mapping**: Correct - Snake case → Camel case  
✅ **Button Logic**: Correct - All conditions checked  
✅ **Status**: Ready for testing  

**Next Step**: Test with an operator that has fetch bill enabled and verify the button appears and works correctly.

---

**Last Updated**: January 2026  
**Status**: ✅ Ready for Testing
