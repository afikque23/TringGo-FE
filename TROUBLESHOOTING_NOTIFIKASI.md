# 🔧 Troubleshooting: Notifikasi Tidak Muncul di Flutter

## 🚨 Problem: "Notifikasi berhasil di Postman tapi tidak masuk ke Flutter"

### ✅ Yang Sudah Benar:

- Firebase initialized successfully ✅
- FCM Token registered ✅
- NotificationService initialized ✅
- Postman API call berhasil (200 OK) ✅

### ❌ Masalah:

- Notifikasi count: **0** (tidak muncul di Flutter)
- Push notification tidak muncul

---

## 🔍 Root Cause Analysis

### Scenario 1: **Guest Mode vs Authenticated Mode** (PALING SERING!)

**Deteksi:**

```
Log Flutter menunjukkan:
👤 Auth mode: GUEST (device: d40436f2-ec64-44f2-b8be-d0f65754607c)
```

**Problem:**

- Flutter app sedang buka sebagai **GUEST** (device ID: `d40436f2-ec64-44f2-b8be-d0f65754607c`)
- Postman test pakai **Authorization: Bearer TOKEN** → Kirim ke user account
- Notifikasi masuk ke **user account**, tapi Flutter fetch pakai **device ID guest** → 0 results

**Solusi A: Test dengan Guest Mode di Postman**

```bash
# Jangan pakai Authorization header
# Gunakan X-Device-ID header

curl -X GET "http://localhost/api/v1/motorcycle/notifications" \
  -H "X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c" \
  -H "Accept: application/json"
```

**Solusi B: Login di Flutter App**

1. Buka Flutter app
2. **Login** dengan akun user yang sama dengan token Postman
3. Test lagi di Postman dengan token yang sama
4. Refresh halaman notifikasi di Flutter

**Solusi C: Kirim Notifikasi ke Guest Device**

**Via Admin Panel:**

1. Menu: Notifikasi → Kirim Notifikasi
2. Mode: **Guest**
3. Device ID: `d40436f2-ec64-44f2-b8be-d0f65754607c` (copy dari log Flutter)
4. Kirim

**Via Postman:**

```bash
# Contoh: Kirim notifikasi ke guest device
POST http://localhost/api/v1/motorcycle/notifications/send-to-device

Headers:
- Content-Type: application/json

Body:
{
  "device_id": "d40436f2-ec64-44f2-b8be-d0f65754607c",
  "title": "Test Notifikasi Guest",
  "message": "Ini notifikasi untuk guest device",
  "category": "system"
}
```

---

### Scenario 2: **Backend Tidak Save ke Database**

**Problem:**

- API return success
- Push notification terkirim via FCM
- **TAPI** notifikasi tidak disimpan ke database
- Flutter fetch dari database → 0 results

**Check:**

**1. Verify di Database:**

```sql
-- Check apakah notifikasi tersimpan
SELECT * FROM notifications
WHERE created_at > NOW() - INTERVAL 5 MINUTE
ORDER BY created_at DESC;

-- Check by device_id (guest mode)
SELECT * FROM notifications
WHERE device_id = 'd40436f2-ec64-44f2-b8be-d0f65754607c'
ORDER BY created_at DESC;
```

**2. Check Backend Response:**

```json
// Response dari Postman harus menunjukkan notification_id
{
  "success": true,
  "message": "Notification sent successfully",
  "data": {
    "id": 123, // ← Pastikan ada ID (artinya tersimpan)
    "title": "Test",
    "category": "service"
  }
}
```

**Jika tidak ada ID di response:**
→ Backend hanya kirim push notification, tidak save ke database
→ Perlu fix di backend Laravel

---

### Scenario 3: **Filter/Query Tidak Match**

**Problem:**

- Notifikasi tersimpan di database
- Tapi Flutter query pakai filter yang tidak match

**Check di Postman:**

**Query 1: Get All (tanpa filter)**

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications" \
  -H "X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c"
```

**Query 2: Specific category**

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service" \
  -H "X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c"
```

**Expected:**

```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "title": "Test",
      "category_key": "service",
      "is_read": false
    }
  ],
  "unread_count": 1
}
```

**Jika masih 0:**
→ Notifikasi tidak disimpan dengan device_id yang benar

---

### Scenario 4: **Backend API Error (Silent Fail)**

**Problem:**

- Flutter call API tapi dapat error 500/404
- Error tidak ditampilkan di UI
- User lihat 0 notifikasi

**Check di Flutter Console:**

```
Cari log error:
"Failed to fetch notifications:"
"HTTP Error: 500"
"Exception:"
```

**Jika ada error:**
→ Backend ada masalah
→ Check Laravel log: `storage/logs/laravel.log`

---

## 🎯 Quick Fix Step-by-Step

### Fix 1: Test dengan Device ID yang Benar

**Step 1: Copy Device ID dari Flutter**

```
Log Flutter:
👤 Auth mode: GUEST (device: d40436f2-ec64-44f2-b8be-d0f65754607c)
                              ↑↑↑ Copy this ↑↑↑
```

**Step 2: Test di Postman dengan Device ID**

```bash
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/notifications" \
  -H "X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c" \
  -H "Accept: application/json"
```

**Expected:**

```json
{
  "success": true,
  "data": [...], // ← Harus ada data jika notifikasi sudah dikirim
  "unread_count": 1
}
```

---

### Fix 2: Kirim Notifikasi ke Guest Device

**Option A: Via Postman**

**1. Register Device Token (jika belum):**

```bash
curl -X POST "http://10.0.2.2:8000/api/v1/motorcycle/device-tokens/register" \
  -H "X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c" \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "e1lYGTQuSvadNWHWx2WeYp:APA91bHA-iLm77rDT...",
    "platform": "android",
    "device_name": "Test Device"
  }'
```

**2. Trigger Notifikasi (Odometer Update):**

```bash
curl -X POST "http://10.0.2.2:8000/api/v1/motorcycle/vehicles/10/odometer" \
  -H "X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c" \
  -H "Content-Type: application/json" \
  -d '{
    "distance_km": 25.5,
    "notes": "Test notifikasi guest"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Odometer updated successfully",
  "notification": {
    "id": 124, // ← Notifikasi otomatis terkirim
    "title": "Jarak Ditambahkan",
    "category": "trip"
  }
}
```

**3. Verify di Flutter:**

- Pull-to-refresh di halaman notifikasi
- Lihat badge count bertambah
- Tab "Perjalanan" ada notifikasi baru

---

**Option B: Via Admin Panel (Lebih Mudah!)**

1. **Login admin panel:** `http://localhost/admin/login`
2. **Menu:** Notifikasi → Kirim Notifikasi
3. **Pilih:**
   - Mode: **Guest**
   - Device ID: `d40436f2-ec64-44f2-b8be-d0f65754607c`
   - Template: (pilih template)
   - Kategori: Service/Trip/Alert
4. **Klik:** "Kirim"
5. **Verify di Flutter:** Refresh halaman notifikasi

---

### Fix 3: Login di Flutter, Test dengan User Token

**Step 1: Login di Flutter**

1. Buka Flutter app
2. Tap "Login" (bukan guest)
3. Masukkan email/password
4. Login berhasil

**Step 2: Get Token dari Flutter**

- Check console log:
  ```
  🔍 CURRENT AUTH STATUS
  Token: eyJ0eXAiOiJKV1Qi...  ← Copy this
  ```

**Step 3: Test di Postman dengan Token**

```bash
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/notifications" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1Qi..." \
  -H "Accept: application/json"
```

**Step 4: Kirim Notifikasi ke User**

```bash
curl -X POST "http://10.0.2.2:8000/api/v1/motorcycle/vehicles/10/odometer" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1Qi..." \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 30}'
```

**Step 5: Verify di Flutter**

- Pull-to-refresh
- Notifikasi muncul ✅

---

## 📝 Verification Checklist

### Backend Verification

- [ ] **Database:** Notifikasi tersimpan?

  ```sql
  SELECT COUNT(*) FROM notifications WHERE created_at > NOW() - INTERVAL 1 HOUR;
  ```

- [ ] **Device Token:** FCM token registered?

  ```sql
  SELECT * FROM device_tokens WHERE fcm_token LIKE 'e1lYGTQuSva%';
  ```

- [ ] **User/Device Match:** Notifikasi punya device_id yang benar?

  ```sql
  SELECT id, title, device_id, user_id FROM notifications ORDER BY created_at DESC LIMIT 5;
  ```

- [ ] **Postman Response:** Ada notification ID di response?
  ```json
  {"data": {"id": 123}}  ← Harus ada
  ```

### Flutter Verification

- [ ] **Firebase Status:**

  ```
  ✅ Firebase initialized successfully
  ✅ FCM Token registered
  ✅ NotificationService initialized successfully
  ```

- [ ] **Device ID/Token:**

  ```
  Check log:
  👤 Auth mode: GUEST (device: ...)
  📱 FCM Token: ...
  ```

- [ ] **API Call Success:**

  ```
  ✅ Loaded X notifications  ← Harus > 0 jika ada notifikasi
  ```

- [ ] **Pull-to-Refresh:** Sudah coba refresh?

---

## 🎯 Recommended Testing Flow

### Test 1: Guest Mode (Paling Mudah untuk Debug)

```bash
# 1. Copy device ID dari Flutter log
DEVICE_ID="d40436f2-ec64-44f2-b8be-d0f65754607c"

# 2. Check current notifications
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/notifications" \
  -H "X-Device-ID: $DEVICE_ID"

# 3. Trigger notifikasi baru
curl -X POST "http://10.0.2.2:8000/api/v1/motorcycle/vehicles/10/odometer" \
  -H "X-Device-ID: $DEVICE_ID" \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 25.5}'

# 4. Check lagi (harus bertambah)
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/notifications" \
  -H "X-Device-ID: $DEVICE_ID"

# Expected: data array > 0, unread_count > 0
```

### Test 2: Authenticated Mode

```bash
# 1. Login untuk get token
curl -X POST "http://10.0.2.2:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

# Response: {"token": "eyJ0..."}

# 2. Set token
TOKEN="eyJ0eXAiOiJKV1Qi..."

# 3. Check notifications
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/notifications" \
  -H "Authorization: Bearer $TOKEN"

# 4. Trigger notifikasi
curl -X POST "http://10.0.2.2:8000/api/v1/motorcycle/vehicles/10/odometer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 30}'

# 5. Check lagi
curl -X GET "http://10.0.2.2:8000/api/v1/motorcycle/notifications?unread=true" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🔍 Debug Mode

### Enable Debug di Flutter

**File:** `lib/core/services/notification_api_service.dart`

**Tambahkan print debug:**

```dart
static Future<NotificationListResponse> getNotifications({...}) async {
  print('🔍 DEBUG: Calling API...');
  print('URL: $url');
  print('Headers: $headers');

  final response = await http.get(url, headers: headers);

  print('📥 Response status: ${response.statusCode}');
  print('📥 Response body: ${response.body}');

  // ...rest of code
}
```

**Expected Console Output:**

```
🔍 DEBUG: Calling API...
URL: http://10.0.2.2:8000/api/v1/motorcycle/notifications
Headers: {X-Device-ID: d40436f2-ec64-44f2-b8be-d0f65754607c}
📥 Response status: 200
📥 Response body: {"success":true,"data":[...],"unread_count":5}
```

---

## ✅ Success Indicators

**Notifikasi berhasil jika:**

1. ✅ **Postman Response:**

   ```json
   {
     "success": true,
     "data": [
       {
         "id": 123, // ← Ada ID
         "title": "Test",
         "is_read": false
       }
     ],
     "unread_count": 1 // ← > 0
   }
   ```

2. ✅ **Flutter Console:**

   ```
   ✅ Loaded 1 notifications  // ← > 0
   📊 Unread count: 1
   ```

3. ✅ **Flutter UI:**
   - Badge count > 0
   - Notifikasi muncul di list
   - Kategori filter berfungsi

4. ✅ **Database:**
   ```sql
   SELECT COUNT(*) FROM notifications;
   -- Result: > 0
   ```

---

## 📱 Quick Test Commands (Copy-Paste)

**Windows PowerShell:**

```powershell
# Set variables
$DEVICE_ID = "d40436f2-ec64-44f2-b8be-d0f65754607c"
$BASE_URL = "http://10.0.2.2:8000/api/v1/motorcycle"

# Check notifications
curl -X GET "$BASE_URL/notifications" -H "X-Device-ID: $DEVICE_ID"

# Trigger notifikasi
curl -X POST "$BASE_URL/vehicles/10/odometer" `
  -H "X-Device-ID: $DEVICE_ID" `
  -H "Content-Type: application/json" `
  -d '{\"distance_km\": 25.5}'

# Verify
curl -X GET "$BASE_URL/notifications?unread=true" -H "X-Device-ID: $DEVICE_ID"
```

**Linux/Mac:**

```bash
# Set variables
DEVICE_ID="d40436f2-ec64-44f2-b8be-d0f65754607c"
BASE_URL="http://10.0.2.2:8000/api/v1/motorcycle"

# Check notifications
curl -X GET "$BASE_URL/notifications" \
  -H "X-Device-ID: $DEVICE_ID"

# Trigger notifikasi
curl -X POST "$BASE_URL/vehicles/10/odometer" \
  -H "X-Device-ID: $DEVICE_ID" \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 25.5}'

# Verify
curl -X GET "$BASE_URL/notifications?unread=true" \
  -H "X-Device-ID: $DEVICE_ID"
```

---

## 🎉 Expected Result

**Setelah fix, harusnya:**

1. ✅ Postman GET notifications → Response punya data
2. ✅ Flutter pull-to-refresh → Badge count bertambah
3. ✅ Notifikasi muncul di tab yang sesuai
4. ✅ Push notification muncul (jika backend FCM configured)
5. ✅ Mark as read → Badge count berkurang

---

**Masih bermasalah? Check:**

1. Laravel log: `storage/logs/laravel.log`
2. Flutter console: Cari error "Failed to..."
3. Database: Query manual untuk verify data
4. Postman: Pastikan endpoint & headers benar

Good luck! 🚀
