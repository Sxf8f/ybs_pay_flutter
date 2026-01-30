# Popup Message System - API Requirements

## Overview
This document outlines the API requirements for implementing a customizable popup message system that displays when the app opens. The system supports two types of popups: "every_time" (displays until admin turns it off) and "one_time" (displays only once per user).

---

## Table of Contents
1. [Get Popup API](#1-get-popup-api)
2. [Mark Popup as Seen API](#2-mark-popup-as-seen-api)
3. [Database Schema](#3-database-schema)
4. [Implementation Flow](#4-implementation-flow)

---

## 1. Get Popup API

### Purpose
Check if there's an active popup to display when the app opens. This API should handle the logic for determining which popup to show based on type and user history.

### Endpoint
```
GET /api/android/popup/check/
```

### Authentication
**Required:** Bearer Token (JWT)

### Headers
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Request
No body required. Uses authenticated user's token to identify the user.

### Response (Success - 200 OK)

#### Case 1: Popup Available
```json
{
  "success": true,
  "has_popup": true,
  "popup": {
    "id": 1,
    "type": "every_time",
    "title": "Welcome to YBS Pay!",
    "content": "We have exciting new features. Check them out!",
    "image_url": "https://api.example.com/media/popups/welcome_image.png",
    "background_image_url": "https://api.example.com/media/popups/welcome_bg.png",
    "background_color": "#FFFFFF",
    "text_color": "#000000",
    "title_color": "#1A1A1A",
    "button_text": "Got it!",
    "button_color": "#007AFF",
    "button_text_color": "#FFFFFF",
    "button_border_radius": 8,
    "is_active": true,
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": "2025-12-31T23:59:59Z",
    "priority": 1,
    "created_at": "2025-01-01T10:00:00Z",
    "updated_at": "2025-01-01T10:00:00Z"
  }
}
```

#### Case 2: No Popup Available
```json
{
  "success": true,
  "has_popup": false,
  "popup": null,
  "message": "No active popup to display"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Indicates if the request was successful |
| `has_popup` | boolean | Whether there's a popup to display |
| `popup` | object\|null | Popup data if available |
| `popup.id` | integer | Unique popup ID |
| `popup.type` | string | Popup type: `"every_time"` or `"one_time"` |
| `popup.title` | string | Popup title/heading |
| `popup.content` | string | Popup message content (supports HTML if needed) |
| `popup.image_url` | string\|null | URL to popup image (optional) |
| `popup.background_image_url` | string\|null | URL to background image (optional) |
| `popup.background_color` | string | Background color in hex format (e.g., "#FFFFFF") |
| `popup.text_color` | string | Text color in hex format |
| `popup.title_color` | string | Title color in hex format |
| `popup.button_text` | string | Text for the action button |
| `popup.button_color` | string | Button background color in hex format |
| `popup.button_text_color` | string | Button text color in hex format |
| `popup.button_border_radius` | integer | Button border radius in pixels |
| `popup.is_active` | boolean | Whether popup is currently active |
| `popup.start_date` | string (ISO 8601) | Start date/time for popup display |
| `popup.end_date` | string (ISO 8601)\|null | End date/time for popup display (null = no end date) |
| `popup.priority` | integer | Priority level (higher = shown first if multiple popups) |
| `popup.created_at` | string (ISO 8601) | Creation timestamp |
| `popup.updated_at` | string (ISO 8601) | Last update timestamp |

### Popup Type Logic

#### Type: `"every_time"`
- Display every time the app opens
- Continue displaying until `is_active` is set to `false` by admin
- No need to track user viewing history

#### Type: `"one_time"`
- Display only once per user
- Backend should check if user has already seen this popup
- If user has seen it, don't return it in the response
- Requires tracking in `UserPopupHistory` table (see Database Schema)

### Date Range Logic
- Popup should only be returned if current date/time is between `start_date` and `end_date`
- If `end_date` is `null`, popup has no expiration
- If current time is before `start_date` or after `end_date`, don't return popup

### Priority Logic
- If multiple popups are available, return the one with highest `priority`
- If priorities are equal, return the most recently created one

### Error Responses

#### 401 Unauthorized
```json
{
  "success": false,
  "has_popup": false,
  "error": "Authentication required"
}
```

#### 500 Internal Server Error
```json
{
  "success": false,
  "has_popup": false,
  "error": "Failed to fetch popup: <error_message>"
}
```

### cURL Example
```bash
curl -X GET "https://api.example.com/api/android/popup/check/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

---

## 2. Mark Popup as Seen API

### Purpose
Mark a popup as "seen" by the user. This is required for `"one_time"` type popups to prevent them from showing again.

### Endpoint
```
POST /api/android/popup/mark-seen/
```

### Authentication
**Required:** Bearer Token (JWT)

### Headers
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Request Body
```json
{
  "popup_id": 1
}
```

### Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `popup_id` | integer | Yes | ID of the popup that was viewed |

### Response (Success - 200 OK)
```json
{
  "success": true,
  "message": "Popup marked as seen",
  "popup_id": 1,
  "user_id": 12345,
  "viewed_at": "2025-01-15T10:30:00Z"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Indicates if the request was successful |
| `message` | string | Success message |
| `popup_id` | integer | ID of the popup that was marked as seen |
| `user_id` | integer | ID of the user who viewed the popup |
| `viewed_at` | string (ISO 8601) | Timestamp when popup was viewed |

### Error Responses

#### 400 Bad Request - Missing Popup ID
```json
{
  "success": false,
  "error": "Popup ID is required"
}
```

#### 400 Bad Request - Invalid Popup ID
```json
{
  "success": false,
  "error": "Invalid popup ID"
}
```

#### 400 Bad Request - Popup Already Seen
```json
{
  "success": false,
  "error": "Popup already marked as seen",
  "viewed_at": "2025-01-10T08:00:00Z"
}
```

#### 401 Unauthorized
```json
{
  "success": false,
  "error": "Authentication required"
}
```

#### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Failed to mark popup as seen: <error_message>"
}
```

### Notes
- If popup is already marked as seen, return success (idempotent operation)
- This API is called automatically by the Flutter app when user closes/dismisses a `"one_time"` popup
- For `"every_time"` popups, this API is optional (can be called for analytics)

### cURL Example
```bash
curl -X POST "https://api.example.com/api/android/popup/mark-seen/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "popup_id": 1
  }'
```

---

## 3. Database Schema

### Popup Table
```sql
CREATE TABLE popup (
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (type IN ('every_time', 'one_time')),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    background_image_url VARCHAR(500),
    background_color VARCHAR(7) DEFAULT '#FFFFFF',
    text_color VARCHAR(7) DEFAULT '#000000',
    title_color VARCHAR(7) DEFAULT '#1A1A1A',
    button_text VARCHAR(50) DEFAULT 'OK',
    button_color VARCHAR(7) DEFAULT '#007AFF',
    button_text_color VARCHAR(7) DEFAULT '#FFFFFF',
    button_border_radius INTEGER DEFAULT 8,
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_popup_active ON popup(is_active, start_date, end_date);
CREATE INDEX idx_popup_priority ON popup(priority DESC);
```

### UserPopupHistory Table
```sql
CREATE TABLE user_popup_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES custom_user(id) ON DELETE CASCADE,
    popup_id INTEGER NOT NULL REFERENCES popup(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, popup_id)
);

CREATE INDEX idx_user_popup_history_user ON user_popup_history(user_id);
CREATE INDEX idx_user_popup_history_popup ON user_popup_history(popup_id);
```

### Notes
- `user_popup_history` table tracks which users have seen which `"one_time"` popups
- Unique constraint on `(user_id, popup_id)` prevents duplicate entries
- When checking for popups, exclude popups that exist in `user_popup_history` for the current user

---

## 4. Implementation Flow

### Flutter App Flow

1. **App Opens** → Splash screen loads
2. **After Authentication** → Call `GET /api/android/popup/check/`
3. **If `has_popup: true`**:
   - Display popup with custom styling
   - User clicks button/closes popup
   - If `popup.type == "one_time"`:
     - Call `POST /api/android/popup/mark-seen/` with `popup_id`
   - Continue to home screen
4. **If `has_popup: false`**:
   - Continue directly to home screen

### Backend Flow for Get Popup API

1. Authenticate user from JWT token
2. Query active popups:
   ```sql
   SELECT * FROM popup 
   WHERE is_active = TRUE 
     AND (start_date IS NULL OR start_date <= NOW())
     AND (end_date IS NULL OR end_date >= NOW())
   ORDER BY priority DESC, created_at DESC
   LIMIT 1
   ```
3. For each popup found:
   - If `type == "one_time"`:
     - Check if `(user_id, popup_id)` exists in `user_popup_history`
     - If exists, skip this popup
     - If not exists, return this popup
   - If `type == "every_time"`:
     - Return this popup immediately
4. Return the first matching popup (highest priority)
5. If no popup found, return `has_popup: false`

### Backend Flow for Mark Seen API

1. Authenticate user from JWT token
2. Validate `popup_id` exists and is valid
3. Check if `(user_id, popup_id)` already exists in `user_popup_history`
4. If not exists:
   - Insert into `user_popup_history`
5. Return success response

---

## 5. Additional Considerations

### Admin Panel Requirements
- Create/Edit/Delete popups
- Toggle `is_active` to enable/disable popups
- Set `start_date` and `end_date` for scheduled popups
- Set `priority` to control which popup shows first
- Preview popup appearance
- View statistics: how many users have seen each popup

### Analytics (Optional)
- Track popup views (for both types)
- Track popup dismissals
- Track button clicks
- Track time spent viewing popup

### Multiple Popups
- If multiple popups are active, show them one at a time
- Show highest priority first
- After user dismisses one, check for next popup
- Continue until all popups are shown or dismissed

### Image Handling
- Store images in Django media folder or cloud storage (S3, etc.)
- Return full URLs in API response
- Support common image formats: PNG, JPG, JPEG, WebP
- Recommended max image size: 2MB

### Content Formatting
- Support plain text content
- Optionally support HTML/Markdown for rich formatting
- Support line breaks (`\n` or `<br>`)

### Button Actions (Future Enhancement)
- Currently: Single button that dismisses popup
- Future: Support multiple buttons with different actions
  - "Learn More" → Navigate to specific screen
  - "Dismiss" → Close popup
  - "Don't Show Again" → Mark as seen and disable

---

## 6. Example API Responses

### Example 1: Every Time Popup
```json
{
  "success": true,
  "has_popup": true,
  "popup": {
    "id": 1,
    "type": "every_time",
    "title": "New Feature Available!",
    "content": "Check out our new payment options.",
    "image_url": "https://api.example.com/media/popups/feature.png",
    "background_image_url": null,
    "background_color": "#F0F8FF",
    "text_color": "#333333",
    "title_color": "#1A1A1A",
    "button_text": "Explore",
    "button_color": "#007AFF",
    "button_text_color": "#FFFFFF",
    "button_border_radius": 12,
    "is_active": true,
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": null,
    "priority": 5,
    "created_at": "2025-01-01T10:00:00Z",
    "updated_at": "2025-01-01T10:00:00Z"
  }
}
```

### Example 2: One Time Popup
```json
{
  "success": true,
  "has_popup": true,
  "popup": {
    "id": 2,
    "type": "one_time",
    "title": "Welcome!",
    "content": "Thanks for joining YBS Pay. Here's what you need to know.",
    "image_url": "https://api.example.com/media/popups/welcome.png",
    "background_image_url": "https://api.example.com/media/popups/welcome_bg.jpg",
    "background_color": "#FFFFFF",
    "text_color": "#000000",
    "title_color": "#1A1A1A",
    "button_text": "Get Started",
    "button_color": "#28A745",
    "button_text_color": "#FFFFFF",
    "button_border_radius": 8,
    "is_active": true,
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": "2025-12-31T23:59:59Z",
    "priority": 10,
    "created_at": "2025-01-01T08:00:00Z",
    "updated_at": "2025-01-01T08:00:00Z"
  }
}
```

### Example 3: No Popup
```json
{
  "success": true,
  "has_popup": false,
  "popup": null,
  "message": "No active popup to display"
}
```

---

## 7. Testing Checklist

- [ ] Get popup API returns active popup when available
- [ ] Get popup API returns `has_popup: false` when no popup
- [ ] `every_time` popup shows every app launch
- [ ] `one_time` popup shows only once per user
- [ ] `one_time` popup doesn't show after being marked as seen
- [ ] Date range filtering works (start_date, end_date)
- [ ] Priority ordering works correctly
- [ ] Mark seen API prevents popup from showing again
- [ ] Multiple popups show in priority order
- [ ] Inactive popups don't show
- [ ] Expired popups don't show
- [ ] Authentication required for both APIs
- [ ] Error handling works correctly

---

## Support

For questions or clarifications regarding these APIs, please contact the backend development team.

---

**Last Updated:** January 2025

