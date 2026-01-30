# Complete Android API Flow Documentation

## Overview
This document describes the **complete flow** from services listing to payment, matching the exact same flow as the web interface. All APIs use the same operator-based configuration system.

---

## Complete Flow: Services → Payment

### Step 1: Get Services List (Homepage)

**Endpoint**: `GET /api/android/services/`

**Purpose**: Get list of operator types to display on homepage

**Authentication**: Bearer Token (JWT)

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
    }
  ],
  "total_count": 4
}
```

**Location**: `lib/View/Home/widgets/servicesGrid.dart` (Currently hardcoded - needs implementation)

**Status**: ❌ **NOT IMPLEMENTED** - Currently hardcoded

---

### Step 2: Check Operator Type Check API (On Service Selection)

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

---

### Step 3: Get Operators List (If No Operator Check OR After Operator Check)

**Endpoint**: `GET /api/android/operators/{OPERATORTYPEID}/`

**Purpose**: Get list of operators for this operator type

**Authentication**: Bearer Token (JWT)

**Response**:
```json
{
  "operators": [
    {
      "OperatorID": 1,
      "OperatorName": "Airtel",
      "OperatorCode": "AIRTEL",
      "icon": "/media/operators/airtel.png"
    }
  ]
}
```

**Android Action**:
- Show operator dropdown/list
- If operator check is enabled, this appears **AFTER** the operator check field
- If operator check is NOT enabled, this appears **FIRST**

**Location**: `lib/View/testRechargePage.dart` (line ~342)

**Status**: ✅ **IMPLEMENTED** - Working

---

### Step 4: Auto-Detect Operator (If Operator Check Enabled)

**Endpoint**: `GET /api/android/operator-info/?mobile={MOBILE}&operator_type_id={TYPE_ID}`

**Alternative**: `GET /api/android/auto-operator/{MOBILE}/?operator_type_id={TYPE_ID}`

**Purpose**: Auto-detect operator from mobile/consumer number

**Authentication**: Bearer Token (JWT)

**Request Parameters**:
- `mobile`: Mobile/consumer number (from operator check field)
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

**Android Action**:
- Auto-select operator from response (`operator_id` or `OperatorID`)
- Proceed to Step 5 (load operator form config)

**Location**: `lib/View/testRechargePage.dart` (line ~389)

**Status**: ✅ **IMPLEMENTED** - Currently uses `/api/android/auto-operator/{MOBILE}/`

**Note**: Could optionally use `/api/android/operator-info/` for better consistency with web interface

---

### Step 5: Get Operator Form Config (On Operator Selection)

**Endpoint**: `GET /api/android/operator-form-config/?operator_id={OPERATOR_ID}`

**Purpose**: Get form configuration for selected operator (fields, features, flow control)

**Authentication**: Bearer Token (JWT)

**Response**:
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
  "fields": [
    {
      "id": 1,
      "name": "mobile",
      "label": "Mobile Number",
      "type": "tel",
      "placeholder": "Enter Mobile Number",
      "required": true,
      "display_order": 1,
      "api_placeholder": "{MOBILE}",
      "show_after_operator_fetch": false,
      "show_after_bill_fetch": false,
      "is_editable_after_fetch": true,
      "validation": {
        "min_length": 10,
        "max_length": 10,
        "pattern": "[0-9]{10}"
      }
    },
    {
      "name": "operator",
      "label": "Select Operator",
      "type": "select",
      "display_order": 2,
      "show_after_operator_fetch": true
    },
    {
      "name": "amount",
      "label": "Amount",
      "type": "number",
      "placeholder": "Enter Amount",
      "required": true,
      "display_order": 3,
      "api_placeholder": "{AMOUNT}",
      "show_after_bill_fetch": false,
      "validation": {
        "min_value": 1.0,
        "max_value": 10000.0
      }
    }
  ],
  "features": [
    {
      "id": 1,
      "type": "plans",
      "label": "View Plans",
      "button_class": "btn-info",
      "display_order": 1
    },
    {
      "type": "fetch_bill",
      "label": "Fetch Bill",
      "display_order": 2
    }
  ],
  "bill_fetch_mode": "both",
  "require_bill_fetch_first": false,
  "amount_editable_after_fetch": true,
  "booking_endpoint": "/api/android/recharge/booking/",
  "payment_endpoint": "/api/android/recharge/payment/",
  "fetch_bill_endpoint": "/api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/"
}
```

**Android Action - Field Ordering**:
1. **Operator Check Fields** (if `has_active_operator_check_api: true` and field matches `operator_check_api_field_name`):
   - Show **FIRST**
   - These are fields that provide value for operator check API (e.g., mobile, consumer_number)
   
2. **Operator Selection Field** (fields with `name: "operator"` or `show_after_operator_fetch: true`):
   - Show **SECOND** (or FIRST if no operator check)
   - Can be shown/hidden based on `show_after_operator_fetch`
   
3. **Regular Fields** (all other fields):
   - Show **THIRD**
   - Sorted by `display_order`
   
4. **Bill Fetch Fields** (fields with `show_after_bill_fetch: true`):
   - Show **FOURTH**
   - Hidden initially if `require_bill_fetch_first: true`

**Field Filtering Logic**:
```dart
// Pseudo-code for Android
List<dynamic> getVisibleFields() {
  List<dynamic> visibleFields = [];
  
  for (var field in fields) {
    // Check flow control
    if (field['show_after_operator_fetch'] == true && !isOperatorFetched) {
      continue; // Hide until operator fetched
    }
    if (field['show_after_bill_fetch'] == true && !isBillFetched) {
      continue; // Hide until bill fetched
    }
    
    visibleFields.add(field);
  }
  
  // Sort by display_order
  visibleFields.sort((a, b) {
    int orderA = a['display_order'] ?? 999;
    int orderB = b['display_order'] ?? 999;
    return orderA.compareTo(orderB);
  });
  
  return visibleFields;
}
```

**Location**: Currently using layout settings, could use operator form config

**Status**: ⚠️ **PARTIALLY IMPLEMENTED** - Using layout settings; operator form config not yet implemented

---

### Step 6: Render Feature Buttons

**Purpose**: Display dynamic buttons (Plans, Offers, Fetch Bill, etc.)

**Data Source**: From `features` array in operator form config (or `buttons` array in layout settings)

**Android Action**:
- Render buttons based on `features` array
- Each feature has:
  - `type`: `plans`, `best_offers`, `fetch_bill`, `heavy_refresh`, `dth_info`
  - `label`: Button text
  - `display_order`: Order of buttons

**Location**: `lib/View/testRechargePage.dart` - `buildDynamicButtons()` method

**Status**: ✅ **IMPLEMENTED** - Using buttons from layout settings

---

### Step 7: Handle Feature Button Clicks

#### 7.1: View Plans / Best Offers

**Endpoint**: `GET /api/android/feature-api-data/?operator_id={ID}&feature_type={TYPE}&mobile={MOBILE}&operator_code={CODE}`

**Response**:
```json
{
  "success": true,
  "data": [...],
  "display_format": "categorized",
  "categories": ["TOPUP", "3G/4G"]
}
```

**Location**: `lib/View/testRechargePage.dart` - `fetchPlans()` method

**Status**: ✅ **IMPLEMENTED** - Updated for new format

#### 7.2: Fetch Bill

**Endpoint**: `GET /api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/`

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

**Android Action**:
- Prefill amount field with `amount` from response
- Display other bill details (name, bill_date, due_date, etc.)
- If `bill_fetch_mode: "fetch_only"`, make amount field non-editable
- If `require_bill_fetch_first: true`, show pay button now

**Location**: `lib/View/testRechargePage.dart` (line ~823)

**Status**: ✅ **IMPLEMENTED** - Working

---

### Step 8: Process Payment

**Endpoint**: `POST /api/android/recharge/booking/`

**Purpose**: Process recharge transaction

**Authentication**: Bearer Token (JWT)

**Request Body**:
```json
{
  "operator": 1,
  "mobile": "9876543210",
  "amount": "100",
  "consumer_number": "optional",
  "date_of_birth": "optional",
  "secure_key": "optional_pin"
}
```

**Note**: All form fields configured in Operator Master can be sent here. The system will:
1. Map form fields to API placeholders
2. Validate all required fields
3. Process recharge using unified recharge service
4. Return transaction result

**Response**:
```json
{
  "success": true,
  "message": "Recharge successful",
  "transaction_id": "TXN123456",
  "status": "SUCCESS"
}
```

**Location**: `lib/View/testRechargePage.dart` (line ~475)

**Status**: ✅ **IMPLEMENTED** - Working

---

## Field Display Order Rules

### Rule 1: Operator Check Flow (if enabled)
```
1. Operator Check Field (mobile/consumer) → FIRST
2. Operator Selection → SECOND
3. Regular Fields → THIRD
4. Bill Fetch Fields → FOURTH
```

### Rule 2: Normal Flow (if operator check NOT enabled)
```
1. Operator Selection → FIRST
2. Regular Fields → SECOND
3. Bill Fetch Fields → THIRD
```

### Rule 3: Field Visibility
- `show_after_operator_fetch: true` → Hide until operator is fetched
- `show_after_bill_fetch: true` → Hide until bill is fetched (if `require_bill_fetch_first: true`)
- Otherwise → Always show (sorted by `display_order`)

---

## Complete Example Flow

### Scenario 1: Prepaid with Operator Check

1. **User selects "Prepaid" service**
   - Call `/api/android/services/` → Get services list
   
2. **Check operator type**
   - Call `/api/android/check-operator-type-api/?operator_type_id=1`
   - Response: `has_active_operator_check_api: true`, `field_config` exists
   - **Action**: Show mobile field FIRST (from `field_config`)
   
3. **User enters mobile "9876543210"**
   - On blur/enter, call `/api/android/operator-info/?mobile=9876543210&operator_type_id=1`
   - Response: `operator_id: 1` (Airtel)
   - **Action**: Auto-select Airtel operator
   
4. **Load operator config**
   - Call `/api/android/operator-form-config/?operator_id=1`
   - **Action**: Render fields in order:
     1. Mobile field (already shown, keep it)
     2. Operator selection (show with Airtel selected)
     3. Amount field
     4. Feature buttons (View Plans, Best Offers)
   
5. **User clicks "View Plans"**
   - Call `/api/android/feature-api-data/?operator_id=1&feature_type=plans&mobile=9876543210&operator_code=AIRTEL`
   - Display plans
   
6. **User enters amount and clicks "Pay"**
   - Call `/api/android/recharge/booking/` with all form data
   - Process recharge

### Scenario 2: Postpaid without Operator Check

1. **User selects "Postpaid" service**
   - Call `/api/android/check-operator-type-api/?operator_type_id=2`
   - Response: `has_active_operator_check_api: false`
   - **Action**: Show operator selection FIRST
   
2. **User selects operator**
   - Call `/api/android/operators/2/` → Get operators list
   - User selects operator
   - Call `/api/android/operator-form-config/?operator_id=5`
   - **Action**: Render fields:
     1. Operator selection (already shown)
     2. Mobile/consumer number field
     3. Amount field
     4. Fetch Bill button
   
3. **User clicks "Fetch Bill"**
   - Call `/api/android/recharge/fetch-bill/9876543210/5/`
   - Prefill amount and display bill details
   
4. **User clicks "Pay"**
   - Call `/api/android/recharge/booking/`
   - Process recharge

---

## Key API Endpoints Summary

| Step | Endpoint | Purpose | Status |
|------|----------|---------|--------|
| 1 | `GET /api/android/services/` | Get services list | ❌ Not implemented |
| 2 | `GET /api/android/check-operator-type-api/?operator_type_id={ID}` | Check if operator check enabled | ❌ Not implemented |
| 3 | `GET /api/android/operators/{TYPE_ID}/` | Get operators list | ✅ Implemented |
| 4 | `GET /api/android/operator-info/?mobile={MOBILE}&operator_type_id={ID}` | Auto-detect operator | ⚠️ Partial (uses auto-operator) |
| 5 | `GET /api/android/operator-form-config/?operator_id={ID}` | Get form config | ⚠️ Partial (uses layout settings) |
| 6 | `GET /api/android/feature-api-data/?feature_type={TYPE}&operator_id={ID}` | Get plans/offers/etc. | ✅ Implemented |
| 7 | `GET /api/android/recharge/fetch-bill/{MOBILE}/{OPERATOR}/` | Fetch bill | ✅ Implemented |
| 8 | `POST /api/android/recharge/booking/` | Process payment | ✅ Implemented |

---

## Flow Control Flags

### Operator Check
- `has_active_operator_check_api`: Is operator check API active?
- `operator_check_api_field_name`: Which field maps to operator check API?
- `operator_check_api_placeholder`: What placeholder does it use?
- `field_config`: Field configuration for operator check field (from check-operator-type-api)

### Bill Fetch
- `bill_fetch_mode`: `"fetch_only"`, `"manual_only"`, or `"both"`
- `require_bill_fetch_first`: Must fetch bill before payment?
- `amount_editable_after_fetch`: Can user edit amount after fetch?

### Field Flow
- `show_after_operator_fetch`: Show field after operator is fetched?
- `show_after_bill_fetch`: Show field after bill is fetched?
- `is_editable_after_fetch`: Is field editable after fetch?
- `display_order`: Field ordering (lower = earlier)

---

## Implementation Status

### ✅ Fully Implemented
- Operators List API
- Auto Operator Detection (basic)
- Feature API Data (plans, offers, DTH)
- Fetch Bill API
- Booking/Payment/Request APIs
- Dynamic buttons rendering

### ⚠️ Partially Implemented
- Layout Settings API (works but doesn't use operator form config)
- Auto Operator Detection (works but could use operator-info endpoint)
- Field ordering (not sorted by display_order)
- Field flow control (properties available but not fully utilized)

### ❌ Not Implemented
- Services List API (hardcoded)
- Check Operator Type API (new endpoint)
- Operator Form Config API (using layout settings instead)
- Complete field ordering and flow control

---

## Next Steps for Android App

### Priority 1: New Endpoints
1. **Implement Services List API** - Replace hardcoded services
2. **Implement Check Operator Type API** - Determine operator check flow
3. **Implement Operator Form Config API** - Get operator-specific configs

### Priority 2: Flow Control
1. **Implement field ordering** - Sort by display_order
2. **Implement field visibility** - Use show_after_operator_fetch, show_after_bill_fetch
3. **Implement bill fetch flow control** - Support all bill_fetch_mode options

### Priority 3: UX Enhancements
1. **Field validation** - Client-side validation using API rules
2. **Operator Info API** - Use unified endpoint for consistency
3. **Complete flow matching** - Match exact web interface flow

---

## Result

**Current Status**: ✅ **Core functionality working** - All essential recharge features work

**Next Steps**: ⚠️ **Flow improvements available** - Can enhance to match exact web flow with new endpoints

The app currently works but can be enhanced to exactly match the web interface flow using the new endpoints and flow control features.
