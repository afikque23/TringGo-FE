# 🧪 Token Refresh Testing Guide

**Purpose**: Verify bahwa token refresh bekerja dengan benar setelah backend fix  
**Audience**: QA Team, Backend Team, Users  
**Expected Time**: 45+ minutes (karena harus tunggu 30 min untuk access token expire)

---

## 📋 Pre-Requisites

- [ ] Backend fix deployed (May 15, 2026)
- [ ] Flutter app updated dengan single-flight refresh logic
- [ ] Test user account (bisa buat baru atau gunakan existing)
- [ ] Access ke backend logs: `tail -f storage/logs/laravel.log`
- [ ] Access ke Flutter app logs (Android Studio atau via `adb logcat`)

---

## 🚀 Test Scenario 1: Login → Immediate Refresh

**Time**: 5 minutes  
**Goal**: Verify login returns correct token format dan refresh works immediately

### Step 1: Login via API

```bash
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "data": {
    "access_token": "64|...",
    "refresh_token": "cfbe22b22123f01ba4bfb7f15cf57e94...",
    "expires_in": 1800
  }
}
```

**Verify**:

- [ ] `refresh_token` length = 128 chars (NOT 64)
- [ ] `access_token` = starts with "64|" (Sanctum format)
- [ ] `expires_in` = 1800 (30 mins)

### Step 2: Save Token for Testing

```bash
REFRESH_TOKEN="cfbe22b22123f01ba4bfb7f15cf57e94..."
ACCESS_TOKEN="64|xxx..."
USER_ID="5"
```

### Step 3: Immediately Call Refresh Endpoint

```bash
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d "{
    \"refresh_token\": \"$REFRESH_TOKEN\"
  }"
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Token berhasil diperbaharui",
  "data": {
    "access_token": "64|yyy...",
    "refresh_token": "new_token_128_chars...",
    "expires_in": 1800
  }
}
```

**Verify**:

- [ ] Response `statusCode` = 200
- [ ] New `refresh_token` is different from old one
- [ ] New `access_token` is different from old one
- [ ] Both tokens are 128 chars (refresh) and proper format (access)

### Step 4: Try Using Old Refresh Token Again

```bash
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d "{
    \"refresh_token\": \"$REFRESH_TOKEN\"  # Old token
  }"
```

**Expected Response:**

```json
{
  "success": false,
  "message": "Refresh token tidak valid. Silakan login kembali."
}
```

**Verify**:

- [ ] Response `statusCode` = 401 (NOT 404)
- [ ] Error message = "Refresh token tidak valid" (NOT "User tidak ditemukan")
- [ ] ✅ This proves token rotation works!

### Step 5: Check Backend Logs

```bash
tail -f storage/logs/laravel.log | grep -A 5 -B 5 "refresh"
```

**Expected Logs:**

```
[2026-05-15 14:30:15] local.INFO: Token refresh request (token_hash: ed5c8421c583...)
[2026-05-15 14:30:15] local.INFO: Token refreshed successfully (user_id: 5)
[2026-05-15 14:30:45] local.WARNING: Refresh token not found (token_hash: ed5c8421c583...) [OLD TOKEN]
```

---

## 🕐 Test Scenario 2: Wait for Access Token Expiry

**Time**: 40 minutes  
**Goal**: Verify automatic token refresh every 30 minutes

### Phase 1: Login (Minute 0)

```bash
# Login
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123"
  }'

# Save tokens
REFRESH_TOKEN="..."
ACCESS_TOKEN="64|..."
echo "Login at: $(date)"
```

### Phase 2: Use API (Minutes 0-30)

```bash
# Make API call immediately (should work)
curl -X GET http://10.0.2.2:8000/api/v1/motorcycle/users/profile \
  -H "Authorization: Bearer $ACCESS_TOKEN"
# Expected: 200 OK

echo "API call at: $(date) → 200 OK ✅"

# Wait 5 minutes
sleep 300

# Make another API call (access token still valid)
curl -X GET http://10.0.2.2:8000/api/v1/motorcycle/users/profile \
  -H "Authorization: Bearer $ACCESS_TOKEN"
# Expected: 200 OK

echo "API call at: $(date) → 200 OK ✅"
```

### Phase 3: Access Token Expires (Minute 31+)

```bash
# Timestamp: ~31 minutes after login

# Make API call with EXPIRED access token
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET http://10.0.2.2:8000/api/v1/motorcycle/users/profile \
  -H "Authorization: Bearer $ACCESS_TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "API call at: $(date) → $HTTP_CODE"

if [ "$HTTP_CODE" = "401" ]; then
  echo "✅ Got 401 as expected (access token expired)"
else
  echo "❌ Expected 401, got $HTTP_CODE"
  echo "Response: $BODY"
fi
```

### Phase 4: Auto-Refresh (App Should Do This Automatically)

**In Flutter App Logs:**

```
I/flutter: 🔄 Access token expired, attempting refresh...
I/flutter: 📡 Refreshing token...
I/flutter: ✅ Token refreshed successfully!
I/flutter: New access token: 64|yyy...
I/flutter: New refresh token: zzz...
```

**In Backend Logs:**

```
[2026-05-15 14:60:30] local.INFO: Token refresh request (user_id: 5)
[2026-05-15 14:60:30] local.INFO: Token refreshed successfully (user_id: 5)
```

### Phase 5: Verify New Token Works

```bash
# App automatically retries with NEW access token
curl -X GET http://10.0.2.2:8000/api/v1/motorcycle/users/profile \
  -H "Authorization: Bearer $NEW_ACCESS_TOKEN"
# Expected: 200 OK ✅
```

---

## 📱 Test Scenario 3: Flutter App End-to-End

**Time**: 45+ minutes  
**Goal**: Verify complete flow in real Flutter app

### Setup

```bash
# 1. Open Flutter app on device/emulator
# 2. Logout if already logged in
# 3. Open Flutter console to see logs:
#    - Android: adb logcat | grep flutter
#    - iOS: Xcode console
```

### Test Flow

```
T=00:00 - Login
┌─────────────────────────────┐
│ Tap Login                   │
│ Enter: testuser@example.com │
│ Password: password123       │
│ Tap: Proceed                │
└─────────────────────────────┘
   │
   ├─ Check logs:
   │  I/flutter: 🌐 [POST] .../auth/login
   │  I/flutter: ✅ Login successful
   │  I/flutter: Navigating to Dashboard
   │
   └─ ✅ Dashboard appears

T=00:05 - Normal API Usage
┌─────────────────────────────┐
│ Browse app features         │
│ Make 2-3 API calls          │
│ Check logs for success      │
└─────────────────────────────┘
   │
   ├─ Check logs:
   │  I/flutter: 🌐 [GET] .../motorcycles
   │  I/flutter: ✅ 200 OK
   │
   └─ ✅ Data loads fine

T=00:30 - First Token Refresh (after access token expire)
┌─────────────────────────────┐
│ App should auto-refresh     │
│ NO user action needed       │
│ Should happen silently      │
└─────────────────────────────┘
   │
   ├─ Check logs:
   │  I/flutter: 🔄 Access token expired, attempting refresh...
   │  I/flutter: 📡 Refreshing token...
   │  I/flutter: ✅ Token refreshed successfully!
   │
   └─ ✅ New tokens saved

T=00:31 - Continue Using (after refresh)
┌─────────────────────────────┐
│ Make more API calls         │
│ Should work with new token  │
│ No errors should appear     │
└─────────────────────────────┘
   │
   ├─ Check logs:
   │  I/flutter: 🌐 [GET] .../schedules
   │  I/flutter: ✅ 200 OK
   │
   └─ ✅ Everything works!

T=01:00 - Second Token Refresh (60 mins later)
┌─────────────────────────────┐
│ App should refresh again    │
│ Another automatic refresh   │
└─────────────────────────────┘
   │
   ├─ Check logs:
   │  I/flutter: 🔄 Access token expired, attempting refresh...
   │  I/flutter: ✅ Token refreshed successfully!
   │
   └─ ✅ Refresh works again!
```

### Verification Checklist

- [ ] Login succeeds
- [ ] Access token + refresh token saved correctly
- [ ] Can make API calls immediately after login
- [ ] After 30 mins: See "Token refreshed" in logs (automatic)
- [ ] NO manual refresh needed
- [ ] NO 401 errors appear
- [ ] NO "User tidak ditemukan" errors
- [ ] App continues working after each refresh
- [ ] No crashes or exceptions

### What Should NEVER Appear in Logs

```
❌ ❌ Token refresh failed: 404
❌ ❌ User tidak ditemukan
❌ ❌ Unauthorized (repeated)
❌ ❌ Cannot read property 'refresh_token'
❌ ❌ Socket timeout
```

---

## 🔍 Test Scenario 4: Error Conditions

**Time**: 15 minutes  
**Goal**: Verify proper error handling

### Test 4A: Invalid Refresh Token

```bash
# Try refresh with wrong token
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "invalid_token_12345"
  }'
```

**Expected**:

- [ ] `statusCode` = 401
- [ ] Message = "Refresh token tidak valid"
- [ ] NOT 404 "User tidak ditemukan"

### Test 4B: Missing Refresh Token

```bash
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected**:

- [ ] `statusCode` = 400 atau 422 (validation error)
- [ ] Clear error message

### Test 4C: Expired Refresh Token (After 90 days)

```bash
# (Cannot test immediately, but verify logic)
# If refresh_token_expires_at < now():
# Should return 401 "Refresh token tidak valid"
```

### Test 4D: App Logout

```bash
# In Flutter app:
# 1. Tap Menu → Logout
# 2. Verify:
#    - All tokens cleared from storage
#    - Redirected to login screen
#    - Next API call fails (no auth header)
```

**Expected Logs**:

```
I/flutter: 📡 Logging out...
I/flutter: ✅ Logged out successfully
I/flutter: 🧹 Cleared local tokens
I/flutter: Redirecting to login screen
```

---

## 📊 Test Results Template

Use this template to document test results:

```markdown
# Test Results - May 15, 2026

**Tester**: [Name]  
**Device**: [Emulator/Physical - Android/iOS]  
**App Version**: [version]  
**Backend Version**: [commit/date]

## Scenario 1: Login → Immediate Refresh

- [ ] Passed
- [ ] Failed - Issue: \***\*\_\_\_\*\***
- [ ] Notes: \***\*\_\_\_\*\***

## Scenario 2: Wait for Access Token Expiry

- [ ] Passed
- [ ] Failed - Issue: \***\*\_\_\_\*\***
- [ ] Notes: \***\*\_\_\_\*\***

## Scenario 3: Flutter App End-to-End

- [ ] Passed (Duration: \_\_\_ mins)
- [ ] Failed - Issue: \***\*\_\_\_\*\***
- [ ] Notes: \***\*\_\_\_\*\***

## Scenario 4: Error Conditions

- [ ] 4A Passed
- [ ] 4B Passed
- [ ] 4C Passed
- [ ] 4D Passed

## Overall Status

- [ ] ✅ ALL TESTS PASSED
- [ ] ⚠️ SOME ISSUES FOUND
- [ ] ❌ CRITICAL ISSUES

## Issues Found

(If any)

1. ***
2. ***

## Logs Collected

- Backend logs: [path]
- Flutter logs: [path]
- Curl commands: [attached]

**Sign-Off Date**: \***\*\_\_\_\*\***
```

---

## 🛠️ Debugging If Tests Fail

### If you see "404 User tidak ditemukan"

```bash
# 1. Check backend code was updated
grep -n "normalizeRefreshToken" app/Models/User.php
# Should find: public static function normalizeRefreshToken

# 2. Check cache was cleared
php artisan cache:clear && php artisan config:clear

# 3. Manually test the logic
php -r "
  include 'vendor/autoload.php';
  App::setBasePath(getcwd());
  echo hash('sha256', 'testtoken123');
"
```

### If you see "Token refresh failed: 401"

```bash
# 1. Check token is actually in database
SELECT * FROM tokens WHERE user_id = 5 ORDER BY created_at DESC LIMIT 1;

# 2. Check expiry
SELECT
  CASE
    WHEN expires_at < NOW() THEN 'EXPIRED'
    ELSE 'VALID'
  END as status,
  expires_at
FROM tokens WHERE user_id = 5 LIMIT 1;

# 3. Check if token is hashed correctly
SELECT LENGTH(refresh_token) FROM tokens WHERE user_id = 5 LIMIT 1;
# Should be 64 (SHA256 hash)
```

### If app keeps retrying refresh

```bash
# 1. Check single-flight logic in ApiClient
grep -n "_refreshInFlight" lib/core/network/api_client.dart
# Should have: Future<bool>? _refreshInFlight

# 2. Check that old tokens are being cleared
grep -n "clearAll" lib/core/network/api_client.dart
# Should clear on 401/403

# 3. Check SplashScreen validation
grep -n "refreshTokens" lib/features/splashscreen/splashcreen.dart
# Should call refreshTokens() before auto-login
```

---

## ✅ Success Criteria

**All tests PASSED if**:

- ✅ Login returns 128-char refresh token
- ✅ Refresh returns 200 OK (not 404)
- ✅ Old token cannot be reused
- ✅ App auto-refreshes at 30-min mark
- ✅ No 401 loops or errors
- ✅ Users stay logged in for 90 days
- ✅ No manual refresh needed by app

---

**Ready to test? Start with Scenario 1! 🚀**
