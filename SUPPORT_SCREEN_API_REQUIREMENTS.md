# Support Screen API Requirements

## Overview
This document outlines the API requirements for the Support/Contact Us screen in the Android app. The screen displays various contact information, social media links, and support details that need to be fetched from the backend.

---

## API Endpoint

### Get Support Information
**Endpoint:** `GET /api/android/support/`

**Authentication:** Required (Bearer Token - JWT)

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## Response Format

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
      "facebook": {
        "url": "https://www.facebook.com/yourpage",
        "enabled": true
      },
      "instagram": {
        "url": "https://www.instagram.com/yourpage",
        "enabled": true
      },
      "twitter_x": {
        "url": "https://twitter.com/yourpage",
        "enabled": true
      }
    },
    "website": {
      "url": "https://www.yourwebsite.com",
      "enabled": true
    },
    "address": {
      "full_address": "123 Main Street, City, State, PIN Code, Country",
      "enabled": true
    },
    "toll_free": {
      "mobile": [
        {
          "operator_name": "BSNL- Special Tariff",
          "phone_number": "1503",
          "enabled": true
        },
        {
          "operator_name": "Airtel",
          "phone_number": "198",
          "enabled": true
        }
      ],
      "dth": [
        {
          "operator_name": "Dish TV",
          "phone_number": "1800-2700-300",
          "enabled": true
        },
        {
          "operator_name": "Tata Sky",
          "phone_number": "1800-208-6633",
          "enabled": true
        }
      ]
    },
    "bank_details": {
      "bank_name": "Your Bank Name",
      "account_holder_name": "Your Company Name",
      "account_number": "1234567890",
      "ifsc_code": "BANK0001234",
      "branch": "Main Branch",
      "branch_address": "123 Bank Street, City",
      "enabled": true
    },
    "legal": {
      "privacy_policy": {
        "url": "https://www.yourwebsite.com/privacy-policy",
        "enabled": true
      },
      "terms_conditions": {
        "url": "https://www.yourwebsite.com/terms-conditions",
        "enabled": true
      }
    }
  },
  "message": "Support information retrieved successfully"
}
```

---

## Response Fields

### Root Level
| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Indicates if the request was successful |
| `data` | object | Support information data |
| `message` | string | Success message |

### Customer Care (`data.customer_care`)
| Field | Type | Description |
|-------|------|-------------|
| `mobile` | string | Mobile number for customer care |
| `phone` | string | Landline/phone number for customer care |
| `whatsapp` | string | WhatsApp number for customer care |

### Accounts & Finance (`data.accounts_finance`)
| Field | Type | Description |
|-------|------|-------------|
| `mobile` | string | Mobile number for accounts & finance |
| `phone` | string | Landline/phone number for accounts & finance |
| `whatsapp` | string | WhatsApp number for accounts & finance |

### Social Media (`data.social_media`)
| Field | Type | Description |
|-------|------|-------------|
| `facebook` | object | Facebook page information |
| `facebook.url` | string | Facebook page URL |
| `facebook.enabled` | boolean | Whether Facebook link is enabled |
| `instagram` | object | Instagram page information |
| `instagram.url` | string | Instagram profile URL |
| `instagram.enabled` | boolean | Whether Instagram link is enabled |
| `twitter_x` | object | Twitter/X page information |
| `twitter_x.url` | string | Twitter/X profile URL |
| `twitter_x.enabled` | boolean | Whether Twitter/X link is enabled |

### Website (`data.website`)
| Field | Type | Description |
|-------|------|-------------|
| `url` | string | Company website URL |
| `enabled` | boolean | Whether website link is enabled |

### Address (`data.address`)
| Field | Type | Description |
|-------|------|-------------|
| `full_address` | string | Complete company address |
| `enabled` | boolean | Whether address section is enabled |

### Toll Free (`data.toll_free`)
| Field | Type | Description |
|-------|------|-------------|
| `mobile` | array | List of mobile toll-free numbers |
| `mobile[].operator_name` | string | Operator/service name |
| `mobile[].phone_number` | string | Toll-free phone number |
| `mobile[].enabled` | boolean | Whether this toll-free number is enabled |
| `dth` | array | List of DTH toll-free numbers |
| `dth[].operator_name` | string | DTH operator name |
| `dth[].phone_number` | string | Toll-free phone number |
| `dth[].enabled` | boolean | Whether this toll-free number is enabled |

### Bank Details (`data.bank_details`)
| Field | Type | Description |
|-------|------|-------------|
| `bank_name` | string | Bank name |
| `account_holder_name` | string | Account holder name |
| `account_number` | string | Bank account number |
| `ifsc_code` | string | IFSC code |
| `branch` | string | Branch name |
| `branch_address` | string | Branch address |
| `enabled` | boolean | Whether bank details section is enabled |

### Legal (`data.legal`)
| Field | Type | Description |
|-------|------|-------------|
| `privacy_policy` | object | Privacy policy information |
| `privacy_policy.url` | string | Privacy policy URL |
| `privacy_policy.enabled` | boolean | Whether privacy policy link is enabled |
| `terms_conditions` | object | Terms & conditions information |
| `terms_conditions.url` | string | Terms & conditions URL |
| `terms_conditions.enabled` | boolean | Whether terms & conditions link is enabled |

---

## Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Authentication required"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Failed to fetch support information: <error_message>"
}
```

---

## Implementation Notes

### Phone Number Format
- Phone numbers should be stored as strings
- Format: Can include dashes (e.g., "1800-2700-300") or plain numbers (e.g., "9037187402")
- WhatsApp numbers should be in international format if needed (e.g., "919037187402")

### URL Format
- All URLs should be complete URLs starting with `http://` or `https://`
- Social media URLs should be full profile/page URLs
- Website URL should be the main company website

### Enabled Flags
- Use `enabled` flags to show/hide sections dynamically
- If `enabled: false`, the Flutter app should hide that section
- This allows admins to enable/disable features without app updates

### Toll-Free Numbers
- Multiple operators can be supported
- The Flutter app will show a dialog with the operator name and phone number
- Users can tap the phone number to call directly

### Bank Details
- Bank details can be displayed in a dialog or separate screen when user taps "Bank Details"
- All fields are optional - show only if provided

### Address
- Full address should be a single string
- Can include multiple lines separated by commas or newlines
- The Flutter app will format it appropriately

---

## Database Schema Suggestions

### SupportSettings Model
```python
class SupportSettings(models.Model):
    # Customer Care
    customer_care_mobile = models.CharField(max_length=20, blank=True)
    customer_care_phone = models.CharField(max_length=20, blank=True)
    customer_care_whatsapp = models.CharField(max_length=20, blank=True)
    
    # Accounts & Finance
    accounts_mobile = models.CharField(max_length=20, blank=True)
    accounts_phone = models.CharField(max_length=20, blank=True)
    accounts_whatsapp = models.CharField(max_length=20, blank=True)
    
    # Social Media
    facebook_url = models.URLField(blank=True)
    facebook_enabled = models.BooleanField(default=True)
    instagram_url = models.URLField(blank=True)
    instagram_enabled = models.BooleanField(default=True)
    twitter_x_url = models.URLField(blank=True)
    twitter_x_enabled = models.BooleanField(default=True)
    
    # Website
    website_url = models.URLField(blank=True)
    website_enabled = models.BooleanField(default=True)
    
    # Address
    full_address = models.TextField(blank=True)
    address_enabled = models.BooleanField(default=True)
    
    # Bank Details
    bank_name = models.CharField(max_length=200, blank=True)
    account_holder_name = models.CharField(max_length=200, blank=True)
    account_number = models.CharField(max_length=50, blank=True)
    ifsc_code = models.CharField(max_length=20, blank=True)
    branch = models.CharField(max_length=200, blank=True)
    branch_address = models.TextField(blank=True)
    bank_details_enabled = models.BooleanField(default=True)
    
    # Legal
    privacy_policy_url = models.URLField(blank=True)
    privacy_policy_enabled = models.BooleanField(default=True)
    terms_conditions_url = models.URLField(blank=True)
    terms_conditions_enabled = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = "Support Settings"
```

### TollFreeNumber Model
```python
class TollFreeNumber(models.Model):
    TYPE_CHOICES = [
        ('mobile', 'Mobile'),
        ('dth', 'DTH'),
    ]
    
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    operator_name = models.CharField(max_length=200)
    phone_number = models.CharField(max_length=20)
    enabled = models.BooleanField(default=True)
    display_order = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['display_order', 'operator_name']
```

---

## cURL Example

```bash
curl -X GET "https://api.example.com/api/android/support/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

---

## Flutter Implementation Notes

### Data Model Structure
The Flutter app will create models for:
- `SupportInfo` - Main response model
- `ContactInfo` - For customer care and accounts finance
- `SocialMediaInfo` - For social media links
- `TollFreeInfo` - For toll-free numbers
- `BankDetails` - For bank information
- `LegalInfo` - For privacy policy and terms

### Usage
1. Call API on screen load
2. Display data in respective widgets
3. Handle enabled flags to show/hide sections
4. Implement click handlers for:
   - Phone numbers → Open dialer
   - WhatsApp → Open WhatsApp with number
   - URLs → Open in browser
   - Bank Details → Show dialog with details

---

## Testing Checklist

- [ ] Returns all support information correctly
- [ ] Handles missing optional fields gracefully
- [ ] Respects `enabled` flags
- [ ] Returns 401 for invalid/expired token
- [ ] Handles empty toll-free arrays
- [ ] Handles null/empty optional fields
- [ ] URL validation works correctly
- [ ] Phone number format is correct

---

## Additional Notes

1. **Caching:** Consider caching support information for 1 hour to reduce API calls
2. **Admin Panel:** Create an admin interface to manage support settings
3. **Versioning:** Consider adding version field if support info changes frequently
4. **Localization:** If supporting multiple languages, add language-specific fields

---

**Last Updated:** December 2025

