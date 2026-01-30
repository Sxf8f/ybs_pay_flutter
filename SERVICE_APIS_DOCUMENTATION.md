# Unified Android Service APIs Documentation

## Overview
This document describes the **unified Android API system** that uses the **same operator-based configuration** as the web interface. All operator configurations (form fields, features, buttons, validation) are stored in the backend and automatically work for both **Web** and **Android** without any additional configuration.

**📖 For Complete Flow Documentation**: See `COMPLETE_ANDROID_API_FLOW.md`

---

## Key Principle
**One Configuration, Two Platforms**: All operator configurations are stored in:
- `OperatorFormField` model (for form fields)
- `OperatorFormFeature` model (for buttons/features)

These configurations are used by:
- ✅ **Web Interface** (`unified_recharge.html`)
- ✅ **Android App** (via these unified APIs)

---

## Complete API Flow Overview

**Complete Flow**: Services → Check Operator Type → Operators List → Operator Info → Form Config → Features → Payment

1. **Services List** → Get available services
2. **Check Operator Type API** → Determine if operator check is enabled
3. **Operators List** → Get operators for selected type
4. **Operator Info** → Auto-detect operator (if operator check enabled)
5. **Operator Form Config** → Get form fields and features for selected operator
6. **Feature API Data** → Get plans/offers/etc.
7. **Fetch Bill** → Get bill details (if applicable)
8. **Booking/Payment** → Process recharge

See `COMPLETE_ANDROID_API_FLOW.md` for detailed flow documentation.

---

## API Endpoints

### 1. Services List API (Homepage)
**Endpoint**: `GET /api/android/services/`

**Purpose**: Get list of services (operator types) to display on Android homepage

**Authentication**: Bearer Token (JWT)

**Location**: `lib/View/Home/widgets/servicesGrid.dart` (Currently hardcoded - needs implementation)

**Response**:
```json
{
  "success": true,
  "services": [
    {
      "id": 1,
      "name": "Prepaid",
      "operator_type_id": 1,
      "icon": "/media/operator_types/prepaid.png",
      "is_active": true,
      "order": 1
    },
    {
      "id": 2,
      "name": "Postpaid",
      "operator_type_id": 2,
      "icon": "/media/operator_types/postpaid.png",
      "is_active": true,
      "order": 2
    }
  ],
  "total_count": 4
}
```

**Status**: ❌ **NOT IMPLEMENTED** - Currently hardcoded in `servicesGrid.dart`

---

### 2. Check Operator Type API (On Service Selection)

**Endpoint**: `GET /api/android/check-operator-type-api/?operator_type_id={TYPE_ID}`

**Purpose**: Check if operator check API is enabled for this operator type. This determines whether to show operator check field first or operator selection first.

**Authentication**: Bearer Token (JWT)

**Response (Operator Check Enabled)**:
```json
{
  "has_active_operator_check_api": true,
  "operator_type_id": 1,
  "operator_type_name": "Prepaid",
  "operator_check_api_placeholder": "MOBILE",
  "field_config": {
    "field_name": "mobile",
    "field_label": "Mobile Number",
    "field_type": "tel",
    "placeholder": "Enter Mobile Number",
    "is_required": true,
    "min_length": 10,
    "max_length": 10,
    "validation_pattern": "[0-9]{10}",
    "help_text": "Enter 10 digit mobile number"
  }
}
```

**Response (Operator Check NOT Enabled)**:
```json
{
  "has_active_operator_check_api": false,
  "operator_type_id": 1,
  "operator_type_name": "Prepaid"
}
```

**Android Action**:
- **If `has_active_operator_check_api: true` AND `field_config` exists**:
  - Show `field_config` field **FIRST** (before operator selection)
  - User enters mobile/consumer number in this field
  - On blur/enter, call `/api/android/operator-info/` to auto-detect operator
- **If `has_active_operator_check_api: false`**:
  - Show operator selection **FIRST**
  - User selects operator manually

**Status**: ❌ **NOT IMPLEMENTED** - New endpoint, needs implementation

**Use Case**: This endpoint should be called when a user selects a service to determine the flow order.

---

### 3. Layout Settings API (Main Configuration)
**Endpoint**: `GET /api/android/layout-settings/all/`

**Alternative Endpoints** (for backward compatibility - tried in order):
- `GET /api/android/layout-settings/all/` (Primary)
- `GET /api/layout-settings/all/`
- `GET /api/layout-settings/`
- `GET /api/recharge-layouts/`
- `GET /api/android/recharge-layouts/`

**Location**: `lib/core/repository/layoutRepository/layoutRepo.dart`

**Authentication**: Bearer Token (JWT)

**Purpose**: Get layout configuration for all operator types. Returns fields, buttons, and endpoints.

**Response Structure**:
```json
{
  "success": true,
  "layouts": [
    {
      "operator_type_id": 1,
      "operator_type_name": "Prepaid",
      "is_active": true,
      "icon": "/media/operator_types/prepaid.png",
      "booking_button": true,
      "payment_button": true,
      "request_button": true,
      "fetch_bill_button": false,
      "booking_endpoint": "/api/android/recharge/booking/",
      "payment_endpoint": "/api/android/recharge/payment/",
      "request_endpoint": "/api/android/recharge/request/",
      "fetch_bill_endpoint": "",
      "operator_dropdown": {
        "enabled": true,
        "endpoint": "/api/android/operators/1/"
      },
      "auto_operator": {
        "enabled": true,
        "endpoint": "/api/android/auto-operator/{MOBILE}/"
      },
      "buttons": [
        {
          "key": "view_plan",
          "type": "fetch",
          "label": "View Plans",
          "function": "/api/android/feature-api-data/?operator_id={OPERATOR}&feature_type=plans&mobile={MOBILE}&operator_code={OPERATORCODE}"
        },
        {
          "key": "best_offer",
          "type": "fetch",
          "label": "Best Offers",
          "function": "/api/android/feature-api-data/?operator_id={OPERATOR}&feature_type=best_offers&mobile={MOBILE}&operator_code={OPERATORCODE}"
        }
      ],
      "fields": [
        {
          "name": "mobile",
          "type": "tel",
          "hint": "Enter Mobile Number",
          "remark": "10 digit mobile number",
          "required": true,
          "display_order": 1,
          "api_placeholder": "MOBILE",
          "show_after_operator_fetch": false,
          "show_after_bill_fetch": false,
          "is_editable_after_fetch": true,
          "validation": {
            "min_length": 10,
            "max_length": 10,
            "pattern": "^[0-9]{10}\$"
          }
        },
        {
          "name": "amount",
          "type": "number",
          "hint": "Enter Amount",
          "remark": "",
          "required": true,
          "display_order": 2,
          "api_placeholder": "AMOUNT",
          "show_after_operator_fetch": false,
          "show_after_bill_fetch": false,
          "is_editable_after_fetch": true,
          "validation": {
            "min_value": 1.0,
            "max_value": 10000.0
          }
        }
      ],
      "amount": {
        "enabled": true,
        "editable": true
      },
      "bill_fetch_mode": "both",
      "require_bill_fetch_first": false,
      "amount_editable_after_fetch": true
    }
  ],
  "total_count": 4
}
```

**Key Changes from Old System**:
- ✅ Response now wrapped in `{success: true, layouts: [...]}` (already handled in code)
- ✅ Button `function` URLs now use unified `/api/android/feature-api-data/` endpoint
- ✅ New placeholders: `{OPERATORCODE}` in addition to `{MOBILE}` and `{OPERATOR}`
- ✅ `{OPERATOR}` in button functions should be operator_id (not operator name)
- ✅ **NEW**: Fields include flow control properties (`show_after_operator_fetch`, `show_after_bill_fetch`, `is_editable_after_fetch`)
- ✅ **NEW**: Fields include `display_order` for field ordering
- ✅ **NEW**: Fields include `api_placeholder` for API parameter mapping
- ✅ **NEW**: Complete validation rules (min/max length, min/max value, patterns)
- ✅ **NEW**: Bill fetch flow control (`bill_fetch_mode`, `require_bill_fetch_first`, `amount_editable_after_fetch`)

**Status**: ✅ **IMPLEMENTED** - Code already handles `layouts` key in response

**Note**: Flow control properties and field ordering are available in the API response but not yet fully utilized in the UI. See `ANDROID_FEATURE_PARITY_STATUS.md` for enhancement opportunities.

---

### 4. Operators List API
**Endpoint**: `GET /api/android/operators/{OPERATORTYPEID}/`

**Location**: `lib/View/testRechargePage.dart` (line ~342)

**Authentication**: Bearer Token (JWT)

**Purpose**: Get list of operators for a specific operator type

**Response**:
```json
{
  "operators": [
    {
      "OperatorID": 1,
      "OperatorName": "Airtel",
      "OperatorName_DB": "Airtel",
      "OperatorCode": "AIRTEL",
      "icon": "/media/operators/airtel.png"
    },
    {
      "OperatorID": 2,
      "OperatorName": "Jio",
      "OperatorName_DB": "Jio",
      "OperatorCode": "JIO",
      "icon": "/media/operators/jio.png"
    }
  ]
}
```

**Key Changes**:
- ✅ Now includes `OperatorCode` field (needed for button function URLs)

**Status**: ✅ **IMPLEMENTED** - Need to ensure `OperatorCode` is stored and used

---

### 5. Operator Form Config API (Operator-Specific)

**Endpoint**: `GET /api/android/operator-form-config/?operator_id={OPERATOR_ID}`

**Purpose**: Get detailed form configuration for a specific operator (when user selects an operator)

**Authentication**: Bearer Token (JWT)

**Response Structure**:
```json
{
  "operator_id": 1,
  "operator_name": "Airtel",
  "operator_type_id": 1,
  "operator_type_name": "Prepaid",
  "has_active_operator_check_api": true,
  "operator_check_api_field_name": "mobile",
  "operator_check_api_placeholder": "MOBILE",
  "has_operator_fetching": true,
  "fields": [...],
  "features": [...],
  "bill_fetch_mode": "both",
  "require_bill_fetch_first": false,
  "amount_editable_after_fetch": true
}
```

**Key Features**:
- Operator-specific form fields with flow control
- Operator-specific feature buttons
- Complete validation rules
- Field ordering (`display_order`)
- Flow control properties (`show_after_operator_fetch`, `show_after_bill_fetch`, `is_editable_after_fetch`)

**Status**: ⚠️ **PARTIALLY IMPLEMENTED** - Currently using layout settings; this API provides operator-specific configs

**Note**: Should be called when operator is selected to get operator-specific fields and features that may differ from the operator type template.

---

### 6. Auto Operator Detection API
**Endpoint**: `GET /api/android/operator-info/?mobile={MOBILE}&operator_type_id={TYPE_ID}`

**Alternative Endpoint**: `GET /api/android/auto-operator/{MOBILE}/` (legacy, still works)

**Location**: `lib/View/testRechargePage.dart` (line ~389)

**Authentication**: Bearer Token (JWT)

**Purpose**: Automatically detect operator from mobile number

**Response**:
```json
{
  "success": true,
  "operator_id": 1,
  "operator_name": "Airtel",
  "operator_code": "AIRTEL"
}
```

**How it works**:
- Uses `OperatorCheckAPI` configuration
- Uses `operatorCheckApiHelper` (same as web)
- Supports operator type-wise API switching
- Supports operator-specific API switching
- Includes operator code mapping
- Calls external API to detect operator
- Returns operator ID, name, and code from database

**Request Parameters**:
- `mobile`: Mobile/consumer number (required)
- `operator_type_id`: Operator type ID (optional but recommended)

**Response**:
```json
{
  "operator_id": 1,
  "OperatorID": 1,
  "_mapped_operator_id": 1,
  "operator_name": "Airtel",
  "OperatorName": "Airtel",
  "_mapped_operator_name": "Airtel",
  "status": 1
}
```

**Status**: ✅ **IMPLEMENTED** - Currently uses `/api/android/auto-operator/{MOBILE}/`

**Note**: Should use `/api/android/operator-info/` with `operator_type_id` parameter for better consistency with web interface

---

### 7. Booking API
**Endpoint**: `POST /api/android/recharge/booking/`

**Location**: `lib/View/testRechargePage.dart` (line ~475)

**Authentication**: Bearer Token (JWT)

**Purpose**: Book/initiate a recharge transaction

**Request Body**:
```json
{
  "operator": 1,
  "mobile": "9876543210",
  "amount": "100",
  "secure_key": "optional_pin",
  "consumer_number": "optional",
  "date_of_birth": "optional"
}
```

**Note**: All form fields configured in Operator Master can be sent here.

**Response**:
```json
{
  "success": true,
  "message": "Recharge successful",
  "transaction_id": "TXN123456",
  "status": "SUCCESS"
}
```

**Status**: ✅ **IMPLEMENTED** - No changes needed

---

### 8. Payment API
**Endpoint**: `POST /api/android/recharge/payment/`

**Location**: `lib/View/testRechargePage.dart` (line ~661)

**Authentication**: Bearer Token (JWT)

**Request/Response**: Same as Booking API

**Status**: ✅ **IMPLEMENTED** - No changes needed

---

### 9. Request API
**Endpoint**: `POST /api/android/recharge/request/`

**Location**: `lib/View/testRechargePage.dart` (line ~549)

**Authentication**: Bearer Token (JWT)

**Request/Response**: Same as Booking API

**Status**: ✅ **IMPLEMENTED** - No changes needed

---

### 10. Fetch Bill API
**Endpoint**: `GET /api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/`

**Location**: `lib/View/testRechargePage.dart` (line ~823)

**Authentication**: Bearer Token (JWT)

**Purpose**: Fetch bill details for postpaid/utility services

**Response**:
```json
{
  "success": true,
  "name": "Customer Name",
  "amount": "500.00",
  "bill_date": "2025-01-15",
  "due_date": "2025-01-25",
  "bill_number": "BILL123456",
  "balance": "100.00"
}
```

**Status**: ✅ **IMPLEMENTED** - No changes needed

---

### 11. Feature API Data (Plans, Offers, Heavy Refresh, DTH Info) ⚠️ **MAJOR CHANGE**
**Endpoint**: `GET /api/android/feature-api-data/?operator_id={ID}&feature_type={TYPE}&mobile={MOBILE}&operator_code={CODE}`

**Location**: `lib/View/testRechargePage.dart` (line ~890 - `fetchPlans` method)

**Authentication**: Bearer Token (JWT)

**Purpose**: Fetch dynamic feature data (plans, offers, heavy refresh, DTH info)

**Parameters**:
- `operator_id`: OperatorMaster ID (required) - Use `{OPERATOR}` placeholder
- `feature_type`: `plans`, `best_offers`, `heavy_refresh`, `dth_info` (required)
- `mobile`: Mobile number (optional) - Use `{MOBILE}` placeholder
- `operator_code`: Operator code for API (optional) - Use `{OPERATORCODE}` placeholder

**Response Format 1 (Regular Plans/Offers)**:
```json
{
  "success": true,
  "data": [
    {
      "rs": "10",
      "desc": "Talktime Rs. 10",
      "validity": "28 days"
    }
  ],
  "categories": ["TOPUP", "3G/4G"],
  "display_format": "categorized"
}
```

**Response Format 2 (DTH Plans with Multiple Durations)**:
```json
{
  "success": true,
  "data": [
    {
      "plan_name": "Basic Pack",
      "amount_options": {
        "1 MONTHS": "150",
        "3 MONTHS": "400",
        "6 MONTHS": "750"
      },
      "description": "DTH Plan Description"
    }
  ],
  "display_format": "categorized"
}
```

**Response Format 3 (DTH Info)**:
```json
{
  "success": true,
  "data": {
    "customerName": "John Doe",
    "Balance": "100.00",
    "MonthlyRecharge": "500",
    "status": "Active",
    "NextRechargeDate": "2025-02-01",
    "planname": "Premium Pack"
  }
}
```

**Response Format 4 (Heavy Refresh)**:
```json
{
  "success": true,
  "data": {
    "desc": "Refresh successful",
    "customerName": "John Doe",
    "status": 1
  }
}
```

**Key Changes from Old System**:
- ⚠️ **BREAKING CHANGE**: Response structure changed from `{records: [...]}` to `{success: true, data: [...]}`
- ⚠️ **BREAKING CHANGE**: URL format changed from path parameters to query string
- ⚠️ **NEW**: Requires `operator_code` parameter (from `OperatorCode` field)
- ⚠️ **NEW**: `{OPERATOR}` placeholder should be operator_id (not operator name)

**Status**: ⚠️ **NEEDS CODE UPDATES** - See "Required Code Changes" section below

---

## Summary of All Endpoints

### Homepage Services
1. ❌ **Services List API** - `GET /api/android/services/` (NOT IMPLEMENTED - Currently hardcoded)

### Service Flow
2. ❌ **Check Operator Type API** - `GET /api/android/check-operator-type-api/?operator_type_id={ID}` (NOT IMPLEMENTED - New endpoint)
3. ✅ **Operators List** - `GET /api/android/operators/{OPERATORTYPEID}/`
4. ✅ **Operator Form Config** - `GET /api/android/operator-form-config/` (PARTIALLY - Using layout settings)
5. ✅ **Auto Operator Detection** - `GET /api/android/operator-info/` or `/api/android/auto-operator/{MOBILE}/`

### Service Page Content
6. ✅ **Layout Settings** - `GET /api/android/layout-settings/all/` (Primary endpoint)
7. ✅ **Fetch Bill** - `GET /api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/`
8. ✅ **Booking** - `POST /api/android/recharge/booking/`
9. ✅ **Payment** - `POST /api/android/recharge/payment/`
10. ✅ **Request** - `POST /api/android/recharge/request/`
11. ✅ **Feature API Data** - `GET /api/android/feature-api-data/` (UPDATED - All fixes complete)

---

## Total API Count

- **Homepage Services**: 0 APIs (hardcoded) - **1 API needed**
- **Service Flow**: **4 APIs** (2 implemented, 1 partial, 1 new)
- **Service Operations**: **6 APIs** (All implemented and updated)

**Total: 9 implemented APIs + 1 missing API = 10 APIs total**

---

## Base URL

All endpoints use the base URL from `lib/core/const/assets_const.dart`:
```dart
static const String apiBase = 'http://192.168.1.7:8001/';
```

---

## Authentication

All APIs require:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

The access token is stored in SharedPreferences and retrieved before each API call.

---

## Required Code Changes

### ⚠️ CRITICAL: Feature API Data Response Parsing

**File**: `lib/View/testRechargePage.dart` (line ~890 - `fetchPlans` method)

**Current Code** (expects old format):
```dart
if (data['records'] != null && data['records'] is List) {
  offers = data['records'] as List;
}
```

**Required Change** (new format):
```dart
if (data['success'] == true && data['data'] != null) {
  if (data['data'] is List) {
    offers = data['data'] as List;
  } else if (data['data'] is Map) {
    // Handle DTH info or heavy refresh format
  }
}
```

### ⚠️ CRITICAL: Button Function URL Replacement

**File**: `lib/View/testRechargePage.dart` (line ~1225 - `buildDynamicButtons` method)

**Current Code**:
```dart
String url = "${AssetsConst.apiBase}$function"
    .replaceAll("{MOBILE}", mobileController.text)
    .replaceAll(
      "{OPERATOR}",
      selectedOperator?.toString() ??
          widget.layout.operatorTypeName.toString(),
    );
```

**Required Changes**:
1. `{OPERATOR}` should be operator_id (already using `selectedOperator`, which should be ID)
2. Need to add `{OPERATORCODE}` replacement from operator list
3. Need to get operator code from `operatorList` when operator is selected

**Updated Code**:
```dart
// Get operator code from operatorList
String? operatorCode;
if (selectedOperator != null && operatorList.isNotEmpty) {
  try {
    final operator = operatorList.firstWhere((op) {
      final id = (op['OperatorID'] is int)
          ? op['OperatorID'] as int
          : int.tryParse(op['OperatorID'].toString());
      return id == selectedOperator;
    }, orElse: () => null);
    if (operator != null) {
      operatorCode = operator['OperatorCode']?.toString();
    }
  } catch (e) {
    print('Error getting operator code: $e');
  }
}

String url = "${AssetsConst.apiBase}$function"
    .replaceAll("{MOBILE}", mobileController.text)
    .replaceAll(
      "{OPERATOR}",
      selectedOperator?.toString() ??
          widget.layout.operatorTypeId.toString(),
    )
    .replaceAll(
      "{OPERATORCODE}",
      operatorCode ?? "",
    );
```

### ⚠️ CRITICAL: DTH Plans Response Format

**File**: `lib/View/testRechargePage.dart` (line ~924 - `fetchPlans` method)

**Current Code** (expects old format):
```dart
if (data['records'] != null &&
    data['records'] is Map &&
    !(data['records'] is List)) {
  dthPlans = DthPlans.fromJson(data);
}
```

**Required Change** (new format):
```dart
if (data['success'] == true && 
    data['data'] != null && 
    data['data'] is List &&
    data['data'].isNotEmpty &&
    data['data'][0] is Map &&
    data['data'][0]['amount_options'] != null) {
  // New DTH plans format with amount_options
  // May need to update DthPlans model or create new parsing logic
}
```

### ⚠️ CRITICAL: DTH Info Response Format

**File**: `lib/View/testRechargePage.dart` (line ~967 - `fetchDthInfo` method)

**Current Code** (expects old format):
```dart
final dthInfo = DthInfo.fromJson(data);
```

**Required Change** (new format):
```dart
if (data['success'] == true && data['data'] != null) {
  // New format: data is directly in data['data'], not in records array
  final dthInfo = DthInfo.fromJson({
    'tel': mobileController.text,
    'operator': widget.layout.operatorTypeName,
    'records': data['data'] is Map ? [data['data']] : data['data'],
    'status': 1
  });
}
```

### ⚠️ CRITICAL: DTH Heavy Refresh Response Format

**File**: `lib/View/testRechargePage.dart` (line ~1007 - `performDthHeavyRefresh` method)

**Current Code** (expects old format):
```dart
final refreshData = DthHeavyRefresh.fromJson(data);
```

**Required Change** (new format):
```dart
if (data['success'] == true && data['data'] != null) {
  final refreshData = DthHeavyRefresh.fromJson({
    'tel': mobileController.text,
    'operator': widget.layout.operatorTypeName,
    'records': data['data'],
    'status': 1
  });
}
```

### ✅ OPTIONAL: Services List API Implementation

**File**: `lib/View/Home/widgets/servicesGrid.dart`

**Status**: Currently hardcoded. Should implement API call to fetch services dynamically.

**Implementation Steps**:
1. Create `ServicesRepository` class
2. Add `fetchServices()` method calling `/api/android/services/`
3. Update `servicesGrid.dart` to use API data instead of hardcoded list
4. Handle loading and error states

---

## Compatibility Notes

### Backward Compatibility
- ✅ Layout repository already handles both old (direct list) and new (`{success, layouts}`) response formats
- ⚠️ Feature API Data endpoint response format changed - requires code updates
- ⚠️ Button function URLs changed format - requires code updates

### Migration Path
1. Update response parsing in `fetchPlans`, `fetchDthInfo`, `performDthHeavyRefresh`
2. Update button URL replacement to handle `{OPERATORCODE}`
3. Ensure `selectedOperator` is operator_id (not operator name)
4. Test all feature buttons (View Plans, Best Offers, DTH Info, Heavy Refresh)
5. Implement Services List API (optional but recommended)

---

## Testing Checklist

- [ ] Layout Settings API returns `{success, layouts}` format
- [ ] Button function URLs include `{OPERATORCODE}` placeholder
- [ ] Operator list includes `OperatorCode` field
- [ ] Feature API Data returns `{success, data}` format
- [ ] Plans/Offers display correctly with new format
- [ ] DTH Info works with new format
- [ ] DTH Heavy Refresh works with new format
- [ ] DTH Plans with multiple durations display correctly
- [ ] All placeholders (`{MOBILE}`, `{OPERATOR}`, `{OPERATORCODE}`) are replaced correctly

---

## Notes

1. **Unified System**: All configurations now come from Operator Master, same as web interface
2. **Dynamic Configuration**: New operators/types work automatically without code changes
3. **Response Wrapping**: Most APIs now return `{success: true, data: ...}` format
4. **Operator Code**: New requirement for feature API calls - must be extracted from operator list
5. **Query String Format**: Feature API now uses query parameters instead of path parameters
