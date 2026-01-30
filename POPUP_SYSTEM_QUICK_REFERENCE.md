# Popup System - Quick Reference for Backend Team

## Overview
Implement a popup message system that displays customizable popups when the app opens.

---

## Required APIs

### 1. Check Popup API
**Endpoint:** `GET /api/android/popup/check/`  
**Auth:** Required (JWT Bearer Token)

**Response when popup available:**
```json
{
  "success": true,
  "has_popup": true,
  "popup": {
    "id": 1,
    "type": "every_time",  // or "one_time"
    "title": "Welcome!",
    "content": "Message content here",
    "image_url": "https://...",
    "background_image_url": "https://...",
    "background_color": "#FFFFFF",
    "text_color": "#000000",
    "title_color": "#1A1A1A",
    "button_text": "OK",
    "button_color": "#007AFF",
    "button_text_color": "#FFFFFF",
    "button_border_radius": 8,
    "is_active": true,
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": "2025-12-31T23:59:59Z",
    "priority": 1
  }
}
```

**Response when no popup:**
```json
{
  "success": true,
  "has_popup": false,
  "popup": null
}
```

### 2. Mark Popup as Seen API
**Endpoint:** `POST /api/android/popup/mark-seen/`  
**Auth:** Required (JWT Bearer Token)

**Request:**
```json
{
  "popup_id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Popup marked as seen",
  "popup_id": 1,
  "user_id": 12345,
  "viewed_at": "2025-01-15T10:30:00Z"
}
```

---

## Popup Types

### Type: `"every_time"`
- Shows every time app opens
- Continues until admin sets `is_active = false`
- No user tracking needed

### Type: `"one_time"`
- Shows only once per user
- Backend must check `user_popup_history` table
- If user has seen it, don't return it
- Call "Mark Seen" API when user views it

---

## Database Tables Needed

### `popup` Table
- `id`, `type`, `title`, `content`
- `image_url`, `background_image_url`
- `background_color`, `text_color`, `title_color`
- `button_text`, `button_color`, `button_text_color`, `button_border_radius`
- `is_active`, `start_date`, `end_date`, `priority`
- `created_at`, `updated_at`

### `user_popup_history` Table
- `id`, `user_id`, `popup_id`, `viewed_at`
- Unique constraint on `(user_id, popup_id)`

---

## Logic for Get Popup API

1. Get authenticated user ID from JWT
2. Query active popups:
   - `is_active = TRUE`
   - Current time between `start_date` and `end_date`
   - Order by `priority DESC`, then `created_at DESC`
3. For each popup:
   - If `type == "one_time"`: Check if user has seen it (exists in `user_popup_history`)
   - If `type == "every_time"`: Return it
4. Return first matching popup (highest priority)
5. If none found, return `has_popup: false`

---

## Key Points

✅ **Customizable:** Colors, images, text, button styling  
✅ **Two Types:** Every time vs One time  
✅ **Date Range:** Start/end dates for scheduled popups  
✅ **Priority:** Multiple popups show in priority order  
✅ **User Tracking:** Track which users have seen one-time popups  

---

**Full Documentation:** See `POPUP_SYSTEM_API_REQUIREMENTS.md`

