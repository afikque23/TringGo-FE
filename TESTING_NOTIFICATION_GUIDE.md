# 🧪 Panduan Testing Notifikasi - Step by Step

## 📋 Daftar Isi

1. [Testing dari Web (Backend)](#testing-dari-web-backend)
2. [Testing dari Odometer Update](#testing-dari-odometer-update)
3. [Testing dari Trip Completion](#testing-dari-trip-completion)
4. [Testing dari Flutter App](#testing-dari-flutter-app)
5. [Verifikasi Notifikasi Masuk](#verifikasi-notifikasi-masuk)

---

## 🌐 Testing dari Web (Backend)

### Method 1: Admin Panel (Paling Mudah!)

#### ✅ Setup Awal

1. Buka browser, akses: `http://localhost/admin/login`
2. Login dengan admin credentials
3. Pastikan ada data motor & user di database

#### 📤 Kirim Notifikasi Manual

**Langkah-langkah:**

1. **Menu Notifikasi** → **Kirim Notifikasi**
2. Pilih form input:
   - **Template**: Pilih template yang sudah dibuat (atau buat baru)
   - **Kategori**: Pilih kategori (service, trip, alert, insight, system)
   - **Kendaraan**: Pilih motor target
   - **Penerima**: Pilih user/guest
3. **Klik "Kirim"**

**Expected Result:**

- ✅ Notifikasi terkirim ke database
- ✅ Push notification terkirim (jika FCM token ada)
- ✅ Muncul di halaman notifikasi Flutter

---

### Method 2: Postman API

#### 📥 Setup Postman

**Download Collection:**

```bash
# File Postman Collection (sudah include filter kategori)
- Motorcycle_Management_API.postman_collection.json
- Motorcycle_Management_Local.postman_environment.json
```

**Import ke Postman:**

1. Buka Postman
2. **Import** → Drag & drop 2 file di atas
3. Pilih environment: **Motorcycle Management Local**
4. Set variables:
   ```
   base_url: http://localhost/api/v1/motorcycle
   token: <your-jwt-token>
   device_id: <your-device-uuid>
   ```

#### 🧪 Test Endpoints

**1. Get All Notifications**

```http
GET {{base_url}}/notifications
Authorization: Bearer {{token}}
```

**2. Filter by Category - Service**

```http
GET {{base_url}}/notifications?category=service&per_page=20
Authorization: Bearer {{token}}
```

**3. Filter by Category - Trip**

```http
GET {{base_url}}/notifications?category=trip&per_page=20
Authorization: Bearer {{token}}
```

**4. Filter Unread Only**

```http
GET {{base_url}}/notifications?unread=true
Authorization: Bearer {{token}}
```

**5. Kombinasi Filter - Service + Unread**

```http
GET {{base_url}}/notifications?category=service&unread=true
Authorization: Bearer {{token}}
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "data": [
    {
      "id": 15,
      "category_key": "trip",
      "category_name": "Perjalanan",
      "title": "Perjalanan Selesai",
      "message": "✅ Perjalanan selesai! Honda Beat menempuh 15.5 km.",
      "is_read": false,
      "created_at": "2026-02-19T14:30:00+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 25
  },
  "unread_count": 5
}
```

---

## 📊 Testing dari Odometer Update

### Backend: Trigger Otomatis

Ketika user update odometer motor, sistem otomatis:

1. ✅ Cek jarak dari servis terakhir
2. ✅ Kirim notifikasi jika mendekati jadwal servis
3. ✅ Kirim alert jika sudah lewat jadwal

### Testing via Postman

**1. Tambah Manual Distance**

```http
POST {{base_url}}/vehicles/{vehicle_id}/odometer
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "distance_km": 25.5,
  "notes": "Perjalanan Solo - Jogja"
}
```

**Expected:**

- ✅ Odometer ter-update
- ✅ **Notifikasi otomatis terkirim** (kategori: `trip`)
- ✅ Message: "✅ Jarak 25.5 km berhasil ditambahkan. Odometer sekarang: 5,334.5 km."

**2. Verifikasi Notifikasi**

```http
GET {{base_url}}/notifications?category=trip&unread=true
```

**Response:**

```json
{
  "data": [
    {
      "id": 16,
      "category_key": "trip",
      "title": "Jarak Ditambahkan",
      "message": "✅ Jarak 25.5 km berhasil ditambahkan. Odometer sekarang: 5,334.5 km.",
      "is_read": false,
      "created_at": "2026-02-19T15:00:00+07:00"
    }
  ],
  "unread_count": 1
}
```

---

### Testing via Flutter App

**1. Buka Halaman Kendaraan**

- Pilih motor dari list
- Tap **"Tambah Jarak"** atau **"Update Odometer"**

**2. Input Data**

```
Jarak: 25.5 km
Catatan: (optional)
```

**3. Tap "Simpan"**

**4. Cek Notifikasi**

- **Badge count** di icon notifikasi bertambah
- Buka **halaman notifikasi**
- Tab **"Perjalanan"** ada notifikasi baru
- Status: **Belum dibaca** (dot merah)

---

## 🛣️ Testing dari Trip Completion

### Scenario: Perjalanan Selesai

#### Via Postman

**1. Start Trip**

```http
POST {{base_url}}/trips
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "vehicle_id": 1,
  "start_latitude": -6.2088,
  "start_longitude": 106.8456,
  "start_address": "Jakarta Pusat",
  "tracking_mode": "gps"
}
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

**2. Finish Trip**

```http
POST {{base_url}}/trips/25/finish
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "end_latitude": -6.1751,
  "end_longitude": 106.8650,
  "end_address": "Monas, Jakarta",
  "distance": 15.5,
  "duration_minutes": 25,
  "average_speed": 37.2
}
```

**Expected:**

- ✅ Trip status jadi `completed`
- ✅ Odometer motor bertambah 15.5 km
- ✅ **Notifikasi otomatis terkirim** (kategori: `trip`)
- ✅ Message: "✅ Perjalanan selesai! Honda Beat menempuh 15.5 km dalam 25 menit. Kecepatan rata-rata: 37.2 km/h. Odometer: 5,350 km."

**3. Cek Notifikasi**

```http
GET {{base_url}}/notifications?category=trip&unread=true
```

---

#### Via Flutter App

**1. Start Trip**

- Buka halaman **Tracking**
- Tap **"Mulai Perjalanan"**
- Pilih motor
- Pilih mode tracking: **GPS** atau **Manual**

**2. During Trip**

- Jika GPS mode: tracking otomatis
- Jika Manual mode: input start location

**3. Finish Trip**

- Tap **"Selesai"**
- Sistem calculate distance & duration
- Tap **"Simpan"**

**4. Verifikasi Notifikasi**

- **Notifikasi push** muncul di status bar
- **Badge count** bertambah
- Buka **halaman notifikasi**
- Tab **"Perjalanan"** ada notifikasi baru

---

## 📱 Testing dari Flutter App

### 1. Test Badge Count

**Setup:**

- Login ke app
- Pastikan ada notifikasi belum dibaca di backend

**Steps:**

1. Buka app (cold start)
2. Perhatikan **badge count** di icon notifikasi (bottom navigation)
3. Tap icon notifikasi
4. Tab **"Semua"** → Badge count total
5. Tab **"Servis"** → Badge count kategori service
6. Tab **"Perjalanan"** → Badge count kategori trip

**Verification:**

```
Badge "Semua": 5
Badge "Servis": 3
Badge "Perjalanan": 2
Badge "Peringatan": 0
```

---

### 2. Test Filter by Category

**Steps:**

1. Buka halaman notifikasi
2. Switch ke tab **"Servis"**
   - ✅ Hanya muncul notifikasi kategori `service`
3. Switch ke tab **"Perjalanan"**
   - ✅ Hanya muncul notifikasi kategori `trip`
4. Switch ke tab **"Peringatan"**
   - ✅ Hanya muncul notifikasi kategori `alert`

---

### 3. Test Mark as Read

**Steps:**

1. Tab **"Semua"** → Badge count: **5**
2. Tap 1 notifikasi yang belum dibaca
3. Detail notifikasi terbuka
4. Kembali ke list
5. ✅ Badge count jadi **4**
6. ✅ Dot merah hilang pada notifikasi tersebut

---

### 4. Test Mark All as Read

**Steps:**

1. Tab **"Semua"** → Badge count: **5**
2. Tap **"Tandai Semua Dibaca"** (di header)
3. ✅ Badge count jadi **0**
4. ✅ Semua dot merah hilang

---

### 5. Test Real-time Update (FCM)

**Prerequisites:**

- FCM token sudah registered
- Backend FCM configured

**Testing:**

**Method 1: Via Admin Panel**

1. Buka admin panel di browser
2. Kirim notifikasi manual ke user tertentu
3. **Check Flutter app:**
   - ✅ Push notification muncul di status bar
   - ✅ Badge count bertambah (jika app dibuka)
   - ✅ Notifikasi muncul di list

**Method 2: Via Odometer Update**

1. Di Postman: POST `/vehicles/1/odometer` dengan `distance_km: 30`
2. **Check Flutter app:**
   - ✅ Push notification: "Jarak 30 km berhasil ditambahkan"
   - ✅ Badge count bertambah
   - ✅ Notifikasi muncul di tab "Perjalanan"

**Method 3: Via Trip Completion**

1. Di Postman: POST `/trips/25/finish`
2. **Check Flutter app:**
   - ✅ Push notification: "Perjalanan selesai! ..."
   - ✅ Badge count bertambah
   - ✅ Notifikasi muncul di tab "Perjalanan"

---

## ✅ Verifikasi Notifikasi Masuk

### Checklist Testing Lengkap

#### 1. Test dari Backend (Postman)

- [ ] **GET** `/notifications` → Ambil semua notifikasi
- [ ] **GET** `/notifications?category=service` → Filter servis
- [ ] **GET** `/notifications?category=trip` → Filter perjalanan
- [ ] **GET** `/notifications?category=alert` → Filter peringatan
- [ ] **GET** `/notifications?unread=true` → Filter belum dibaca
- [ ] **GET** `/notifications?category=service&unread=true` → Kombinasi
- [ ] **POST** `/notifications/{id}/read` → Tandai dibaca
- [ ] **POST** `/notifications/mark-all-read` → Tandai semua dibaca

#### 2. Test Trigger Otomatis

- [ ] **POST** `/vehicles/{id}/odometer` → Notifikasi "Jarak ditambahkan"
- [ ] **POST** `/trips/{id}/finish` → Notifikasi "Perjalanan selesai"
- [ ] **POST** `/services` → Notifikasi "Servis tercatat" (jika ada)
- [ ] **Admin Panel** → Kirim manual → Notifikasi muncul

#### 3. Test di Flutter App

- [ ] Badge count akurat (semua tab)
- [ ] Filter kategori berfungsi
- [ ] Mark as read mengurangi badge count
- [ ] Mark all as read reset badge count
- [ ] Pull-to-refresh load data terbaru
- [ ] Pagination berfungsi (jika >20 notifikasi)

#### 4. Test Push Notification (FCM)

- [ ] App **foreground** → Notifikasi muncul di in-app banner
- [ ] App **background** → Notifikasi muncul di status bar
- [ ] App **terminated** → Notifikasi muncul, tap buka app
- [ ] Tap push notification → Navigate ke halaman notifikasi

#### 5. Test Guest Mode

- [ ] **POST** `/device-tokens/register` dengan header `X-Device-ID`
- [ ] **GET** `/notifications` dengan header `X-Device-ID`
- [ ] Filter kategori berfungsi (guest mode)
- [ ] Mark as read berfungsi (guest mode)
- [ ] Login → Data sync dari guest ke user

---

## 🎯 Quick Testing Scenarios

### Scenario 1: Test Trip Notification (5 menit)

```bash
# 1. Start trip
POST /trips
{
  "vehicle_id": 1,
  "start_latitude": -6.2088,
  "start_longitude": 106.8456,
  "tracking_mode": "gps"
}

# 2. Finish trip (tunggu 1-2 menit atau langsung)
POST /trips/{id}/finish
{
  "end_latitude": -6.1751,
  "end_longitude": 106.8650,
  "distance": 15.5,
  "duration_minutes": 25,
  "average_speed": 37.2
}

# 3. Check notification
GET /notifications?category=trip&unread=true

# 4. Verify di Flutter app
- Badge count bertambah
- Notifikasi muncul di tab "Perjalanan"
```

---

### Scenario 2: Test Odometer Notification (2 menit)

```bash
# 1. Add distance
POST /vehicles/1/odometer
{
  "distance_km": 25.5,
  "notes": "Test odometer update"
}

# 2. Check notification
GET /notifications?category=trip&unread=true

# 3. Verify
- Response: "Jarak 25.5 km berhasil ditambahkan"
- category_key: "trip"
- is_read: false
```

---

### Scenario 3: Test Service Reminder (Manual)

```bash
# 1. Admin panel: Kirim notifikasi manual
Kategori: Servis
Template: "Pengingat Servis"
Target: User tertentu

# 2. Check via API
GET /notifications?category=service&unread=true

# 3. Verify di Flutter
- Badge "Servis" bertambah
- Notifikasi muncul di tab "Servis"
```

---

## 📊 Expected Output Examples

### 1. Get All Notifications

**Request:**

```http
GET /api/v1/motorcycle/notifications?per_page=10
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 15,
      "category_key": "trip",
      "category_name": "Perjalanan",
      "title": "Perjalanan Selesai",
      "message": "✅ Perjalanan selesai! Honda Beat menempuh 15.5 km dalam 25 menit.",
      "priority": "normal",
      "is_read": false,
      "created_at": "2026-02-19T14:30:00+07:00",
      "vehicle": {
        "id": 1,
        "title": "Honda Beat 2023",
        "odometer": 5350
      }
    },
    {
      "id": 14,
      "category_key": "service",
      "category_name": "Servis",
      "title": "Pengingat Servis",
      "message": "⏰ Waktunya ganti oli! Honda Beat sudah menempuh 950 km dari servis terakhir.",
      "priority": "normal",
      "is_read": false,
      "created_at": "2026-02-19T10:00:00+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 10,
    "total": 25
  },
  "unread_count": 5
}
```

---

### 2. Filter Service Category

**Request:**

```http
GET /api/v1/motorcycle/notifications?category=service&per_page=20
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 14,
      "category_key": "service",
      "category_name": "Servis",
      "title": "Pengingat Servis",
      "message": "⏰ Waktunya ganti oli!",
      "is_read": false
    },
    {
      "id": 10,
      "category_key": "service",
      "title": "Servis Berikutnya",
      "message": "⏰ Servis berikutnya dalam 200 km lagi.",
      "is_read": true
    }
  ],
  "meta": {
    "total": 8
  },
  "unread_count": 5
}
```

---

### 3. Unread Only

**Request:**

```http
GET /api/v1/motorcycle/notifications?unread=true
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 15,
      "category_key": "trip",
      "is_read": false
    },
    {
      "id": 14,
      "category_key": "service",
      "is_read": false
    }
  ],
  "unread_count": 5
}
```

---

## 🔧 Troubleshooting

### Notifikasi Tidak Muncul di Flutter

**Cek:**

1. ✅ Firebase initialized successfully? (console log)
2. ✅ FCM token registered? (Halaman debug → Copy token)
3. ✅ Backend FCM configured? (service-account.json)
4. ✅ API call success? (console log HTTP response)

**Fix:**

```dart
// Debug di notification_page.dart
print('Loading notifications...');
final response = await NotificationApiService.getNotifications();
print('Response: ${response.data}');
```

---

### Badge Count Tidak Update

**Cek:**

1. ✅ FCM listener running? (NotificationService.initialize())
2. ✅ `setState()` dipanggil setelah API call?
3. ✅ `mounted` check sebelum `setState()`?

**Fix:**

```dart
// Refresh badge count manual
FirebaseMessaging.onMessage.listen((message) {
  if (mounted) {
    _loadData(); // Reload notifications
  }
});
```

---

### Push Notification Tidak Terkirim

**Cek:**

1. ✅ FCM token valid? (cek di Firebase Console → Cloud Messaging → Test)
2. ✅ service-account.json configured di backend?
3. ✅ Channel notification exist? (Android)

**Fix:**

```bash
# Test manual via Firebase Console
Firebase Console → Cloud Messaging → Send test message
Target: FCM token dari debug page
```

---

## 📚 API Reference Summary

| Endpoint                       | Method | Fungsi                    | Query Params                                |
| ------------------------------ | ------ | ------------------------- | ------------------------------------------- |
| `/notifications`               | GET    | Get list notifikasi       | `category`, `unread`, `per_page`, `page`    |
| `/notifications/{id}/read`     | POST   | Mark as read              | -                                           |
| `/notifications/mark-all-read` | POST   | Mark all as read          | -                                           |
| `/notifications/{id}`          | DELETE | Delete notifikasi         | -                                           |
| `/device-tokens/register`      | POST   | Register FCM token        | Body: `fcm_token`, `platform`               |
| `/vehicles/{id}/odometer`      | POST   | Update odometer (trigger) | Body: `distance_km`                         |
| `/trips/{id}/finish`           | POST   | Finish trip (trigger)     | Body: `distance`, `duration`, `end_lat/lng` |

---

## 🎉 Ready to Test!

Sekarang Anda bisa test notifikasi dari:

- ✅ Web (Admin Panel)
- ✅ Postman API
- ✅ Odometer Update (automated)
- ✅ Trip Completion (automated)
- ✅ Flutter App (manual & real-time)

**Next Steps:**

1. Build & run Flutter app
2. Test scenario 1-3 di atas
3. Verify badge count & filter kategori
4. Test push notification (FCM)

Good luck! 🚀
