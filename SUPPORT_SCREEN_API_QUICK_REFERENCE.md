# Support Screen API - Quick Reference

## API Endpoint
```
GET /api/android/support/
```

**Authentication:** Required (Bearer Token)

---

## Required Data Fields

### 1. Customer Care
- Mobile number
- Phone number (landline)
- WhatsApp number

### 2. Accounts & Finance
- Mobile number
- Phone number (landline)
- WhatsApp number

### 3. Social Media Links
- Facebook URL
- Instagram URL
- Twitter/X URL
- Each with enabled/disabled flag

### 4. Website
- Website URL
- Enabled flag

### 5. Address
- Full company address (text)

### 6. Toll-Free Numbers
- Mobile toll-free: Array of {operator_name, phone_number}
- DTH toll-free: Array of {operator_name, phone_number}

### 7. Bank Details
- Bank name
- Account holder name
- Account number
- IFSC code
- Branch name
- Branch address

### 8. Legal Documents
- Privacy Policy URL
- Terms & Conditions URL
- Each with enabled flag

---

## Sample Response Structure

```json
{
  "success": true,
  "data": {
    "customer_care": {
      "mobile": "9037187402",
      "phone": "9037187402",
      "whatsapp": "9037187402"
    },
    "accounts_finance": {
      "mobile": "9037187402",
      "phone": "9037187402",
      "whatsapp": "9037187402"
    },
    "social_media": {
      "facebook": {"url": "https://facebook.com/page", "enabled": true},
      "instagram": {"url": "https://instagram.com/page", "enabled": true},
      "twitter_x": {"url": "https://twitter.com/page", "enabled": true}
    },
    "website": {"url": "https://website.com", "enabled": true},
    "address": {"full_address": "123 Street, City, State", "enabled": true},
    "toll_free": {
      "mobile": [{"operator_name": "BSNL", "phone_number": "1503", "enabled": true}],
      "dth": [{"operator_name": "Dish TV", "phone_number": "1800-2700-300", "enabled": true}]
    },
    "bank_details": {
      "bank_name": "Bank Name",
      "account_holder_name": "Company Name",
      "account_number": "1234567890",
      "ifsc_code": "BANK0001234",
      "branch": "Main Branch",
      "branch_address": "123 Bank St",
      "enabled": true
    },
    "legal": {
      "privacy_policy": {"url": "https://website.com/privacy", "enabled": true},
      "terms_conditions": {"url": "https://website.com/terms", "enabled": true}
    }
  }
}
```

---

## Key Points

1. **Single API Endpoint:** All support data in one response
2. **Enabled Flags:** Use to show/hide sections dynamically
3. **Arrays for Toll-Free:** Support multiple operators
4. **Optional Fields:** All fields can be optional/null
5. **URLs:** Must be complete URLs (http:// or https://)
6. **Phone Numbers:** Can include dashes or be plain numbers

---

**See `SUPPORT_SCREEN_API_REQUIREMENTS.md` for complete documentation.**

