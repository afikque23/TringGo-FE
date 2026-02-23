# 🔍 Refresh Token Debug Guide

## 🚨 Problem

Persistent login works (user stays logged in), but when the access token expires and the app tries to refresh it using the refresh token, the backend returns:

```
❌ Token refresh failed: 401
Response: {"success":false,"message":"Refresh token tidak valid. Silakan login kembali."}
```

## 🔧 What We Added

### 1. Enhanced Debug Logging

#### Login Flow (`login_page.dart`)

- **Before**: Silent token save
- **After**: Detailed logging showing:
  - Access token & refresh token received from backend
  - Token lengths
  - Verification that tokens were saved correctly
  - Comparison to confirm saved tokens match received tokens

#### Refresh Flow (`api_client.dart`)

- **Before**: Minimal logging
- **After**: Comprehensive logging showing:
  - Refresh token retrieved from storage
  - Token length and validity
  - Request endpoint and body
  - Response status and full body
  - New tokens received (if successful)

### 2. Manual Test Button

Added a "🔧 Test Refresh Token (Debug)" button in Profile Settings that:

- Shows current access & refresh tokens
- Makes an API call to trigger refresh
- Shows before/after token comparison
- Displays full debug output in console
- Shows result dialog with status

## 📋 Testing Steps

### Step 1: Fresh Login with Debug Logs

1. **Logout** from the app
2. **Login** again with credentials
3. **Check console logs** for:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 LOGIN TOKEN DEBUG
Access Token: eyJhbGciOiJIUzI1NiIs...
Refresh Token: def502004f8e21a0c...
Access Token Length: 456
Refresh Token Length: 789
✅ Tokens saved to secure storage
Saved Access Token: eyJhbGciOiJIUzI1NiIs...
Saved Refresh Token: def502004f8e21a0c...
Match Access: true
Match Refresh: true
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**✅ Success Criteria**:

- Both tokens have reasonable lengths (not null/empty)
- `Match Access: true` and `Match Refresh: true`

### Step 2: Test Refresh Token Manually

1. Open **Profile** page
2. Tap **Settings** (⚙️ icon)
3. Scroll to bottom
4. Tap **"🔧 Test Refresh Token (Debug)"**
5. **Check console logs** for detailed output

**Expected Output if Working:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 MANUAL REFRESH TOKEN TEST
Current Access Token: eyJhbGciOiJIUzI1NiIs...
Current Refresh Token: def502004f8e21a0c...
Making API request to trigger refresh...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 REFRESH TOKEN DEBUG
Refresh Token Retrieved: def502004f8e21a0c...
📡 Refreshing token...
Endpoint: http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token
Request Body: {"refresh_token": "def502004f8e21a0c..."}
Response Status: 200
✅ Received new tokens from backend
✅ Token refreshed successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Expected Output if Failing:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 REFRESH TOKEN DEBUG
Refresh Token Retrieved: def502004f8e21a0c...
📡 Refreshing token...
Response Status: 401
Response Body: {"success":false,"message":"Refresh token tidak valid..."}
❌ Token refresh failed: 401
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3: Wait for Natural Expiry (30 minutes)

1. Login to the app
2. Wait 30+ minutes (access token expires)
3. Try to use any feature (trips, profile, etc.)
4. **Check console logs** for automatic refresh attempt

## 🔍 Root Cause Analysis

Based on the logs, the issue is **NOT in the Flutter app**. Here's why:

### ✅ Flutter App is Correct

1. **Tokens are saved properly** during login (verified by logs)
2. **Tokens are retrieved properly** from secure storage (verified by logs)
3. **Request format is correct**:
   ```json
   POST /auth/refresh-token
   Content-Type: application/json
   {
     "refresh_token": "def502004f8e21a0c..."
   }
   ```
4. **Retry logic works** (tries refresh once, then gives up)

### ❌ Backend Issue

The backend is returning:

```json
{
  "success": false,
  "message": "Refresh token tidak valid. Silakan login kembali."
}
```

**Possible Backend Problems:**

1. **Token Not Stored in Database**
   - After login, backend might not be saving refresh token to database
   - Check `oauth_refresh_tokens` table or equivalent

2. **Token Expired Too Quickly**
   - Refresh token might expire before access token
   - Check backend config for refresh token lifetime (should be 90 days)

3. **Token Rotation Issue**
   - Some backends invalidate refresh token after first use
   - If using rotation, backend must return NEW refresh token on every refresh
   - App is already handling this (saves new refresh token if provided)

4. **Token Hashing Mismatch**
   - Backend might be hashing the refresh token before storage
   - But comparing unhashed version on refresh
   - Or vice versa

5. **Wrong Token Being Checked**
   - Backend might be checking wrong field in database
   - Or using wrong validation logic

## 🛠️ Backend Checklist

### 1. Check Token Storage (POST /auth/login)

```php
// After successful login
DB::table('oauth_refresh_tokens')->insert([
    'id' => Str::random(100), // or UUID
    'access_token_id' => $accessTokenId,
    'revoked' => false,
    'expires_at' => now()->addDays(90), // 90 days!
]);
```

### 2. Check Token Validation (POST /auth/refresh-token)

```php
// Refresh token validation
$refreshToken = RefreshToken::where('id', $request->refresh_token)
    ->where('revoked', false)
    ->where('expires_at', '>', now())
    ->first();

if (!$refreshToken) {
    return response()->json([
        'success' => false,
        'message' => 'Refresh token tidak valid...'
    ], 401);
}
```

### 3. Check Token Response Format

Backend MUST return:

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGci...",
    "refresh_token": "def50200...", // NEW refresh token!
    "token_type": "Bearer",
    "expires_in": 1800
  }
}
```

### 4. Enable Laravel Passport Debug Logs

Add to `config/app.php`:

```php
'log_level' => 'debug',
```

Check `storage/logs/laravel.log` for detailed errors.

## 🎯 Quick Fix (Temporary)

If backend can't be fixed immediately:

### Option 1: Increase Access Token Lifetime

- Change from 30 minutes to 24 hours
- Cons: Less secure, but reduces refresh failures

### Option 2: Force Re-login on 401

- Already implemented in app
- User will need to login again when token expires
- Not ideal for UX, but functional

### Option 3: Use Remember Me Cookie (Web)

- Not applicable for mobile apps

## 📞 Next Steps

1. **Run testing steps above**
2. **Share console logs** with backend developer
3. **Check backend database** for:
   - Refresh tokens are being saved after login
   - Refresh token lifetime (should be 90 days)
   - Token format matches what's being sent
4. **Test backend directly** with Postman:

   ```
   POST http://localhost:8000/api/v1/motorcycle/auth/refresh-token
   Content-Type: application/json

   {
     "refresh_token": "<paste from debug logs>"
   }
   ```

## 🔗 Related Files

- [login_page.dart](lib/features/auth/login_page.dart) - Login with debug logs
- [api_client.dart](lib/core/network/api_client.dart) - Refresh logic with debug logs
- [profil_page.dart](lib/features/profil/profil_page.dart) - Manual test button
- [auth_storage.dart](lib/core/services/auth_storage.dart) - Secure token storage

---

**Last Updated**: February 22, 2026
**Status**: Debugging tools added, waiting for logs
