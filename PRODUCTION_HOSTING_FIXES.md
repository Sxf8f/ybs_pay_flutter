# Production Hosting Fixes - Django Backend to Mobile App

## Issue Summary
The app was working with localhost Django backend but stopped working after hosting the server at `https://trvpay.com/`.

## Changes Made to Flutter App

### 1. Enhanced HTTP Client (`lib/core/auth/httpClient.dart`)
- ✅ Added 30-second timeout for all requests
- ✅ Added comprehensive error handling for:
  - Network connection errors (SocketException)
  - HTTP errors (HttpException)
  - Timeout errors
  - SSL certificate errors
- ✅ Added detailed logging for debugging
- ✅ Improved error messages for better user feedback

### 2. URL Helper Method (`lib/core/const/assets_const.dart`)
- ✅ Added `buildApiUrl()` helper method to prevent double slashes
- ✅ Ensures proper URL construction

## Backend (Django) Configuration Required

### ⚠️ CRITICAL: Check These Django Settings

#### 1. **CORS Configuration**
Ensure Django CORS is properly configured to allow requests from your mobile app:

```python
# settings.py
CORS_ALLOWED_ORIGINS = [
    "https://trvpay.com",
    # Add any other allowed origins
]

# For mobile apps, you might need:
CORS_ALLOW_ALL_ORIGINS = True  # Only for development/testing
# OR better:
CORS_ALLOW_CREDENTIALS = True
```

#### 2. **ALLOWED_HOSTS**
Make sure your Django `ALLOWED_HOSTS` includes your domain:

```python
# settings.py
ALLOWED_HOSTS = [
    'trvpay.com',
    'www.trvpay.com',
    '*.trvpay.com',  # If using subdomains
]
```

#### 3. **SSL Certificate**
Ensure your SSL certificate is valid and properly configured:
- Certificate should be from a trusted CA (not self-signed)
- Certificate should match the domain `trvpay.com`
- Check certificate expiration date

#### 4. **API Endpoints**
Verify all API endpoints are accessible:
- Test: `https://trvpay.com/api/android/banners/`
- Test: `https://trvpay.com/api/android/services/`
- Test: `https://trvpay.com/api/layout-settings/all/`

#### 5. **Django Settings for Production**
```python
# settings.py
DEBUG = False  # Should be False in production
SECURE_SSL_REDIRECT = True  # Redirect HTTP to HTTPS
SESSION_COOKIE_SECURE = True  # Only send cookies over HTTPS
CSRF_COOKIE_SECURE = True  # Only send CSRF cookies over HTTPS
```

#### 6. **Static Files & Media Files**
Ensure static and media files are properly served:
- Configure `STATIC_URL` and `MEDIA_URL`
- Set up proper file serving (nginx, Apache, or cloud storage)

## Testing Checklist

### ✅ App-Side Testing
1. Check logs in Flutter console for detailed error messages
2. Look for these log prefixes:
   - `🌐 [HTTP] GET Request:` - Shows the URL being called
   - `✅ [HTTP] Response Status:` - Shows response status
   - `❌ [HTTP] GET Error:` - Shows any errors

### ✅ Backend Testing
1. Test API endpoints directly in browser/Postman:
   ```
   GET https://trvpay.com/api/android/banners/
   Headers: Authorization: Bearer <token>
   ```

2. Check Django logs for incoming requests

3. Verify SSL certificate:
   ```bash
   openssl s_client -connect trvpay.com:443
   ```

## Common Issues & Solutions

### Issue 1: SSL Certificate Error
**Error**: `SSL certificate error: Please ensure the server has a valid SSL certificate.`

**Solution**:
- Ensure SSL certificate is valid and not expired
- Check certificate chain is complete
- Verify certificate matches the domain

### Issue 2: Network Timeout
**Error**: `Request timeout: Server took too long to respond.`

**Solution**:
- Check server performance
- Increase timeout if needed (currently 30 seconds)
- Check server logs for slow queries

### Issue 3: Connection Refused
**Error**: `Network error: Unable to connect to server.`

**Solution**:
- Verify server is running
- Check firewall rules
- Verify domain DNS is pointing to correct server
- Check if port 443 (HTTPS) is open

### Issue 4: 401 Unauthorized
**Error**: `Session expired. Please login again.`

**Solution**:
- Token might be expired
- Check token refresh endpoint
- Verify JWT token configuration on backend

### Issue 5: CORS Error
**Error**: CORS policy blocking requests

**Solution**:
- Configure CORS properly in Django
- Add mobile app user agents to allowed list if needed

## Base URL Configuration

Current base URL: `https://trvpay.com/`

To change it, edit `lib/core/const/assets_const.dart`:
```dart
static const String apiBase = 'https://trvpay.com/';
```

## Next Steps

1. ✅ Test the app with the new error handling
2. ✅ Check Flutter console logs for detailed error messages
3. ✅ Verify Django backend configuration (CORS, ALLOWED_HOSTS, SSL)
4. ✅ Test API endpoints directly
5. ✅ Check server logs for any errors

## Debugging Tips

1. **Enable verbose logging**: The HTTP client now logs all requests and responses
2. **Check response status codes**: Non-200 status codes are logged
3. **Review error messages**: More descriptive error messages help identify the issue
4. **Test endpoints manually**: Use Postman or curl to test backend directly

## Contact Points

If issues persist:
1. Check Flutter console logs for specific error messages
2. Check Django server logs
3. Verify network connectivity
4. Test API endpoints directly
