# Authentication Lifecycle Best Practices

**Purpose**: Panduan lengkap untuk secure dan reliable authentication flow di aplikasi

---

## 📐 Ideal Token Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    Token Lifecycle Flow                      │
└─────────────────────────────────────────────────────────────┘

1. USER LOGIN
   │
   ├─ Mobile app: POST /auth/login (email, password)
   ├─ Backend: Validate credentials
   ├─ Backend: Generate access_token (1 hour) + refresh_token (90 days)
   └─ Response: { access_token, refresh_token, expires_in: 3600 }
       │
       └─ Mobile: Save tokens ke secure storage

2. API REQUEST (NORMAL)
   │
   ├─ Mobile: Send request dengan Authorization: Bearer {access_token}
   ├─ Backend: Validate access_token
   └─ Response: 200 OK (success)

3. API REQUEST (ACCESS TOKEN EXPIRED)
   │
   ├─ Mobile: Get 401 Unauthorized
   ├─ Mobile: Check jika 401 (access token expired)
   ├─ Mobile: POST /auth/refresh-token (refresh_token)
   ├─ Backend: Validate refresh_token
   ├─ Backend: Revoke old refresh_token ✅ PENTING
   ├─ Backend: Generate NEW access_token + refresh_token
   └─ Response: { access_token, refresh_token, expires_in: 3600 }
       │
       ├─ Mobile: Update tokens di storage
       ├─ Mobile: Retry original request dengan new access_token
       └─ Response: 200 OK (success)

4. REFRESH TOKEN INVALID/EXPIRED
   │
   ├─ Mobile: Get 401 untuk refresh attempt
   ├─ Backend: Reject refresh token (invalid/expired/revoked)
   └─ Response: 401 Unauthorized
       │
       ├─ Mobile: Clear local tokens
       ├─ Mobile: Redirect ke login screen
       └─ User: Must login again

5. USER LOGOUT
   │
   ├─ Mobile: POST /auth/logout (access_token)
   ├─ Backend: Revoke access_token dan refresh_token
   └─ Response: 200 OK
       │
       ├─ Mobile: Clear all tokens dari storage
       └─ Mobile: Redirect ke login screen

6. TOKEN CLEANUP (SCHEDULED DAILY)
   │
   ├─ Backend: Delete expired tokens (> 90 days old)
   ├─ Backend: Delete revoked tokens (> 7 days old)
   └─ Result: Cleaner database, better performance
```

---

## 🔐 Token Management Strategy

### Access Token

```
Purpose: Short-lived token untuk authenticated API requests
TTL: 1 hour
Storage: Memory (secure) atau Secure Storage
Sent via: Authorization header (Bearer token)
Validation: Check expiry, signature, user status
Scope: All API resources
```

**Example**:

```json
{
  "sub": 5,
  "email": "user@example.com",
  "iat": 1715756400,
  "exp": 1715760000, // 1 hour from issue
  "type": "access"
}
```

### Refresh Token

```
Purpose: Long-lived token untuk get new access token
TTL: 90 days
Storage: Secure Storage ONLY (never in memory)
Sent via: POST body (not in header!)
Validation: Check expiry, revocation, device match
Scope: Only for /auth/refresh-token endpoint
Rotation: New token issued setiap refresh
```

**Example**:

```json
{
  "sub": 5,
  "iat": 1715756400,
  "exp": 1723618800, // 90 days from issue
  "type": "refresh",
  "jti": "unique_id_123" // For revocation tracking
}
```

---

## 📱 Mobile App Implementation Checklist

### Storage

- [x] Access token: Secure storage (FlutterSecureStorage)
- [x] Refresh token: Secure storage ONLY
- [x] User ID: Secure storage
- [x] NEVER store tokens di SharedPreferences (plain text!)

### Login Flow

```dart
// 1. POST /auth/login
final response = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  body: jsonEncode({'email': email, 'password': password})
);

final data = jsonDecode(response.body)['data'];

// 2. Save tokens
await authStorage.saveTokens(
  accessToken: data['access_token'],
  refreshToken: data['refresh_token']
);

// 3. Navigate ke dashboard
Navigator.pushReplacement(context, DashboardPage());
```

### API Request Interceptor

```dart
// ✅ GOOD: Automatic refresh on 401
Future<http.Response> _makeRequest(String method, String endpoint) async {
  var accessToken = await _authStorage.getAccessToken();

  var response = await _sendRequest(method, endpoint, accessToken);

  // If 401, try refresh
  if (response.statusCode == 401) {
    final refreshed = await _refreshToken();

    if (refreshed) {
      accessToken = await _authStorage.getAccessToken();
      response = await _sendRequest(method, endpoint, accessToken);
    } else {
      // Refresh failed, redirect to login
      _handleLogout();
    }
  }

  return response;
}
```

### Refresh Token Implementation

```dart
// ✅ GOOD: Single-flight refresh
Future<bool> _refreshToken() async {
  if (_refreshInFlight != null) {
    return _refreshInFlight;  // Wait untuk existing refresh
  }

  final future = _doRefresh().whenComplete(() {
    _refreshInFlight = null;
  });

  _refreshInFlight = future;
  return future;
}

Future<bool> _doRefresh() async {
  try {
    final refreshToken = await _authStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      body: jsonEncode({'refresh_token': refreshToken})
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      await _authStorage.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token']
      );

      return true;
    }

    // Refresh failed (401/403)
    await _authStorage.clearAll();
    _handleLogout();
    return false;

  } catch (e) {
    print('Error refreshing token: $e');
    return false;
  }
}
```

### Logout Flow

```dart
Future<void> logout() async {
  try {
    // Notify backend
    final accessToken = await _authStorage.getAccessToken();
    if (accessToken != null) {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Authorization': 'Bearer $accessToken'}
      );
    }
  } catch (e) {
    // Continue even if API fails
  } finally {
    // Always clear local tokens
    await _authStorage.clearAll();
    _handleLogout();
  }
}
```

---

## 🖥️ Backend Implementation Checklist

### Database Schema

```sql
CREATE TABLE tokens (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  access_token VARCHAR(255) UNIQUE NOT NULL,
  refresh_token VARCHAR(255) UNIQUE NOT NULL,

  expires_at TIMESTAMP NOT NULL,
  revoked BOOLEAN DEFAULT FALSE,
  revoked_at TIMESTAMP NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_refresh_token (refresh_token),
  INDEX idx_expires_revoked (expires_at, revoked)
);
```

### Login Endpoint

```php
// POST /auth/login
public function login(Request $request)
{
    $validated = $request->validate([
        'email' => 'required|email',
        'password' => 'required'
    ]);

    // Validate credentials
    if (!Auth::attempt($validated)) {
        return response()->json(['message' => 'Invalid credentials'], 401);
    }

    $user = Auth::user();

    // Generate tokens
    $accessToken = $this->generateAccessToken();
    $refreshToken = $this->generateRefreshToken();

    // Save to database
    Token::create([
        'user_id' => $user->id,
        'access_token' => $accessToken,
        'refresh_token' => $refreshToken,
        'expires_at' => now()->addDays(90),
        'revoked' => false
    ]);

    return response()->json([
        'success' => true,
        'data' => [
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'expires_in' => 3600,  // 1 hour untuk access token
            'user' => $user->only(['id', 'name', 'email'])
        ]
    ]);
}
```

### Refresh Token Endpoint

```php
// POST /auth/refresh-token
public function refreshToken(Request $request)
{
    $oldRefreshToken = $request->input('refresh_token');

    // Validate old token
    $tokenRecord = Token::where('refresh_token', $oldRefreshToken)
        ->where('revoked', false)
        ->where('expires_at', '>', now())
        ->first();

    if (!$tokenRecord) {
        return response()->json(['message' => 'Refresh token invalid'], 401);
    }

    // ✅ CRITICAL: Revoke old token
    $tokenRecord->update([
        'revoked' => true,
        'revoked_at' => now()
    ]);

    // Generate new tokens
    $newAccessToken = $this->generateAccessToken();
    $newRefreshToken = $this->generateRefreshToken();

    Token::create([
        'user_id' => $tokenRecord->user_id,
        'access_token' => $newAccessToken,
        'refresh_token' => $newRefreshToken,
        'expires_at' => now()->addDays(90),
        'revoked' => false
    ]);

    return response()->json([
        'success' => true,
        'data' => [
            'access_token' => $newAccessToken,
            'refresh_token' => $newRefreshToken,
            'expires_in' => 3600
        ]
    ]);
}
```

### Protected Endpoints

```php
// Middleware: VerifyAccessToken
public function handle($request, Closure $next)
{
    $token = $request->bearerToken();

    if (!$token) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $tokenRecord = Token::where('access_token', $token)
        ->where('revoked', false)
        ->where('expires_at', '>', now())
        ->first();

    if (!$tokenRecord) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    Auth::setUser($tokenRecord->user);
    return $next($request);
}
```

### Logout Endpoint

```php
// POST /auth/logout
public function logout(Request $request)
{
    $token = $request->bearerToken();

    if ($token) {
        Token::where('access_token', $token)->update([
            'revoked' => true,
            'revoked_at' => now()
        ]);
    }

    return response()->json(['success' => true, 'message' => 'Logout successful']);
}
```

### Scheduled Cleanup

```php
// app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    $schedule->command('tokens:cleanup')->daily()->at('02:00');
}

// app/Console/Commands/CleanupExpiredTokens.php
public function handle()
{
    Token::where('expires_at', '<', now()->subDays(90))
        ->orWhere(function ($query) {
            $query->where('revoked', true)
                ->where('revoked_at', '<', now()->subDays(7));
        })
        ->delete();

    \Log::info('Token cleanup completed');
}
```

---

## 🧪 Testing Checklist

### Unit Tests

```php
// Test login returns tokens
test('login returns access and refresh tokens');

// Test refresh generates new tokens
test('refresh token generates new tokens');

// Test old refresh token is revoked
test('old refresh token is revoked after refresh');

// Test cannot reuse old refresh token
test('cannot use revoked refresh token');

// Test refresh token expiration
test('cannot refresh with expired token');
```

### Integration Tests

```php
// Test full login → request → refresh → request flow
test('complete token lifecycle works');

// Test concurrent refresh requests
test('concurrent refresh requests handled correctly');

// Test token cleanup removes old tokens
test('cleanup task removes expired tokens');
```

### Load Testing

```bash
# Test 1000 concurrent refresh requests
ab -n 1000 -c 100 \
  -p refreshToken.json \
  -T application/json \
  http://api.example.com/auth/refresh-token
```

---

## 📊 Monitoring & Alerts

### Key Metrics

```sql
-- 1. Success rate
SELECT
  COUNT(*) as total,
  SUM(CASE WHEN response_code = 200 THEN 1 ELSE 0 END) as successful,
  ROUND(SUM(CASE WHEN response_code = 200 THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as success_rate
FROM api_logs
WHERE endpoint = '/auth/refresh-token'
AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR);

-- 2. Failure reasons
SELECT response_code, COUNT(*) as count
FROM api_logs
WHERE endpoint = '/auth/refresh-token'
AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY response_code;

-- 3. Average response time
SELECT AVG(response_time_ms) as avg_time
FROM api_logs
WHERE endpoint = '/auth/refresh-token'
AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR);
```

### Alerts

```
SET UP ALERTS FOR:
- Token refresh failure rate > 1%
- 401 errors > 100/hour
- Database query time > 500ms
- Cleanup task failed to run
```

---

## 🚀 Deployment Checklist

- [ ] Database migration applied
- [ ] Indexes created untuk performance
- [ ] Logging configured
- [ ] Cleanup task scheduled
- [ ] Middleware registered
- [ ] Environment variables set
- [ ] Tests passing
- [ ] Code reviewed
- [ ] Staging deployment successful
- [ ] Mobile app tested
- [ ] Production deployment

---

## ✅ Success Criteria

After implementation:

✅ **Reliability**: 99.9% token refresh success rate  
✅ **Security**: Token rotation, revocation, no reuse  
✅ **Performance**: Refresh response < 100ms  
✅ **Usability**: Users tidak pernah surprise 401 logout  
✅ **Observability**: Comprehensive logging untuk debugging

---

---

## 🔧 Backend Implementation Status (May 15, 2026)

✅ **IMPLEMENTED**:

- Token lookup by `refresh_token` hash
- Plain text token support (128 chars)
- Token normalization (SHA256 hashing)
- Proper validation with expiry check
- Cache cleared after changes

**Important**: Users dengan token lama HARUS login ulang untuk mendapatkan format token yang benar.

**Reference**: OAuth 2.0 RFC 6749, JWT Best Practices (RFC 8725)
Backend Details: `docs/REFRESH_TOKEN_FIX.md`
