# Backend Token Refresh Issues & Recommendations

**Status**: Issue Analysis & Resolution Plan  
**Date**: May 15, 2026  
**Priority**: High  
**Component**: Authentication & Token Management

---

## 📋 Executive Summary

**Masalah**: Aplikasi mobile terus-menerus mendapat response `401 Unauthenticated` saat mencoba refresh token, dengan pesan error:

```json
{
  "success": false,
  "message": "Refresh token tidak valid. Silakan login kembali."
}
```

**Root Cause**: Backend menolak refresh token yang sebelumnya berhasil di-issue, kemungkinan karena:

1. Refresh token sudah expired/di-revoke di database
2. Validasi refresh token tidak robust/tidak konsisten
3. Tidak ada mechanism untuk graceful token rotation
4. Token blacklist atau revocation tidak di-handle dengan baik

**Impact**:

- User terjebak dalam 401 loop dan tidak bisa melanjutkan
- User harus login ulang meski session seharusnya valid (90 hari)
- User experience buruk, frustasi

---

## 🔍 Root Cause Analysis

### Skenario yang Terjadi (dari log mobile)

```
1. User login → dapat access_token + refresh_token (valid)
2. Access token expiry → mobile request refresh
3. Backend return 401: "Refresh token tidak valid"
4. Mobile terus retry refresh dengan token yang sama
5. Setiap API request gagal 401, app tidak bisa clear session
6. User stuck di dashboard dengan semua request gagal
```

### Kemungkinan Penyebab

#### 1. **Refresh Token Expiry Issues**

```
Problem:
- Refresh token mungkin punya TTL lebih pendek dari expected
- Atau TTL tidak di-track dengan benar di database
- Token validity check tidak akurat

Evidence:
- Mobile log: Refresh token berhasil di-retrieve dari storage
- Tapi backend reject dengan 401
```

#### 2. **Database State Inconsistency**

```
Problem:
- Refresh token di-revoke/dihapus tapi mobile masih punya copy
- Migration atau cleanup script menghapus token tanpa notifikasi
- Race condition: token dihapus saat mobile sedang refresh

Evidence:
- Token sebelumnya valid (bisa login)
- Tapi sekarang suddenly "invalid"
```

#### 3. **Token Rotation Not Implemented**

```
Problem:
- Setiap refresh harus return NEW refresh token
- Tapi mungkin backend tidak issue new refresh token
- Mobile punya stale/old refresh token

Evidence:
- Log menunjukkan refresh token panjang (128 char)
- Tapi backend not accepting it
```

#### 4. **User/Device Mismatch**

```
Problem:
- Token di-link ke device/IP tertentu
- Device berubah atau IP change
- Validasi device/IP strict dan reject

Evidence:
- Mobile pakai emulator (IP bisa berubah)
- Atau device di-switch
```

#### 5. **No Rate Limiting / Spam Protection**

```
Problem:
- Mobile retry refresh terlalu banyak/cepat
- Backend blacklist token karena suspicious activity
- Token dianggap compromised/under attack

Evidence:
- Log menunjukkan many rapid refresh attempts
- Backend might have triggered security mechanism
```

---

## ✅ Rekomendasi Perbaikan Backend

### 1. **Implement Robust Token Rotation**

#### Masalah Saat Ini

```php
// ❌ TIDAK BAIK: Return token lama
public function refreshToken(Request $request)
{
    $refreshToken = $request->input('refresh_token');
    $token = Token::where('refresh_token', $refreshToken)->first();

    if (!$token || $token->expires_at < now()) {
        return response()->json(['message' => 'Refresh token tidak valid']);
    }

    // Return token lama, tidak generate baru
    return response()->json([
        'data' => [
            'access_token' => $token->access_token,
            'refresh_token' => $refreshToken // ❌ SAMA DENGAN SEBELUMNYA
        ]
    ]);
}
```

#### Solusi Rekomendasi

```php
// ✅ BAIK: Generate token baru setiap refresh
public function refreshToken(Request $request)
{
    $oldRefreshToken = $request->input('refresh_token');

    // 1. Validasi old refresh token
    $tokenRecord = Token::where('refresh_token', $oldRefreshToken)
        ->where('expires_at', '>', now())
        ->first();

    if (!$tokenRecord) {
        return response()->json(
            ['message' => 'Refresh token invalid or expired'],
            401
        );
    }

    $user = $tokenRecord->user;

    // 2. Invalidate old refresh token (revoke)
    $tokenRecord->update(['revoked' => true]);

    // 3. Generate NEW access token + refresh token
    $newAccessToken = $this->generateAccessToken($user);
    $newRefreshToken = $this->generateRefreshToken($user);

    // 4. Store new refresh token
    Token::create([
        'user_id' => $user->id,
        'access_token' => $newAccessToken,
        'refresh_token' => $newRefreshToken,
        'expires_at' => now()->addDays(90),
        'device_id' => $request->header('X-Device-ID'),
        'ip_address' => $request->ip(),
        'revoked' => false
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Token refreshed successfully',
        'data' => [
            'access_token' => $newAccessToken,
            'refresh_token' => $newRefreshToken,
            'expires_in' => 3600 // access token TTL in seconds
        ]
    ]);
}

private function generateAccessToken($user): string
{
    return bin2hex(random_bytes(25)); // 50 chars
}

private function generateRefreshToken($user): string
{
    return bin2hex(random_bytes(64)); // 128 chars
}
```

**Keuntungan:**

- ✅ Setiap refresh generate token baru (token rotation)
- ✅ Old token di-revoke = tidak bisa di-reuse
- ✅ Defense terhadap token theft
- ✅ Audit trail lebih jelas (tahu token mana yang active)

---

### 2. **Add Proper Token Validation Logic**

```php
// ✅ BAIK: Comprehensive validation
public function validateRefreshToken(string $token): ?Token
{
    return Token::where('refresh_token', $token)
        ->where('revoked', false) // ✅ Check revoked
        ->where('expires_at', '>', now()) // ✅ Check expiry
        ->whereNull('revoked_at') // ✅ Check revocation timestamp
        ->latest('created_at') // ✅ Get newest token
        ->first();
}
```

**Tambahkan column ke token table:**

```sql
ALTER TABLE tokens ADD COLUMN revoked_at TIMESTAMP NULL;
ALTER TABLE tokens ADD COLUMN revocation_reason VARCHAR(255) NULL;
ALTER TABLE tokens ADD COLUMN device_id VARCHAR(255) NULL;
ALTER TABLE tokens ADD COLUMN ip_address VARCHAR(45) NULL;

-- Index untuk query lebih cepat
CREATE INDEX idx_tokens_refresh_revoked_expires
ON tokens(refresh_token, revoked, expires_at);
```

---

### 3. **Implement Token Cleanup Strategy**

**Problem**: Stale tokens menumpuk di database, membuat query slow

```php
// ✅ BAIK: Cleanup task (jalankan daily)
// app/Console/Commands/CleanupExpiredTokens.php

namespace App\Console\Commands;

use App\Models\Token;
use Illuminate\Console\Command;

class CleanupExpiredTokens extends Command
{
    protected $signature = 'tokens:cleanup';
    protected $description = 'Remove expired and revoked tokens';

    public function handle()
    {
        // Delete expired tokens (older than 91 days)
        $deleted = Token::where('expires_at', '<', now())
            ->orWhere(function ($query) {
                $query->where('revoked', true)
                    ->where('revoked_at', '<', now()->subDays(7));
            })
            ->delete();

        $this->info("Deleted {$deleted} expired/revoked tokens");

        // Log untuk audit
        \Log::info("Token cleanup: {$deleted} tokens removed");
    }
}

// Schedule di: app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    $schedule->command('tokens:cleanup')->daily()->at('02:00');
}
```

---

### 4. **Add Comprehensive Error Handling & Logging**

```php
// ✅ BAIK: Detailed logging untuk debugging
public function refreshToken(Request $request)
{
    try {
        $userId = auth()->id();
        $oldRefreshToken = $request->input('refresh_token');
        $deviceId = $request->header('X-Device-ID');

        \Log::info('Token refresh attempt', [
            'user_id' => $userId,
            'token_hash' => hash('sha256', $oldRefreshToken), // ✅ Never log full token
            'device_id' => $deviceId,
            'ip_address' => $request->ip(),
            'timestamp' => now()
        ]);

        // Validation...
        $tokenRecord = Token::where('refresh_token', $oldRefreshToken)->first();

        if (!$tokenRecord) {
            \Log::warning('Refresh token not found in database', [
                'user_id' => $userId,
                'token_hash' => hash('sha256', $oldRefreshToken),
                'possible_causes' => [
                    'Token already revoked',
                    'Token deleted during cleanup',
                    'Token never existed',
                    'Database mismatch'
                ]
            ]);
            return response()->json(['message' => 'Invalid refresh token'], 401);
        }

        if ($tokenRecord->revoked) {
            \Log::warning('Attempt to use revoked token', [
                'user_id' => $userId,
                'revoked_at' => $tokenRecord->revoked_at,
                'revocation_reason' => $tokenRecord->revocation_reason
            ]);
            return response()->json(['message' => 'Token was revoked'], 401);
        }

        if ($tokenRecord->expires_at < now()) {
            \Log::info('Refresh token expired', [
                'user_id' => $userId,
                'expired_at' => $tokenRecord->expires_at,
                'days_since_expiry' => now()->diffInDays($tokenRecord->expires_at)
            ]);
            return response()->json(['message' => 'Token expired'], 401);
        }

        // Success - generate new tokens...
        \Log::info('Token refreshed successfully', [
            'user_id' => $userId,
            'device_id' => $deviceId
        ]);

    } catch (\Exception $e) {
        \Log::error('Token refresh error', [
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
        return response()->json(['message' => 'Server error'], 500);
    }
}
```

**Benefit**:

- ✅ Debug masalah lebih mudah
- ✅ Security audit trail
- ✅ Detect abuse patterns

---

### 5. **Implement Optional Device Binding (Strict Mode)**

```php
// ✅ BAIK: Opsi untuk strict device validation
public function validateTokenDevice(Token $token, Request $request): bool
{
    // Jika STRICT_DEVICE_VALIDATION = true
    if (!config('auth.strict_device_validation')) {
        return true; // Skip validation
    }

    $currentDeviceId = $request->header('X-Device-ID');

    // Token hanya bisa dipakai dari device yang sama
    if ($token->device_id && $token->device_id !== $currentDeviceId) {
        \Log::warning('Device mismatch for token', [
            'user_id' => $token->user_id,
            'stored_device_id' => $token->device_id,
            'current_device_id' => $currentDeviceId
        ]);
        return false;
    }

    return true;
}

// Usage di refreshToken:
if (!$this->validateTokenDevice($tokenRecord, $request)) {
    return response()->json(['message' => 'Device mismatch'], 401);
}
```

**Config:**

```php
// config/auth.php
return [
    'strict_device_validation' => env('AUTH_STRICT_DEVICE_VALIDATION', false),
    // Set false untuk development/testing
    // Set true untuk production (high security)
];
```

---

### 6. **Add Rate Limiting untuk Token Refresh**

```php
// ✅ BAIK: Prevent token refresh abuse
// app/Http/Middleware/RateLimitTokenRefresh.php

namespace App\Http\Middleware;

use Illuminate\Cache\RateLimiter;
use Closure;

class RateLimitTokenRefresh
{
    public function handle($request, Closure $next)
    {
        $userId = auth()->id();
        $limit = 10; // Max 10 refresh attempts
        $window = 3600; // Per hour

        $key = "token_refresh_{$userId}";

        if ($this->limiter->tooManyAttempts($key, $limit)) {
            \Log::warning('Token refresh rate limit exceeded', [
                'user_id' => $userId,
                'limit' => $limit,
                'window' => $window
            ]);

            return response()->json([
                'message' => 'Too many refresh attempts. Try again later.',
                'retry_after' => $this->limiter->availableIn($key)
            ], 429);
        }

        $this->limiter->hit($key, $window);

        return $next($request);
    }
}

// Register di Kernel: protected $routeMiddleware = ['rate.token' => RateLimitTokenRefresh::class]
// Use di route: Route::post('/refresh-token', [...])-> middleware('rate.token');
```

---

## 📊 Recommended Token Table Schema

```sql
CREATE TABLE tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    access_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE NOT NULL,

    -- Expiration
    expires_at TIMESTAMP NOT NULL,

    -- Revocation
    revoked BOOLEAN DEFAULT FALSE,
    revoked_at TIMESTAMP NULL,
    revocation_reason VARCHAR(255) NULL,

    -- Device & Security
    device_id VARCHAR(255) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    -- Indexes
    KEY idx_user_id (user_id),
    KEY idx_refresh_token (refresh_token),
    KEY idx_expires_revoked (expires_at, revoked),
    KEY idx_revoked_at (revoked_at),
    UNIQUE KEY idx_user_device_active (user_id, device_id, revoked)
);
```

---

## 🔐 Security Checklist

- [ ] **Token Rotation**: Setiap refresh harus generate token baru
- [ ] **Token Revocation**: Old token harus di-revoke, tidak bisa di-reuse
- [ ] **Token Validation**: Check expiry, revocation, device match
- [ ] **Rate Limiting**: Limit refresh attempts per user
- [ ] **Cleanup**: Remove expired tokens regularly
- [ ] **Logging**: Comprehensive audit trail untuk semua token operations
- [ ] **HTTPS Only**: Tokens hanya transfer via HTTPS
- [ ] **HttpOnly Cookies**: Jika mobile -> app tidak handle cookies (ok)
- [ ] **CORS**: Validate origin jika web app

---

## 📈 Implementation Timeline

### Phase 1: Immediate Fixes (Week 1)

1. ✅ Implement token rotation (new tokens setiap refresh)
2. ✅ Add proper validation logic (revoked check)
3. ✅ Add comprehensive logging

### Phase 2: Robustness (Week 2)

4. ✅ Implement token cleanup task
5. ✅ Add rate limiting
6. ✅ Add device binding (optional)

### Phase 3: Monitoring (Week 3)

7. ✅ Setup alerts untuk token refresh failures
8. ✅ Dashboard untuk token metrics
9. ✅ Security audit

---

## 🧪 Testing Strategy

```php
// tests/Feature/TokenRefreshTest.php

class TokenRefreshTest extends TestCase
{
    /** @test */
    public function user_can_refresh_token()
    {
        $user = User::factory()->create();
        $oldToken = $this->generateToken($user);

        $response = $this->postJson('/api/v1/auth/refresh-token', [
            'refresh_token' => $oldToken->refresh_token
        ]);

        $response->assertOk();
        $response->assertJsonStructure([
            'data' => ['access_token', 'refresh_token', 'expires_in']
        ]);

        // ✅ Old token should be revoked
        $this->assertTrue($oldToken->refresh()->revoked);
    }

    /** @test */
    public function cannot_refresh_with_revoked_token()
    {
        $token = Token::factory()->create(['revoked' => true]);

        $response = $this->postJson('/api/v1/auth/refresh-token', [
            'refresh_token' => $token->refresh_token
        ]);

        $response->assertUnauthorized();
    }

    /** @test */
    public function cannot_refresh_with_expired_token()
    {
        $token = Token::factory()->create(['expires_at' => now()->subDay()]);

        $response = $this->postJson('/api/v1/auth/refresh-token', [
            'refresh_token' => $token->refresh_token
        ]);

        $response->assertUnauthorized();
    }

    /** @test */
    public function rate_limiting_works()
    {
        $user = User::factory()->create();
        $token = $this->generateToken($user);

        // Attempt 11 times (limit is 10)
        for ($i = 0; $i < 11; $i++) {
            $response = $this->postJson('/api/v1/auth/refresh-token', [
                'refresh_token' => $token->refresh_token
            ]);
        }

        // 11th attempt should be rate limited
        $response->assertStatus(429);
    }
}
```

---

## 📞 Troubleshooting Guide

| Error                       | Cause               | Solution                                             |
| --------------------------- | ------------------- | ---------------------------------------------------- |
| "Refresh token tidak valid" | Token not found     | Check if token exists in DB, verify token string     |
| "Refresh token tidak valid" | Token revoked       | Check revoked flag, when was it revoked?             |
| "Refresh token tidak valid" | Token expired       | Check expires_at, compare with server time           |
| Too many 401 errors         | Rate limit hit      | Wait 1 hour, or raise limit                          |
| Different device error      | Device mismatch     | Disable strict device validation or update device ID |
| Tokens keep accumulating    | Cleanup not running | Check if cleanup task is scheduled and running       |

---

## 📝 Migration Script

```php
// database/migrations/2026_05_15_add_token_improvements.php

public function up()
{
    Schema::table('tokens', function (Blueprint $table) {
        // Jika kolom belum ada, tambahkan
        if (!Schema::hasColumn('tokens', 'revoked')) {
            $table->boolean('revoked')->default(false);
        }
        if (!Schema::hasColumn('tokens', 'revoked_at')) {
            $table->timestamp('revoked_at')->nullable();
        }
        if (!Schema::hasColumn('tokens', 'device_id')) {
            $table->string('device_id')->nullable();
        }
        if (!Schema::hasColumn('tokens', 'ip_address')) {
            $table->ipAddress('ip_address')->nullable();
        }
    });
}

public function down()
{
    // Rollback jika diperlukan
}
```

---

## ✨ Hasil yang Diharapkan

Setelah implementasi rekomendasi ini:

✅ **User tidak akan stuck di 401 loop**

- Token refresh mechanism robust dan reliable
- Clear error messages untuk debugging

✅ **Better security**

- Token rotation prevents token theft
- Rate limiting prevents abuse
- Device binding adds extra layer

✅ **Better observability**

- Comprehensive logging untuk debugging
- Easy to track token lifecycle
- Security audit trail

✅ **Better performance**

- Regular cleanup prevents DB bloat
- Efficient queries dengan proper indexes

✅ **Better user experience**

- Persistent login works reliably
- No unexpected logouts
- Clear feedback when session invalid

---

**Next Step**: Schedule implementation meeting dengan backend team untuk discuss priority & timeline.
