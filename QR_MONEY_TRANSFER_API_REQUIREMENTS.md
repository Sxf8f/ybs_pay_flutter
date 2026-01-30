# QR Code Money Transfer - API Requirements

## Overview
This document outlines the APIs needed to implement peer-to-peer money transfer using QR codes. Users can generate their own QR code and scan other users' QR codes to send money directly from their wallet.

---

## Required APIs

### 1. **Generate User QR Code**
**Purpose:** Generate a unique QR code for each user that contains their payment information.

**Endpoint:** `GET /api/android/wallet/generate-qr/`

**Authentication:** Required (Bearer Token)

**Request:** No body required (uses authenticated user's token)

**Response:**
```json
{
  "success": true,
  "qr_data": "YBS_PAY|USER_ID|12345|WALLET_ID|67890",
  "qr_image_url": "https://api.example.com/media/qr_codes/user_12345_qr.png",
  "user_id": 12345,
  "user_name": "John Doe",
  "user_phone": "9876543210",
  "message": "QR code generated successfully"
}
```

**QR Data Format:**
- Format: `YBS_PAY|USER_ID|{user_id}|WALLET_ID|{wallet_id}`
- Example: `YBS_PAY|USER_ID|12345|WALLET_ID|67890`
- This allows the app to identify the recipient when scanned

**Notes:**
- QR code should be unique per user
- QR image can be generated server-side or client-side (if server provides `qr_data`, Flutter can generate image)
- Include user display name/phone for verification

---

### 2. **Validate QR Code / Get Recipient Info**
**Purpose:** When a user scans a QR code, validate it and fetch recipient information before showing the amount input screen.

**Endpoint:** `POST /api/android/wallet/validate-qr/`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "qr_data": "YBS_PAY|USER_ID|12345|WALLET_ID|67890"
}
```

**Response (Success):**
```json
{
  "success": true,
  "valid": true,
  "recipient": {
    "user_id": 12345,
    "user_name": "John Doe",
    "phone": "9876543210",
    "wallet_id": 67890,
    "is_active": true,
    "can_receive": true
  },
  "message": "QR code is valid"
}
```

**Response (Invalid QR):**
```json
{
  "success": false,
  "valid": false,
  "error": "Invalid QR code format",
  "message": "The scanned QR code is not valid for this app"
}
```

**Response (User Not Found):**
```json
{
  "success": false,
  "valid": false,
  "error": "User not found",
  "message": "The recipient user does not exist or is inactive"
}
```

**Response (Self Transfer Prevention):**
```json
{
  "success": false,
  "valid": false,
  "error": "Cannot transfer to self",
  "message": "You cannot send money to yourself"
}
```

**Notes:**
- Validate QR format matches `YBS_PAY|USER_ID|{id}|WALLET_ID|{id}`
- Check if recipient user exists and is active
- Prevent users from sending to themselves
- Return user-friendly recipient info for display

---

### 3. **Transfer Money (P2P)**
**Purpose:** Transfer money from sender's wallet to recipient's wallet.

**Endpoint:** `POST /api/android/wallet/transfer-money/`

**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "recipient_user_id": 12345,
  "amount": "500.00",
  "remarks": "Payment for services",
  "qr_data": "YBS_PAY|USER_ID|12345|WALLET_ID|67890"
}
```

**Response (Success):**
```json
{
  "success": true,
  "transaction_id": "TXN123456789",
  "sender": {
    "user_id": 67890,
    "user_name": "Jane Smith",
    "old_balance": "1000.00",
    "new_balance": "500.00"
  },
  "recipient": {
    "user_id": 12345,
    "user_name": "John Doe",
    "old_balance": "200.00",
    "new_balance": "700.00"
  },
  "amount": "500.00",
  "status": "SUCCESS",
  "transaction_type": "P2P_TRANSFER",
  "created_at": "2025-12-17T10:30:00Z",
  "message": "Money transferred successfully"
}
```

**Response (Insufficient Balance):**
```json
{
  "success": false,
  "error": "Insufficient balance",
  "message": "Your wallet balance is insufficient for this transaction",
  "current_balance": "100.00",
  "required_amount": "500.00"
}
```

**Response (Invalid Recipient):**
```json
{
  "success": false,
  "error": "Invalid recipient",
  "message": "The recipient user is inactive or does not exist"
}
```

**Response (Minimum Amount):**
```json
{
  "success": false,
  "error": "Amount too low",
  "message": "Minimum transfer amount is ₹10.00"
}
```

**Response (Maximum Amount):**
```json
{
  "success": false,
  "error": "Amount too high",
  "message": "Maximum transfer amount per transaction is ₹50,000.00"
}
```

**Notes:**
- Validate sender has sufficient balance
- Validate recipient exists and is active
- Validate amount is within min/max limits
- Create transaction record for both sender and recipient
- Update both wallets atomically (use database transaction)
- Return transaction ID for tracking

---

### 4. **Get Transfer History (P2P Transactions)**
**Purpose:** Get history of peer-to-peer transfers (sent and received).

**Endpoint:** `GET /api/android/wallet/transfer-history/`

**Authentication:** Required (Bearer Token)

**Query Parameters:**
- `type` (optional): `sent` | `received` | `all` (default: `all`)
- `start_date` (optional): `YYYY-MM-DD`
- `end_date` (optional): `YYYY-MM-DD`
- `limit` (optional): `10` | `20` | `50` | `100` (default: `20`)
- `offset` (optional): For pagination (default: `0`)

**Response:**
```json
{
  "success": true,
  "transactions": [
    {
      "transaction_id": "TXN123456789",
      "type": "sent",  // or "received"
      "amount": "500.00",
      "recipient": {
        "user_id": 12345,
        "user_name": "John Doe",
        "phone": "9876543210"
      },
      "sender": {
        "user_id": 67890,
        "user_name": "Jane Smith",
        "phone": "9876543211"
      },
      "status": "SUCCESS",
      "remarks": "Payment for services",
      "created_at": "2025-12-17T10:30:00Z"
    },
    {
      "transaction_id": "TXN987654321",
      "type": "received",
      "amount": "1000.00",
      "recipient": {
        "user_id": 67890,
        "user_name": "Jane Smith",
        "phone": "9876543211"
      },
      "sender": {
        "user_id": 11111,
        "user_name": "Alice Johnson",
        "phone": "9876543212"
      },
      "status": "SUCCESS",
      "remarks": "Refund",
      "created_at": "2025-12-16T15:20:00Z"
    }
  ],
  "total_count": 25,
  "sent_total": "2500.00",
  "received_total": "3000.00"
}
```

**Notes:**
- Show both sent and received transfers
- Include sender/recipient details
- Support pagination
- Filter by date range
- Calculate totals for sent/received

---

## Implementation Flow

### **Flow 1: Generate My QR Code**
1. User opens "My QR Code" screen (can be in Profile or Home)
2. App calls `GET /api/android/wallet/generate-qr/`
3. Display QR code image and allow sharing
4. QR code contains: `YBS_PAY|USER_ID|{id}|WALLET_ID|{id}`

### **Flow 2: Scan & Send Money**
1. User taps "Scan & Pay" button
2. Camera opens, scans QR code
3. App extracts QR data string
4. App calls `POST /api/android/wallet/validate-qr/` with scanned data
5. If valid, show recipient info (name, phone) and amount input screen
6. User enters amount and optional remarks
7. App calls `POST /api/android/wallet/transfer-money/`
8. On success, show confirmation and update wallet balance
9. Navigate back to home screen

### **Flow 3: View Transfer History**
1. User opens "Transfer History" (can be in Wallet/Reports section)
2. App calls `GET /api/android/wallet/transfer-history/`
3. Display list of sent/received transfers
4. Support filtering and pagination

---

## Error Handling

### Common Error Scenarios:
1. **Invalid QR Format** - QR code doesn't match expected format
2. **User Not Found** - Recipient user doesn't exist
3. **Inactive User** - Recipient account is inactive
4. **Self Transfer** - User tries to send to themselves
5. **Insufficient Balance** - Sender doesn't have enough balance
6. **Amount Limits** - Amount below minimum or above maximum
7. **Network Errors** - Handle offline/connection issues
8. **Server Errors** - Handle 500 errors gracefully

---

## Security Considerations

1. **QR Code Validation:**
   - Always validate QR format before processing
   - Verify recipient exists and is active
   - Prevent self-transfers

2. **Amount Validation:**
   - Enforce minimum/maximum transfer limits
   - Check sender balance before processing
   - Validate amount format (positive numbers only)

3. **Transaction Security:**
   - Use database transactions for atomic wallet updates
   - Generate unique transaction IDs
   - Log all transfer attempts (success and failure)
   - Implement rate limiting to prevent abuse

4. **Authentication:**
   - All endpoints require valid JWT token
   - Verify token hasn't expired
   - Check user permissions (if needed)

---

## Database Schema Suggestions

### **wallet_transfers** table:
```sql
- id (Primary Key)
- transaction_id (Unique, indexed)
- sender_user_id (Foreign Key)
- recipient_user_id (Foreign Key)
- amount (Decimal)
- status (SUCCESS, FAILED, PENDING)
- remarks (Text, nullable)
- qr_data (Text, nullable)
- created_at (Timestamp)
- updated_at (Timestamp)
```

### **Indexes:**
- `transaction_id` (unique)
- `sender_user_id` + `created_at` (for sent history)
- `recipient_user_id` + `created_at` (for received history)

---

## Testing Checklist

- [ ] Generate QR code for authenticated user
- [ ] Validate valid QR code
- [ ] Validate invalid QR code format
- [ ] Validate non-existent user QR
- [ ] Prevent self-transfer
- [ ] Transfer money successfully
- [ ] Handle insufficient balance
- [ ] Handle amount limits (min/max)
- [ ] Handle inactive recipient
- [ ] View transfer history (sent/received)
- [ ] Pagination works correctly
- [ ] Date filtering works
- [ ] Wallet balance updates correctly after transfer
- [ ] Transaction appears in wallet history

---

## Additional Features (Optional)

1. **Transfer Limits:**
   - Daily transfer limit per user
   - Monthly transfer limit per user
   - Per-transaction limits

2. **Notifications:**
   - Send notification to recipient when money is received
   - Send notification to sender on successful transfer

3. **QR Code Sharing:**
   - Allow users to share QR code via WhatsApp/SMS
   - Generate QR code image for download

4. **Transfer Requests:**
   - Allow users to request money (reverse flow)
   - Generate request QR codes

---

## Questions for Backend Team

1. What is the minimum transfer amount?
2. What is the maximum transfer amount per transaction?
3. Are there daily/monthly transfer limits?
4. Should we support transfer requests (request money from others)?
5. Do we need to charge any fees for P2P transfers?
6. Should transfers be instant or can they be pending?
7. Do we need to support transfer cancellation/refund?

---

This document provides a complete API specification for implementing QR code-based money transfer. Once these APIs are implemented, the Flutter app can be updated to use them.

