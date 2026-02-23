# 🚀 Quick Test Commands - Notifikasi

## 📋 Prerequisites

```bash
# Set environment variables (Windows)
set BASE_URL=http://localhost/api/v1/motorcycle
set TOKEN=your-jwt-token-here
set DEVICE_ID=your-device-uuid-here

# Linux/Mac
export BASE_URL=http://localhost/api/v1/motorcycle
export TOKEN=your-jwt-token-here
export DEVICE_ID=your-device-uuid-here
```

---

## 🧪 Test 1: Get All Notifications

### Windows (PowerShell)

```powershell
curl -X GET "http://localhost/api/v1/motorcycle/notifications" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

### Expected Output

```json
{
  "success": true,
  "data": [
    {
      "id": 15,
      "category_key": "trip",
      "category_name": "Perjalanan",
      "title": "Perjalanan Selesai",
      "is_read": false
    }
  ],
  "unread_count": 5
}
```

---

## 🔧 Test 2: Filter by Category - Service

### Windows

```powershell
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service&per_page=20" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service&per_page=20" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## 🛣️ Test 3: Filter by Category - Trip

### Windows

```powershell
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## 📊 Test 4: Filter Unread Only

### Windows

```powershell
curl -X GET "http://localhost/api/v1/motorcycle/notifications?unread=true" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications?unread=true" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## ⭐ Test 5: Kombinasi - Service + Unread

### Windows

```powershell
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service&unread=true" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service&unread=true" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## 📌 Test 6: Mark as Read

### Windows

```powershell
curl -X POST "http://localhost/api/v1/motorcycle/notifications/15/read" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X POST "http://localhost/api/v1/motorcycle/notifications/15/read" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## ✅ Test 7: Mark All as Read

### Windows

```powershell
curl -X POST "http://localhost/api/v1/motorcycle/notifications/mark-all-read" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Accept: application/json"
```

### Linux/Mac

```bash
curl -X POST "http://localhost/api/v1/motorcycle/notifications/mark-all-read" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## 🚗 Test 8: Trigger Notifikasi - Add Odometer

**Ini akan trigger notifikasi otomatis!**

### Windows

```powershell
curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -d '{\"distance_km\": 25.5, \"notes\": \"Test dari curl\"}'
```

### Linux/Mac

```bash
curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "distance_km": 25.5,
    "notes": "Test dari curl"
  }'
```

### Expected Result

```json
{
  "success": true,
  "message": "Odometer updated successfully",
  "data": {
    "vehicle_id": 1,
    "odometer": 5375.5
  }
}
```

**Lalu cek notifikasi:**

```bash
# Akan muncul notifikasi kategori "trip"
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🛣️ Test 9: Trigger Notifikasi - Start & Finish Trip

### Step 1: Start Trip

**Windows:**

```powershell
curl -X POST "http://localhost/api/v1/motorcycle/trips" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Content-Type: application/json" `
  -d '{\"vehicle_id\": 1, \"start_latitude\": -6.2088, \"start_longitude\": 106.8456, \"start_address\": \"Jakarta\", \"tracking_mode\": \"gps\"}'
```

**Linux/Mac:**

```bash
curl -X POST "http://localhost/api/v1/motorcycle/trips" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_id": 1,
    "start_latitude": -6.2088,
    "start_longitude": 106.8456,
    "start_address": "Jakarta Pusat",
    "tracking_mode": "gps"
  }'
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 25,
    "vehicle_id": 1,
    "status": "in_progress"
  }
}
```

**Copy trip ID dari response!**

---

### Step 2: Finish Trip (Trigger Notifikasi!)

**Windows:**

```powershell
curl -X POST "http://localhost/api/v1/motorcycle/trips/25/finish" `
  -H "Authorization: Bearer YOUR_TOKEN" `
  -H "Content-Type: application/json" `
  -d '{\"end_latitude\": -6.1751, \"end_longitude\": 106.8650, \"end_address\": \"Monas\", \"distance\": 15.5, \"duration_minutes\": 25, \"average_speed\": 37.2}'
```

**Linux/Mac:**

```bash
curl -X POST "http://localhost/api/v1/motorcycle/trips/25/finish" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "end_latitude": -6.1751,
    "end_longitude": 106.8650,
    "end_address": "Monas, Jakarta",
    "distance": 15.5,
    "duration_minutes": 25,
    "average_speed": 37.2
  }'
```

**Response:**

```json
{
  "success": true,
  "message": "Trip completed successfully",
  "data": {
    "id": 25,
    "status": "completed",
    "distance": 15.5
  }
}
```

---

### Step 3: Verify Notifikasi Trip

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true" \
  -H "Authorization: Bearer $TOKEN"
```

**Expected:**

```json
{
  "data": [
    {
      "id": 16,
      "category_key": "trip",
      "title": "Perjalanan Selesai",
      "message": "✅ Perjalanan selesai! Honda Beat menempuh 15.5 km dalam 25 menit. Kecepatan rata-rata: 37.2 km/h.",
      "is_read": false,
      "created_at": "2026-02-19T15:00:00+07:00"
    }
  ]
}
```

---

## 👤 Test 10: Guest Mode (Tanpa Login)

### Register Device Token

**Windows:**

```powershell
curl -X POST "http://localhost/api/v1/motorcycle/device-tokens/register" `
  -H "X-Device-ID: guest-device-12345-abcdef" `
  -H "Content-Type: application/json" `
  -d '{\"fcm_token\": \"fake-token-testing-123\", \"platform\": \"android\", \"device_name\": \"Test Device\"}'
```

**Linux/Mac:**

```bash
curl -X POST "http://localhost/api/v1/motorcycle/device-tokens/register" \
  -H "X-Device-ID: guest-device-12345-abcdef" \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "fake-token-testing-123",
    "platform": "android",
    "device_name": "Test Device"
  }'
```

### Get Notifications (Guest)

```bash
curl -X GET "http://localhost/api/v1/motorcycle/notifications" \
  -H "X-Device-ID: guest-device-12345-abcdef" \
  -H "Accept: application/json"
```

---

## 📊 Test 11: Get Badge Counts untuk Semua Kategori

**Cara 1: Manual per kategori**

```bash
# All
curl -X GET "http://localhost/api/v1/motorcycle/notifications?unread=true&per_page=1" -H "Authorization: Bearer $TOKEN"

# Service
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service&unread=true&per_page=1" -H "Authorization: Bearer $TOKEN"

# Trip
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true&per_page=1" -H "Authorization: Bearer $TOKEN"

# Alert
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=alert&unread=true&per_page=1" -H "Authorization: Bearer $TOKEN"
```

**Lihat field `unread_count` di response!**

```json
{
  "unread_count": 3 // ← Badge count untuk kategori ini
}
```

---

## 🎯 Testing Workflow - Complete

### Scenario: Test Lengkap dari Awal

```bash
# 1. Check current notifications
curl -X GET "http://localhost/api/v1/motorcycle/notifications" \
  -H "Authorization: Bearer $TOKEN"

# 2. Check unread count
curl -X GET "http://localhost/api/v1/motorcycle/notifications?unread=true" \
  -H "Authorization: Bearer $TOKEN"
# Output: "unread_count": 2

# 3. Trigger notifikasi baru - Add odometer
curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 30, "notes": "Test trip"}'

# 4. Check unread again (should increase)
curl -X GET "http://localhost/api/v1/motorcycle/notifications?unread=true" \
  -H "Authorization: Bearer $TOKEN"
# Output: "unread_count": 3  ← Bertambah!

# 5. Filter kategori trip
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true" \
  -H "Authorization: Bearer $TOKEN"
# Output: Muncul notifikasi "Jarak 30 km berhasil ditambahkan"

# 6. Mark as read
curl -X POST "http://localhost/api/v1/motorcycle/notifications/16/read" \
  -H "Authorization: Bearer $TOKEN"

# 7. Verify unread count decreased
curl -X GET "http://localhost/api/v1/motorcycle/notifications?unread=true" \
  -H "Authorization: Bearer $TOKEN"
# Output: "unread_count": 2  ← Berkurang!
```

---

## 🔍 Debug Commands

### Check App Status di Flutter

**Lihat console log:**

```
✅ Firebase initialized successfully
✅ NotificationService initialized successfully
Device token registered successfully
FCM Token registered: e1lYGTQuSva...
```

### Verify Backend Database

```sql
-- Check notifikasi terbaru
SELECT id, category_key, title, is_read, created_at
FROM notifications
ORDER BY created_at DESC
LIMIT 10;

-- Count by category
SELECT category_key, COUNT(*) as total,
       SUM(CASE WHEN read_at IS NULL THEN 1 ELSE 0 END) as unread
FROM notifications
GROUP BY category_key;
```

---

## 📝 Notes

### Get JWT Token

**Via Login API:**

```bash
curl -X POST "http://localhost/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

**Response:**

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."  ← Copy this
}
```

**Set to variable:**

```bash
export TOKEN="eyJ0eXAiOiJKV1QiLCJhbGc..."
```

---

### Get Device UUID

**Via Flutter Debug Page:**

1. Buka app
2. Halaman Notifikasi → Tap icon bug (🐛)
3. Lihat "Device ID"
4. Tap "Copy Device ID"

**Or generate random:**

```bash
# Linux/Mac
uuidgen

# Windows PowerShell
[guid]::NewGuid().ToString()
```

---

## ✅ Checklist Testing

- [ ] GET all notifications
- [ ] GET filter by category: service
- [ ] GET filter by category: trip
- [ ] GET filter by category: alert
- [ ] GET filter unread only
- [ ] GET kombinasi: service + unread
- [ ] POST mark as read
- [ ] POST mark all as read
- [ ] **TRIGGER**: Add odometer → Notifikasi otomatis
- [ ] **TRIGGER**: Finish trip → Notifikasi otomatis
- [ ] Guest mode: Register device token
- [ ] Guest mode: Get notifications
- [ ] Verify di Flutter app: Badge count update
- [ ] Verify di Flutter app: Push notification muncul

---

## 🚀 Quick Copy-Paste Commands

**Windows PowerShell (Replace YOUR_TOKEN):**

```powershell
# Set token
$TOKEN = "your-jwt-token-here"

# Get all
curl -X GET "http://localhost/api/v1/motorcycle/notifications" -H "Authorization: Bearer $TOKEN"

# Filter service
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service" -H "Authorization: Bearer $TOKEN"

# Trigger odometer
curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{\"distance_km\": 25}'

# Check trip notifications
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true" -H "Authorization: Bearer $TOKEN"
```

**Linux/Mac Bash:**

```bash
# Set token
export TOKEN="your-jwt-token-here"

# Get all
curl -X GET "http://localhost/api/v1/motorcycle/notifications" \
  -H "Authorization: Bearer $TOKEN"

# Filter service
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=service" \
  -H "Authorization: Bearer $TOKEN"

# Trigger odometer
curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 25}'

# Check trip notifications
curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true" \
  -H "Authorization: Bearer $TOKEN"
```

---

Selamat testing! 🎉
