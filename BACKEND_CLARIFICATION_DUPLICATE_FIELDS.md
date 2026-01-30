# Backend API Clarification - Duplicate Field Prevention

## Issue
The Android app is showing duplicate "Mobile Number" fields when:
- Operator check is enabled (`has_active_operator_check_api: true`)
- Operator form config API returns a `mobile` field

## Current Behavior (Android App)
When operator check is enabled:
1. **First mobile field** is shown at the top (from operator check field config)
2. **Second mobile field** is shown below operator dropdown (from operator form config)

## Expected Behavior (Based on Web Implementation)
According to web documentation, when operator check is enabled:
1. **Initial mobile field** should be shown FIRST (before operator dropdown)
2. **Mobile field from operator form config** should be SKIPPED to prevent duplication
3. If initial mobile field has a value, mobile from config should definitely be skipped

## Question for Backend Team

### Question 1: Should operator form config API exclude mobile field when operator check is enabled?

**Scenario A**: Backend should NOT return `mobile` field in operator form config when operator check is enabled
- **Pro**: Prevents duplication at API level
- **Con**: Frontend still needs logic to handle both cases

**Scenario B**: Backend always returns `mobile` field, frontend skips it if operator check enabled
- **Pro**: Consistent API response
- **Con**: Frontend must handle skip logic

**Which approach should we use?**

---

### Question 2: What is the exact field name for operator check field?

When `check-operator-type-api` returns:
```json
{
  "has_active_operator_check_api": true,
  "field_config": {
    "field_name": "mobile",  // <-- Is this always "mobile"?
    ...
  }
}
```

And operator form config returns:
```json
{
  "fields": [
    {
      "name": "mobile",  // <-- Same name?
      ...
    }
  ]
}
```

**Are the field names always the same? Or can they differ?**
- If operator check field is `mobile` but config field is `MobileNumber`, we can't skip it by name matching

---

### Question 3: Should operator form config fields only be shown AFTER operator is fetched?

**Current API Response**:
```json
{
  "fields": [
    {
      "name": "mobile",
      "show_after_operator_fetch": false  // <-- Should this be true?
      ...
    },
    {
      "name": "amount",
      "show_after_operator_fetch": false
      ...
    }
  ]
}
```

**Question**: When operator check is enabled, should fields from operator form config:
- Option A: Always show (after operator fetch) - even if mobile duplicates
- Option B: Only show if `show_after_operator_fetch: true` - mobile can be hidden this way
- Option C: Mobile should have `show_after_operator_fetch: true` when operator check enabled (so it only shows after fetch, which we can skip)

---

### Question 4: What should happen to hardcoded amount field?

**Current Behavior**: Android app shows hardcoded "Amount" field if not in API config fields.

**Question**: Should we:
- Option A: Remove hardcoded amount field completely - only show if in API config
- Option B: Keep hardcoded amount as fallback if API config doesn't have it

**Preference**: Option A - No hardcoded fields, everything from API config only.

---

### Question 5: Button visibility - when should booking/request buttons show?

**Current API Response**:
```json
{
  "booking_button": true,  // <-- Is this always true?
  "request_button": true,  // <-- Is this always true?
  "booking_endpoint": "/api/android/recharge/booking/",  // <-- Always present?
  "request_endpoint": "/api/android/recharge/request/"   // <-- Always present?
}
```

**Question**: 
- If buttons are not configured in web admin, should API return `false` for these flags?
- Or should API return `false` only if endpoint is empty/null?
- What is the canonical way to know if a button should be shown?

**Current Android Logic**: Shows button only if `flag == true` AND `endpoint.isNotEmpty`
**Is this correct?** Or should backend return `false` when button is not configured?

---

## Recommendation for Backend

If backend team prefers, we can implement **Option B** (frontend handles skip logic) with these requirements:

### Required Response Format

**When operator check is enabled**:
```json
{
  "has_active_operator_check_api": true,
  "field_config": {
    "field_name": "mobile",  // Must match operator form config field name
    ...
  }
}
```

**Operator form config should still return mobile field**, but frontend will skip it if:
1. Operator check is enabled
2. Field name matches operator check field name

This is what we're currently trying to implement.

---

## Summary of Questions

1. ✅ Should operator form config exclude mobile when operator check enabled? (We prefer: NO - keep it, we'll skip)
2. ✅ Are field names consistent? (`mobile` vs `MobileNumber` etc.) (We need: YES - consistent naming)
3. ✅ Should `show_after_operator_fetch` control visibility? (We prefer: Yes, but mobile should be skipped regardless)
4. ✅ Remove hardcoded amount field? (We prefer: YES - no hardcoded fields)
5. ✅ When should booking/request buttons show? (We need: Clarification on when flags are false)

---

## Test Case

**Steps to reproduce**:
1. Enable operator check for operator type (e.g., Prepaid)
2. Configure operator form config with `mobile` field
3. Open recharge page
4. Enter mobile in operator check field
5. Operator auto-fetched
6. **Result**: Two mobile fields visible ❌
7. **Expected**: One mobile field (from operator check) ✅

**Request**: Please confirm the expected API response format for this scenario.
