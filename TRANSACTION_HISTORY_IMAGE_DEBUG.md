# Transaction History - Image Loading Debug Guide

## Issue
**Error**: `Exception: Invalid image data`  
**URL**: `NetworkImage("http://192.168.1.7:8001/", scale: 1.0)`

The error occurs when `operator_image` from the API is empty or invalid, resulting in an incomplete URL.

---

## API Endpoint

### Transaction History API

**Endpoint**: `GET /api/recharge-report-android/`

**Full URL**: `{apiBase}api/recharge-report-android/`

**Example**: `http://192.168.1.7:8001/api/recharge-report-android/`

**Authentication**: Bearer Token (JWT)

**Query Parameters**:
- `operator_type` (optional): Filter by operator type ID
- `operator` (optional): Filter by operator ID
- `start_date` (optional): Start date (YYYY-MM-DD)
- `end_date` (optional): End date (YYYY-MM-DD)
- `search` (optional): Search query
- `limit` (default: 50): Number of results

**Headers**:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## API Response Structure

### Expected Response Format

```json
{
  "success": true,
  "transactions": [
    {
      "id": 1,
      "datetime": "2026-01-23 10:30:00",
      "status_name": "SUCCESS",
      "operator_name": "Airtel",
      "operator_image": "/media/operators/airtel.png",  // ✅ Should be non-empty
      "api_name": "API Name",
      "phone_number": "9876543210",
      "username": "user123",
      "transaction_id": "TXN123456",
      "account_no": "1234567890",
      "opening": 1000.00,
      "amount": 100.00,
      "debit": 100.00,
      "comm": 1.00,
      "closing": 900.00,
      "refund_status": "N/A",
      "liveid": "LIVE123",
      "request_mode": "API",
      "user": 1,
      "operator": 2,
      "status": 1,
      "api_id": 1
    }
  ],
  "total_count": 100,
  "filters": {...},
  "applied_filters": {...}
}
```

### Problem Field

**Field**: `operator_image`

**Expected**: Non-empty string with image path (e.g., `/media/operators/airtel.png`)

**Problem**: When `operator_image` is:
- Empty string `""`
- Just a slash `"/"`
- `null` or `"null"`

The resulting URL becomes: `http://192.168.1.7:8001/` (invalid)

---

## Debug Prints Added

### 1. API Call Debug (`transaction_history.dart`)

**Location**: `lib/View/TransactionHistory/transaction_history.dart` (line ~79)

**Prints**:
```
📊 [TRANSACTION_HISTORY] Fetching transactions...
   📡 API Endpoint: http://192.168.1.7:8001/api/recharge-report-android/?limit=50
   🔑 Query Parameters: {limit: 50}
   📊 Response Status: 200
   📏 Response Body Length: 12345 bytes
   ✅ JSON parsed successfully
   📋 Transactions count: 10
   🔍 First transaction operator_image: "/media/operators/airtel.png"
   🔍 First transaction operator_name: "Airtel"
   🔍 Full first transaction: {...}
   ✅ Loaded 10 transactions
```

### 2. Transaction Card Debug (`historyListView.dart`)

**Location**: `lib/View/TransactionHistory/widgets/historyListView.dart` (line ~38)

**Prints** (for each transaction card):
```
🖼️ [TRANSACTION_CARD] Building card for transaction:
   📝 Transaction ID: TXN123456
   📝 Operator Name: Airtel
   🖼️ Operator Image (raw): "/media/operators/airtel.png"
   🖼️ Operator Image (empty): false
   🖼️ Operator Image (is "/"): false
   🔗 Full Image URL: http://192.168.1.7:8001/media/operators/airtel.png
```

**On Tap**:
```
🔘 [TRANSACTION_CARD] Tapped transaction:
   🖼️ Operator Image: "/media/operators/airtel.png"
   🔗 Full URL: http://192.168.1.7:8001/media/operators/airtel.png
```

### 3. Image Load Error Debug

**Location**: `lib/View/TransactionHistory/widgets/historyListView.dart` (errorWidget)

**Prints** (when image fails to load):
```
❌ [TRANSACTION_HISTORY] Image load error:
   🔗 URL: http://192.168.1.7:8001/media/operators/airtel.png
   📝 Error: Exception: Invalid image data
   📝 Transaction ID: TXN123456
   📝 Operator: Airtel
```

---

## Fix Applied

### 1. Image Loading Fix

**Before**:
```dart
image: DecorationImage(
  image: NetworkImage(
    "${AssetsConst.apiBase}${transaction.operatorImage}",
  ),
  fit: BoxFit.contain,
),
```

**After**:
```dart
// Check if operatorImage is valid before loading
transaction.operatorImage.isNotEmpty &&
transaction.operatorImage != '/' &&
transaction.operatorImage != 'null'
  ? CachedNetworkImage(
      imageUrl: transaction.operatorImage.startsWith('http')
          ? transaction.operatorImage
          : "${AssetsConst.apiBase}${transaction.operatorImage.startsWith('/') ? transaction.operatorImage.substring(1) : transaction.operatorImage}",
      fit: BoxFit.contain,
      errorWidget: (context, url, error) {
        // Shows icon if image fails
        return Icon(Icons.phone_android, ...);
      },
    )
  : Icon(Icons.phone_android, ...)  // Shows icon if no image
```

### 2. URL Construction Fix

- Handles absolute URLs (starts with `http`)
- Handles relative URLs (starts with `/`)
- Handles paths without leading slash
- Validates empty/null values

---

## Points to Check

### 1. Backend API Response

**Check**: `/api/recharge-report-android/` response

**Verify**:
- ✅ `operator_image` field exists in transaction objects
- ✅ `operator_image` is not empty (`""`)
- ✅ `operator_image` is not just `"/"`
- ✅ `operator_image` is not `null` or `"null"`
- ✅ `operator_image` contains valid path (e.g., `/media/operators/airtel.png`)

**Example Valid Response**:
```json
{
  "operator_image": "/media/operators/airtel.png"  // ✅ Valid
}
```

**Example Invalid Responses**:
```json
{
  "operator_image": ""  // ❌ Empty
}
```
```json
{
  "operator_image": "/"  // ❌ Just slash
}
```
```json
{
  "operator_image": null  // ❌ Null
}
```

### 2. Database Check

**Check**: `operator_image` field in transaction/operator tables

**SQL Query** (example):
```sql
SELECT id, operator_name, operator_image 
FROM transactions 
WHERE operator_image IS NULL 
   OR operator_image = '' 
   OR operator_image = '/';
```

### 3. Operator Master Table

**Check**: Ensure operators have valid `operator_image` values

**SQL Query** (example):
```sql
SELECT OperatorID, OperatorName, icon 
FROM OperatorMaster 
WHERE icon IS NULL 
   OR icon = '' 
   OR icon = '/';
```

---

## Testing

### Test Case 1: Valid Operator Image

**API Response**:
```json
{
  "operator_image": "/media/operators/airtel.png"
}
```

**Expected**: Image loads successfully ✅

**Debug Output**:
```
🖼️ Operator Image (raw): "/media/operators/airtel.png"
🔗 Full Image URL: http://192.168.1.7:8001/media/operators/airtel.png
```

### Test Case 2: Empty Operator Image

**API Response**:
```json
{
  "operator_image": ""
}
```

**Expected**: Shows icon instead of image ✅

**Debug Output**:
```
🖼️ Operator Image (raw): ""
🖼️ Operator Image (empty): true
🔗 Full Image URL: N/A
```

### Test Case 3: Invalid URL

**API Response**:
```json
{
  "operator_image": "/media/operators/invalid.png"
}
```

**Expected**: Shows icon with error log ✅

**Debug Output**:
```
❌ [TRANSACTION_HISTORY] Image load error:
   🔗 URL: http://192.168.1.7:8001/media/operators/invalid.png
   📝 Error: Exception: Invalid image data
```

---

## Files Modified

1. **`lib/View/TransactionHistory/transaction_history.dart`**
   - Added debug prints for API call
   - Added debug prints for API response
   - Added debug prints for first transaction's operator_image

2. **`lib/View/TransactionHistory/widgets/historyListView.dart`**
   - Added `CachedNetworkImage` import
   - Replaced `NetworkImage` with `CachedNetworkImage`
   - Added validation for empty/null operator_image
   - Added error handling with debug prints
   - Added debug prints for each transaction card

---

## Summary

✅ **Fixed**: Image loading now handles empty/null operator_image  
✅ **Added**: Comprehensive debug prints for troubleshooting  
✅ **Improved**: Error handling with fallback icon  
✅ **API Endpoint**: `/api/recharge-report-android/`  

**Next Steps**:
1. Check backend API response for `operator_image` values
2. Verify operators have valid image paths in database
3. Review debug logs to identify transactions with invalid images

---

**Last Updated**: January 2026  
**Status**: ✅ Fixed with Debug Prints Added
