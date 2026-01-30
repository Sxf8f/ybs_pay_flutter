# API Migration Requirements - Critical Issues & Fixes

## Overview
The backend has migrated to a unified API system. This document outlines **critical code changes** required for the Android app to work with the new APIs.

---

## 🚨 CRITICAL ISSUES (Must Fix)

### 1. Feature API Data Response Format Change

**Impact**: HIGH - All plans/offers/DTH features will break

**Location**: `lib/View/testRechargePage.dart`

**Issue**: 
- Old format: `{records: [...]}`
- New format: `{success: true, data: [...]}`

**Files to Update**:
- `fetchPlans()` method (line ~890)
- `fetchDthInfo()` method (line ~967)
- `performDthHeavyRefresh()` method (line ~1007)

**Fix Required**:
```dart
// OLD CODE (BROKEN):
if (data['records'] != null && data['records'] is List) {
  offers = data['records'] as List;
}

// NEW CODE (FIXED):
if (data['success'] == true && data['data'] != null) {
  if (data['data'] is List) {
    offers = data['data'] as List;
  }
}
```

---

### 2. Button Function URL Placeholder Replacement

**Impact**: HIGH - Button clicks will fail with wrong URLs

**Location**: `lib/View/testRechargePage.dart` - `buildDynamicButtons()` method (line ~1225)

**Issue**:
- New button functions use: `/api/android/feature-api-data/?operator_id={OPERATOR}&feature_type=plans&mobile={MOBILE}&operator_code={OPERATORCODE}`
- Missing `{OPERATORCODE}` replacement
- `{OPERATOR}` must be operator_id (not operator name)

**Fix Required**:
1. Extract `OperatorCode` from `operatorList` when operator is selected
2. Add `{OPERATORCODE}` replacement in URL building
3. Ensure `{OPERATOR}` uses operator_id (already correct if `selectedOperator` is ID)

**Code Change**:
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

---

### 3. DTH Plans Format Change

**Impact**: MEDIUM - DTH plans may not display correctly

**Location**: `lib/View/testRechargePage.dart` - `fetchPlans()` method

**Issue**:
- Old format: `{records: {"1 MONTHS": [...], "3 MONTHS": [...]}}`
- New format: `{data: [{plan_name: "...", amount_options: {"1 MONTHS": "150", ...}}]}`

**Fix Required**:
- Update DTH plans parsing logic
- May need to update `DthPlans` model or create adapter

---

### 4. DTH Info Response Format Change

**Impact**: MEDIUM - DTH info feature will break

**Location**: `lib/View/testRechargePage.dart` - `fetchDthInfo()` method (line ~967)

**Issue**:
- Old format: `{tel: "...", operator: "...", records: [...], status: 1}`
- New format: `{success: true, data: {...}}`

**Fix Required**:
```dart
// OLD CODE (BROKEN):
final dthInfo = DthInfo.fromJson(data);

// NEW CODE (FIXED):
if (data['success'] == true && data['data'] != null) {
  final dthInfo = DthInfo.fromJson({
    'tel': mobileController.text,
    'operator': widget.layout.operatorTypeName,
    'records': data['data'] is Map ? [data['data']] : data['data'],
    'status': 1
  });
}
```

---

### 5. DTH Heavy Refresh Response Format Change

**Impact**: MEDIUM - Heavy refresh feature will break

**Location**: `lib/View/testRechargePage.dart` - `performDthHeavyRefresh()` method (line ~1007)

**Issue**:
- Old format: `{tel: "...", operator: "...", records: {...}, status: 1}`
- New format: `{success: true, data: {...}}`

**Fix Required**:
```dart
// OLD CODE (BROKEN):
final refreshData = DthHeavyRefresh.fromJson(data);

// NEW CODE (FIXED):
if (data['success'] == true && data['data'] != null) {
  final refreshData = DthHeavyRefresh.fromJson({
    'tel': mobileController.text,
    'operator': widget.layout.operatorTypeName,
    'records': data['data'],
    'status': 1
  });
  _showSuccessAlert(refreshData.records.desc);
}
```

---

## ✅ COMPATIBLE (No Changes Needed)

### 1. Layout Settings API
- ✅ Already handles both old (direct list) and new (`{success, layouts}`) formats
- ✅ Code in `layoutRepo.dart` already checks for `layouts` key

### 2. Operators List API
- ✅ Response format unchanged
- ✅ Now includes `OperatorCode` field (just need to use it)

### 3. Auto Operator Detection API
- ✅ Response format unchanged

### 4. Booking/Payment/Request APIs
- ✅ Request/response format unchanged

### 5. Fetch Bill API
- ✅ Response format unchanged (may have additional `balance` field)

---

## 📋 OPTIONAL IMPROVEMENTS

### 1. Services List API Implementation
**Priority**: LOW (currently hardcoded works, but API is better)

**Location**: `lib/View/Home/widgets/servicesGrid.dart`

**Action**: Implement API call to fetch services dynamically instead of hardcoded list

---

## 🔍 VERIFICATION CHECKLIST

After making changes, verify:

- [ ] View Plans button works and displays plans correctly
- [ ] Best Offers button works and displays offers correctly
- [ ] DTH Info button works and displays customer info
- [ ] DTH Heavy Refresh button works
- [ ] All button URLs are correctly formatted with all placeholders replaced
- [ ] Operator code is correctly extracted from operator list
- [ ] Response parsing handles both old and new formats (if needed for transition)
- [ ] Error handling for missing operator code
- [ ] Error handling for API response format changes

---

## 🧪 TESTING SCENARIOS

1. **Test Plans/Offers**:
   - Select an operator
   - Click "View Plans" or "Best Offers"
   - Verify plans/offers display correctly

2. **Test DTH Features**:
   - Select a DTH operator
   - Click "DTH Info" - verify customer info displays
   - Click "Heavy Refresh" - verify refresh works

3. **Test URL Building**:
   - Add debug logging to see final URLs
   - Verify all placeholders are replaced
   - Verify operator_code is included when available

4. **Test Error Handling**:
   - Test with missing operator code
   - Test with API returning error
   - Test with invalid response format

---

## 📝 SUMMARY

**Critical Fixes Required**: 5
- Feature API response parsing (3 methods)
- Button URL placeholder replacement
- DTH plans format handling

**Estimated Impact**: HIGH - Features will not work without these fixes

**Estimated Time**: 2-4 hours for all fixes

**Risk Level**: MEDIUM - Changes are straightforward but need thorough testing

---

## 🚀 RECOMMENDED IMPLEMENTATION ORDER

1. **First**: Fix button URL placeholder replacement (Issue #2)
   - This is the foundation for all feature API calls

2. **Second**: Fix response parsing in `fetchPlans()` (Issue #1)
   - Most commonly used feature

3. **Third**: Fix DTH Info and Heavy Refresh (Issues #4, #5)
   - Less commonly used but still important

4. **Fourth**: Fix DTH Plans format (Issue #3)
   - May require model updates

5. **Last**: Implement Services List API (Optional)
   - Nice to have but not critical

---

## 📞 SUPPORT

If you encounter issues:
1. Check API response format matches new documentation
2. Verify all placeholders are being replaced correctly
3. Check operator code is available in operator list
4. Review error logs for specific API failures
