# Token Refresh: Quick Implementation Guide

**Target**: Solve "Refresh token tidak valid" 401 errors within 1 day

---

## 🚀 Quick Wins (Do First)

### 1. Add Better Error Logging (30 mins)

**File**: `app/Http/Controllers/AuthController.php`

```php
public function refreshToken(Request $request)
{
    $token = $request->input('refresh_token');

    // ✅ Log token refresh attempt
    \Log::info('Token refresh request', [
        'token_hash' => hash('sha256', $token),
        'user_id' => auth()->id(),
        'ip' => $request->ip(),
        'user_agent' => $request->header('User-Agent')
    ]);

    // Cek di database
    $tokenRecord = DB::table('tokens')
        ->where('refresh_token', $token)
        ->first();

    // ✅ Detailed error logging
    if (!$tokenRecord) {
        \Log::warning('Refresh token not found', [
            'token_hash' => hash('sha256', $token)
        ]);
        return response()->json(['message' => 'Refresh token tidak valid'], 401);
    }

    if ($tokenRecord->revoked) {
        \Log::warning('Attempt to use revoked token', [
            'user_id' => $tokenRecord->user_id,
            'revoked_at' => $tokenRecord->revoked_at ?? 'unknown'
        ]);
        return response()->json(['message' => 'Refresh token tidak valid'], 401);
    }

    if (strtotime($tokenRecord->expires_at) < time()) {
        \Log::info('Refresh token expired', [
            'user_id' => $tokenRecord->user_id,
            'expired_at' => $tokenRecord->expires_at
        ]);
        return response()->json(['message' => 'Refresh token tidak valid'], 401);
    }

    // ✅ Success logging
    \Log::info('Token refreshed successfully', [
        'user_id' => $tokenRecord->user_id
    ]);

    // ... continue with token refresh logic
}
```

**Check logs**:

```bash
tail -f storage/logs/laravel.log | grep "token"
```

---

### 2. Check Token Table Schema (15 mins)

```sql
-- Run this query to see current state
DESCRIBE tokens;

-- Should have columns:
-- - id (PK)
-- - user_id (FK)
-- - access_token
-- - refresh_token
-- - expires_at
-- - revoked (OPTIONAL)
-- - revoked_at (OPTIONAL)
-- - created_at
-- - updated_at

-- Add missing columns if needed:
ALTER TABLE tokens ADD COLUMN revoked BOOLEAN DEFAULT FALSE;
ALTER TABLE tokens ADD COLUMN revoked_at TIMESTAMP NULL;

-- Add index for faster queries:
CREATE INDEX idx_refresh_token_revoked
ON tokens(refresh_token, revoked);

CREATE INDEX idx_expires_at
ON tokens(expires_at);
```

---

### 3. Implement Token Revocation on Refresh (1 hour)

**Current Problem**: Old token tetap valid setelah refresh
**Solution**: Revoke old token saat generate token baru

```php
// app/Http/Controllers/AuthController.php

public function refreshToken(Request $request)
{
    $oldRefreshToken = $request->input('refresh_token');

    // Validate old token
    $oldToken = DB::table('tokens')
        ->where('refresh_token', $oldRefreshToken)
        ->where('revoked', false)
        ->where('expires_at', '>', now())
        ->first();

    if (!$oldToken) {
        return response()->json(['message' => 'Token invalid atau expired'], 401);
    }

    // ✅ PENTING: Revoke old token SEBELUM generate yang baru
    DB::table('tokens')
        ->where('id', $oldToken->id)
        ->update([
            'revoked' => true,
            'revoked_at' => now(),
            'revocation_reason' => 'Token refreshed'
        ]);

    // Generate NEW tokens
    $newAccessToken = Str::random(50);
    $newRefreshToken = Str::random(128);

    // Save new token to database
    DB::table('tokens')->insert([
        'user_id' => $oldToken->user_id,
        'access_token' => $newAccessToken,
        'refresh_token' => $newRefreshToken,
        'expires_at' => now()->addDays(90),
        'revoked' => false,
        'created_at' => now(),
        'updated_at' => now()
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Token refreshed successfully',
        'data' => [
            'access_token' => $newAccessToken,
            'refresh_token' => $newRefreshToken,
            'expires_in' => 3600
        ]
    ]);
}
```

---

### 4. Query to Find Problematic Tokens (5 mins)

Jalankan queries ini untuk debug:

```sql
-- 1. Check if refresh token exists
SELECT * FROM tokens
WHERE refresh_token = 'YOUR_TOKEN_HERE';

-- 2. Check if user has valid refresh token
SELECT * FROM tokens
WHERE user_id = 5
AND revoked = FALSE
AND expires_at > NOW()
ORDER BY created_at DESC;

-- 3. Count expired tokens (should be cleaned up)
SELECT COUNT(*) as expired_count
FROM tokens
WHERE expires_at < NOW();

-- 4. Check revoked tokens
SELECT COUNT(*) as revoked_count
FROM tokens
WHERE revoked = TRUE;

-- 5. See recent token activity for specific user
SELECT user_id, refresh_token, revoked, expires_at, created_at
FROM tokens
WHERE user_id = 5
ORDER BY created_at DESC
LIMIT 10;
```

---

### 5. Add Database Cleanup Task (1 hour)

**File**: `app/Console/Commands/CleanupExpiredTokens.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CleanupExpiredTokens extends Command
{
    protected $signature = 'tokens:cleanup';
    protected $description = 'Delete expired and revoked tokens older than 7 days';

    public function handle()
    {
        $before = DB::table('tokens')->count();

        // Delete tokens expired more than 90 days ago
        $deleted1 = DB::table('tokens')
            ->where('expires_at', '<', now()->subDays(90))
            ->delete();

        // Delete tokens revoked more than 7 days ago
        $deleted2 = DB::table('tokens')
            ->where('revoked', true)
            ->where('revoked_at', '<', now()->subDays(7))
            ->delete();

        $after = DB::table('tokens')->count();
        $totalDeleted = $deleted1 + $deleted2;

        $this->info("✅ Token cleanup completed");
        $this->info("Tokens before: {$before}");
        $this->info("Tokens deleted: {$totalDeleted}");
        $this->info("Tokens after: {$after}");

        \Log::info('Token cleanup', [
            'deleted' => $totalDeleted,
            'before' => $before,
            'after' => $after
        ]);
    }
}
```

**Register task**:

```php
// app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    $schedule->command('tokens:cleanup')->daily()->at('02:00');
}
```

**Test**:

```bash
php artisan tokens:cleanup
```

---

## 📋 Implementation Checklist

- [ ] Add logging untuk token refresh operations
- [ ] Check token table schema (add revoked, revoked_at if missing)
- [ ] Add indexes untuk performance
- [ ] Implement token revocation on refresh
- [ ] Test dengan manual curl request
- [ ] Setup cleanup task
- [ ] Deploy ke staging
- [ ] Test dengan mobile app
- [ ] Monitor logs untuk errors
- [ ] Deploy ke production

---

## 🧪 Manual Testing

### Test dengan cURL

```bash
# 1. Login untuk dapat tokens
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Response:
# {
#   "data": {
#     "access_token": "abc123...",
#     "refresh_token": "def456..."
#   }
# }

# 2. Refresh token (SAVE refresh_token dari step 1)
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "def456..."
  }'

# 3. Refresh lagi dengan token lama (should fail)
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "def456..."  # Token lama, sudah di-revoke
  }'

# Should return 401:
# {
#   "message": "Token invalid atau expired"
# }

# 4. Refresh dengan token baru dari step 2 (should work)
curl -X POST http://10.0.2.2:8000/api/v1/motorcycle/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "new_token_dari_step_2"
  }'
```

---

## 🔍 Verification Checklist

Setelah implementasi, verify:

```sql
-- 1. Check revoked tokens exist
SELECT COUNT(*) as revoked FROM tokens WHERE revoked = TRUE;
-- Expected: > 0 (ada tokens yang pernah di-revoke)

-- 2. Check token rotation works
SELECT DISTINCT user_id FROM tokens
WHERE created_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)
AND revoked = FALSE;
-- Expected: token baru ada di database

-- 3. Check cleanup is working
SELECT COUNT(*) as old_tokens FROM tokens
WHERE expires_at < NOW();
-- Expected: 0 atau sangat sedikit (kebanyakan sudah di-cleanup)

-- 4. Check specific user tokens
SELECT refresh_token, revoked, expires_at, created_at FROM tokens
WHERE user_id = 5
ORDER BY created_at DESC
LIMIT 10;
-- Expected: Lihat pattern token rotation (old=revoked, new=active)
```

---

## 🐛 Debugging Tips

**If mobile still gets 401 after refresh:**

```sql
-- Check exact token yang dipakai mobile
SELECT * FROM tokens
WHERE refresh_token = 'EXACT_TOKEN_FROM_MOBILE_LOG'
AND user_id = 5;

-- Possible outcomes:
-- 1. NULL result → Token tidak ada di database
--    → Check apakah logout/cleanup menghapusnya
--
-- 2. revoked=1 → Token di-revoke (expected if di-refresh)
--    → Mobile perlu gunakan token baru dari refresh response
--
-- 3. expires_at < NOW() → Token sudah expired
--    → Check expiry logic, TTL mungkin terlalu pendek
--
-- 4. revoked=0, expires_at > NOW() → Token valid tapi error
--    → Check validation logic, mungkin ada bug di code
```

**Monitor logs realtime:**

```bash
# Terminal 1: Monitor semua token operations
tail -f storage/logs/laravel.log | grep -E "(refresh|token|401)"

# Terminal 2: Run mobile app dan trigger refresh
# Lihat log output untuk melihat step-by-step apa yang terjadi
```

---

## 📊 Success Metrics

Setelah fix, track:

```sql
-- Daily successful refreshes
SELECT DATE(created_at) as date, COUNT(*) as refreshes
FROM tokens
WHERE revoked = FALSE
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Failed refresh rate (via logging)
SELECT COUNT(*) as failed_refreshes
FROM logs
WHERE message LIKE '%refresh%'
AND level = 'warning'
AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR);

-- Active sessions (non-revoked, non-expired)
SELECT COUNT(*) as active_sessions
FROM tokens
WHERE revoked = FALSE
AND expires_at > NOW();
```

---

## 📞 Escalation Path

Jika masalah terus terjadi:

1. **Check logs** - Lihat exact error message
2. **Query database** - Verify token ada/tidak ada
3. **Manual test** - cURL request untuk isolate issue
4. **Code review** - Lihat validation logic
5. **Database integrity** - Check constraints, corrupted data

---

## ⚡ One-Day Implementation Plan

**Morning (2 hours)**:

- [ ] Add logging (30 mins)
- [ ] Check schema & add columns (15 mins)
- [ ] Add index (10 mins)
- [ ] Test dengan cURL (45 mins)

**Afternoon (2 hours)**:

- [ ] Implement token revocation (1 hour)
- [ ] Setup cleanup task (30 mins)
- [ ] Deploy & test dengan mobile (30 mins)

**Total**: ~4 hours untuk production-ready solution

---

## ⚠️ BACKEND FIX IMPLEMENTED (May 15, 2026)

**Status**: ✅ DONE - Backend sudah implement refresh token fix!

**What Was Fixed**:

- Backend now finds user by `refresh_token` (tidak perlu email/session lama)
- Supports 128-char plain text tokens (Flutter format)
- Automatic token hashing (SHA256) untuk security
- Proper token validation (check expiry)

**Action for Users**:

- User yang punya token lama (64-char hashed) HARUS login ulang
- After login: will receive 128-char plain text token
- After logout/login: refresh token akan work automatically every 30 mins

**Reference**: Lihat `docs/REFRESH_TOKEN_FIX.md` untuk detail backend changes

**Next**: Inform frontend team bahwa backend sudah fixed, users perlu login ulang.
