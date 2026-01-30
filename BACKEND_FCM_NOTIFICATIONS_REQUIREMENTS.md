# 🔔 Backend Requirements for Live/Background Notifications (FCM)

## 📋 Overview

This document outlines all backend requirements for implementing Firebase Cloud Messaging (FCM) push notifications in the Android app. The app will receive notifications even when closed or in the background.

---

## 🎯 What's Needed from Backend

### **1. New API Endpoint: Register FCM Token**

### **2. Firebase Admin SDK Integration**

### **3. Send FCM Notifications When Creating Notifications**

### **4. Handle Token Management (Update/Delete)**

---

## 📡 API Endpoint Requirements

### **Endpoint 1: Register FCM Token**

**Purpose:** Store the device's FCM token linked to the user account so backend can send push notifications.

**Endpoint:** `POST /api/register-fcm-token-android/`

**Authentication:** Required (JWT token in header)

**Request Body:**
```json
{
  "fcm_token": "eXAMPLE_FCM_TOKEN_FROM_DEVICE",
  "device_type": "android"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "FCM token registered successfully"
}
```

**Response (Error - 400/500):**
```json
{
  "success": false,
  "error": "Error message here"
}
```

**Backend Implementation (Python/Django Example):**
```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def register_fcm_token(request):
    """
    Register FCM token for the authenticated user
    """
    fcm_token = request.data.get('fcm_token')
    device_type = request.data.get('device_type', 'android')
    
    if not fcm_token:
        return Response(
            {'success': False, 'error': 'FCM token is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Get or create FCM token record for user
    fcm_token_obj, created = FCMToken.objects.update_or_create(
        user=request.user,
        device_type=device_type,
        defaults={
            'fcm_token': fcm_token,
            'updated_at': timezone.now(),
        }
    )
    
    return Response({
        'success': True,
        'message': 'FCM token registered successfully',
        'created': created,
    }, status=status.HTTP_200_OK)
```

**Database Model (Django Example):**
```python
from django.db import models
from django.contrib.auth.models import User

class FCMToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    fcm_token = models.CharField(max_length=255, unique=True)
    device_type = models.CharField(max_length=50, default='android')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['user', 'device_type']  # One token per user per device type
```

---

## 🔥 Firebase Admin SDK Setup

### **Step 1: Install Firebase Admin SDK**

```bash
pip install firebase-admin
```

### **Step 2: Download Service Account Key**

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download the JSON file (e.g., `serviceAccountKey.json`)
4. **IMPORTANT:** Store this file securely, never commit to git!

### **Step 3: Initialize Firebase Admin SDK**

**File:** `settings.py` or `firebase_config.py`

```python
import firebase_admin
from firebase_admin import credentials, messaging
import os

# Initialize Firebase Admin SDK (only once)
def initialize_firebase():
    if not firebase_admin._apps:
        # Path to service account key
        cred_path = os.path.join(
            os.path.dirname(__file__),
            'path/to/serviceAccountKey.json'
        )
        
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        
        print('✅ Firebase Admin SDK initialized successfully')
    else:
        print('⚠️ Firebase Admin SDK already initialized')

# Call this in your Django settings or startup
initialize_firebase()
```

---

## 📤 Send FCM Notifications

### **Function: Send Push Notification**

**File:** `utils/fcm_service.py` (or similar)

```python
from firebase_admin import messaging
from django.contrib.auth.models import User
from .models import FCMToken

def send_push_notification(user_id, title, body, data=None, image_url=None):
    """
    Send FCM push notification to a user
    
    Args:
        user_id: User ID to send notification to
        title: Notification title
        body: Notification body/message
        data: Optional custom data dictionary
        image_url: Optional notification image URL
    
    Returns:
        bool: True if sent successfully, False otherwise
    """
    try:
        # Get FCM token for user
        fcm_token_obj = FCMToken.objects.filter(
            user_id=user_id,
            device_type='android'
        ).first()
        
        if not fcm_token_obj:
            print(f'⚠️ No FCM token found for user {user_id}')
            return False
        
        fcm_token = fcm_token_obj.fcm_token
        
        # Build notification
        notification = messaging.Notification(
            title=title,
            body=body,
            image=image_url,  # Optional: Large image for notification
        )
        
        # Build message
        message = messaging.Message(
            notification=notification,
            data=data or {},  # Custom data payload
            token=fcm_token,
            android=messaging.AndroidConfig(
                priority='high',  # High priority for important notifications
                notification=messaging.AndroidNotification(
                    sound='default',
                    channel_id='notification_channel',  # Android notification channel
                ),
            ),
        )
        
        # Send message
        response = messaging.send(message)
        print(f'✅ Successfully sent FCM notification: {response}')
        return True
        
    except messaging.UnregisteredError:
        # Token is invalid, remove it from database
        print(f'❌ FCM token invalid, removing from database')
        FCMToken.objects.filter(fcm_token=fcm_token).delete()
        return False
        
    except Exception as e:
        print(f'❌ Error sending FCM notification: {e}')
        return False
```

---

## 🔄 Integration Points

### **When to Send FCM Notifications**

Send FCM push notifications in these scenarios:

#### **1. When Creating a Notification**

**File:** Your notification creation function

```python
def create_notification(user_id, title, message, image=None, redirect_url=None):
    """
    Create notification and send FCM push
    """
    # Save notification to database (existing code)
    notification = Notification.objects.create(
        user_id=user_id,
        title=title,
        message=message,
        image=image,
        redirect_url=redirect_url,
        is_read=False,
    )
    
    # NEW: Send FCM push notification
    from .utils.fcm_service import send_push_notification
    
    # Prepare custom data for deep linking
    custom_data = {
        'type': 'notification',
        'notification_id': str(notification.id),
        'redirect_url': redirect_url or '',
    }
    
    # Send FCM notification
    send_push_notification(
        user_id=user_id,
        title=title,
        body=message,
        data=custom_data,
        image_url=f'{MEDIA_URL}{image}' if image else None,
    )
    
    return notification
```

#### **2. When Payment Status Changes**

**File:** Your payment status update function

```python
def update_payment_status(transaction_id, status):
    """
    Update payment status and notify user
    """
    # Update payment status (existing code)
    transaction = Transaction.objects.get(id=transaction_id)
    transaction.status = status
    transaction.save()
    
    # NEW: Send FCM notification
    if status == 'SUCCESS':
        send_push_notification(
            user_id=transaction.user_id,
            title='Payment Successful',
            body=f'Your payment of ₹{transaction.amount} was successful',
            data={
                'type': 'payment',
                'transaction_id': transaction_id,
                'status': status,
            },
        )
    elif status == 'FAILED':
        send_push_notification(
            user_id=transaction.user_id,
            title='Payment Failed',
            body=f'Your payment of ₹{transaction.amount} failed. Please try again.',
            data={
                'type': 'payment',
                'transaction_id': transaction_id,
                'status': status,
            },
        )
```

#### **3. When Wallet Balance Updates**

**File:** Your wallet update function

```python
def update_wallet_balance(user_id, amount, transaction_type):
    """
    Update wallet balance and notify user
    """
    # Update balance (existing code)
    wallet = Wallet.objects.get(user_id=user_id)
    wallet.balance += amount
    wallet.save()
    
    # NEW: Send FCM notification for significant changes
    if abs(amount) >= 100:  # Only notify for amounts >= ₹100
        send_push_notification(
            user_id=user_id,
            title='Wallet Updated',
            body=f'Your wallet balance has been updated by ₹{abs(amount)}',
            data={
                'type': 'wallet',
                'amount': str(amount),
                'transaction_type': transaction_type,
            },
        )
```

---

## 🔧 Token Management

### **Update Token When User Logs In**

**File:** Your login function

```python
def user_login(username, password, fcm_token=None):
    """
    User login and register/update FCM token
    """
    # Authenticate user (existing code)
    user = authenticate(username=username, password=password)
    
    if user:
        # NEW: Register/update FCM token if provided
        if fcm_token:
            FCMToken.objects.update_or_create(
                user=user,
                device_type='android',
                defaults={'fcm_token': fcm_token}
            )
        
        # Return auth token (existing code)
        return generate_auth_token(user)
    
    return None
```

### **Remove Token When User Logs Out**

**File:** Your logout function

```python
def user_logout(user_id, fcm_token=None):
    """
    User logout and optionally remove FCM token
    """
    # Invalidate auth token (existing code)
    invalidate_auth_token(user_id)
    
    # NEW: Remove FCM token if provided
    if fcm_token:
        FCMToken.objects.filter(
            user_id=user_id,
            fcm_token=fcm_token
        ).delete()
    
    return {'success': True, 'message': 'Logged out successfully'}
```

---

## 📊 Notification Data Payload Structure

### **Standard Notification Data Format**

```json
{
  "type": "notification|payment|wallet|transaction",
  "notification_id": "123",
  "transaction_id": "abc123",
  "redirect_url": "/notification/123",
  "amount": "100.00",
  "status": "SUCCESS"
}
```

**Types:**
- `notification` - General notification
- `payment` - Payment-related notification
- `wallet` - Wallet balance update
- `transaction` - Transaction update

---

## 🧪 Testing

### **Test FCM Token Registration**

```bash
curl -X POST http://your-api.com/api/register-fcm-token-android/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "TEST_FCM_TOKEN",
    "device_type": "android"
  }'
```

### **Test Sending Notification**

```python
# In Django shell or test script
from utils.fcm_service import send_push_notification

send_push_notification(
    user_id=1,
    title='Test Notification',
    body='This is a test notification',
    data={'type': 'notification', 'test': 'true'},
)
```

---

## 📝 Summary Checklist

### **Backend Tasks:**

- [ ] **Install Firebase Admin SDK**
  ```bash
  pip install firebase-admin
  ```

- [ ] **Download Service Account Key**
  - Go to Firebase Console → Service Accounts
  - Generate and download `serviceAccountKey.json`
  - Store securely (never commit to git)

- [ ] **Initialize Firebase Admin SDK**
  - Add initialization code in Django settings/startup
  - Test initialization

- [ ] **Create Database Model for FCM Tokens**
  - `FCMToken` model with user, token, device_type fields
  - Run migrations

- [ ] **Create FCM Token Registration Endpoint**
  - `POST /api/register-fcm-token-android/`
  - Store/update token linked to user
  - Handle authentication

- [ ] **Create FCM Service Function**
  - `send_push_notification()` function
  - Handle token retrieval
  - Handle errors (invalid tokens, etc.)

- [ ] **Integrate FCM Sending**
  - When creating notifications → Send FCM
  - When payment status changes → Send FCM
  - When wallet updates → Send FCM (optional)
  - Any other important events

- [ ] **Handle Token Management**
  - Update token on login
  - Remove token on logout
  - Remove invalid tokens automatically

- [ ] **Test End-to-End**
  - Register token from app
  - Send test notification
  - Verify delivery

---

## 🔐 Security Considerations

1. **Service Account Key**
   - Store `serviceAccountKey.json` securely
   - Use environment variables for path
   - Never commit to version control

2. **FCM Token Validation**
   - Validate token format before storing
   - Remove invalid/expired tokens automatically

3. **User Authentication**
   - FCM token registration requires authentication
   - Only send notifications to authenticated users

4. **Rate Limiting**
   - Implement rate limiting for FCM sending
   - Prevent spam/abuse

---

## 📚 Additional Resources

- **Firebase Admin SDK Docs:** https://firebase.google.com/docs/admin/setup
- **FCM Sending Guide:** https://firebase.google.com/docs/cloud-messaging/send-message
- **FCM Message Types:** https://firebase.google.com/docs/cloud-messaging/concept-options

---

## ❓ Questions?

If you need clarification on any requirement, please contact the frontend team.

---

## ✅ Current Notification APIs (No Changes Needed)

These existing APIs work as-is and don't need modifications:

- ✅ `GET /api/notification-stats-android/` - Get notification stats
- ✅ `GET /api/user-notifications-android/` - Get user notifications
- ✅ `POST /api/mark-all-notifications-read-android/` - Mark as read

**FCM is just for delivery - your existing notification APIs remain unchanged!**

