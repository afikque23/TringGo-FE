# 📖 Panduan Testing Notifikasi - Index

## 🎯 Mulai Dari Mana?

Pilih metode testing sesuai kebutuhan Anda:

### 🌐 **Option 1: Testing dari Web Browser** (Paling Mudah!)

**Untuk:** Non-developer, testing cepat, demo
**File:** [TESTING_WEB_BROWSER.md](TESTING_WEB_BROWSER.md)
**Tools:** Browser (Chrome/Firefox), Admin Panel
**Waktu:** 5-10 menit

**Cara:**

1. Buka `http://localhost/admin/login`
2. Login dengan akun admin
3. Menu: Notifikasi → Kirim Notifikasi
4. Isi form, klik "Kirim"
5. Verify di Flutter app

✅ **Best for:** Testing manual, demo ke client, quick verification

---

### 🚀 **Option 2: Testing via API (Postman/cURL)** (Recommended!)

**Untuk:** Developer, automated testing, integration testing
**File:** [QUICK_TEST_COMMANDS.md](QUICK_TEST_COMMANDS.md)
**Tools:** Postman, cURL, Terminal
**Waktu:** 15-20 menit (setup awal), 2-3 menit (per test)

**Cara:**

1. Import Postman collection
2. Set environment variables (token, base_url)
3. Run test endpoints
4. Verify response JSON

✅ **Best for:** API testing, automated trigger testing, debugging

---

### 📱 **Option 3: Testing dari Flutter App** (End-to-End)

**Untuk:** User acceptance testing, UI/UX testing
**File:** [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md)
**Tools:** Flutter app di emulator/device
**Waktu:** 20-30 menit

**Cara:**

1. Build & run Flutter app
2. Test badge count, filter kategori, mark as read
3. Test push notification (FCM)
4. Test guest mode

✅ **Best for:** Full integration testing, user experience testing

---

## 📚 Dokumentasi Referensi

### [NOTIFICATION_CATEGORY_FILTER_API.md](NOTIFICATION_CATEGORY_FILTER_API.md)

**Isi:** Dokumentasi lengkap API filter kategori notifikasi
**Untuk:** Developer yang ingin tahu detail API
**Topik:**

- API endpoints & parameters
- Request/response examples
- Filter by category (service, trip, alert, insight, system)
- Guest mode implementation
- UI implementation guide (Flutter)
- Variabel template notifikasi
- Cara tambah kategori baru

---

### [TESTING_WEB_BROWSER.md](TESTING_WEB_BROWSER.md)

**Isi:** Panduan testing dari web browser (admin panel)
**Untuk:** Non-developer, tester, demo
**Topik:**

- Login admin panel
- Kirim notifikasi manual
- Filter & search notifikasi
- Test semua kategori
- Test guest mode
- Troubleshooting

---

### [QUICK_TEST_COMMANDS.md](QUICK_TEST_COMMANDS.md)

**Isi:** Command cURL/Postman untuk testing cepat
**Untuk:** Developer yang ingin test via terminal/Postman
**Topik:**

- cURL commands (Windows & Linux/Mac)
- Postman examples
- Test filter kategori
- Trigger automated notifications (odometer, trip)
- Guest mode testing
- Debug commands

---

### [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md)

**Isi:** Panduan testing komprehensif dari semua source
**Untuk:** Developer yang ingin test end-to-end
**Topik:**

- Testing dari web (backend)
- Testing dari odometer update (automated)
- Testing dari trip completion (automated)
- Testing dari Flutter app (UI/UX)
- Verifikasi notifikasi masuk
- Testing checklist lengkap

---

## 🎯 Quick Start Guide

### Scenario 1: "Saya mau test cepat 5 menit"

**Baca:** [TESTING_WEB_BROWSER.md](TESTING_WEB_BROWSER.md) → Quick Start

**Steps:**

1. Buka `http://localhost/admin/login`
2. Menu: Notifikasi → Kirim Notifikasi
3. Pilih template, kendaraan, user
4. Klik "Kirim"
5. Buka Flutter app → Lihat notifikasi muncul

**Waktu:** ~5 menit

---

### Scenario 2: "Saya mau test trigger otomatis (odometer, trip)"

**Baca:** [QUICK_TEST_COMMANDS.md](QUICK_TEST_COMMANDS.md) → Test 8 & 9

**Steps:**

1. Copy command cURL dari dokumentasi
2. Replace `YOUR_TOKEN` dengan JWT token Anda
3. Run command di terminal:
   ```bash
   # Test odometer update
   curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"distance_km": 25.5}'
   ```
4. Check response:
   ```json
   { "success": true, "message": "Odometer updated" }
   ```
5. Verify notifikasi:
   ```bash
   curl -X GET "http://localhost/api/v1/motorcycle/notifications?category=trip&unread=true" \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

**Waktu:** ~3 menit

---

### Scenario 3: "Saya mau test filter kategori di Flutter"

**Baca:** [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md) → Testing dari Flutter App

**Steps:**

1. Build & run Flutter app: `flutter run`
2. Login / gunakan guest mode
3. Tap icon notifikasi (bottom nav)
4. Switch ke tab **"Servis"** → Hanya muncul notifikasi servis
5. Switch ke tab **"Perjalanan"** → Hanya muncul notifikasi trip
6. Check badge count di setiap tab

**Waktu:** ~10 menit

---

### Scenario 4: "Saya mau test push notification (FCM)"

**Baca:** [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md) → Test Push Notification

**Prerequisites:**

- Firebase configured
- FCM token registered

**Steps:**

1. Flutter app running di background
2. Kirim notifikasi via admin panel / API
3. Push notification muncul di status bar
4. Tap notification → App terbuka ke halaman notifikasi
5. Badge count ter-update

**Waktu:** ~5 menit

---

## 🧪 Testing Matrix

**Test Semua Fitur:**

| Fitur                     | Web Browser | Postman/cURL | Flutter App | Status |
| ------------------------- | ----------- | ------------ | ----------- | ------ |
| Get all notifications     | ✅          | ✅           | ✅          | [ ]    |
| Filter by category        | ✅          | ✅           | ✅          | [ ]    |
| Filter unread only        | ✅          | ✅           | ✅          | [ ]    |
| Kombinasi filter          | ✅          | ✅           | ✅          | [ ]    |
| Mark as read              | ✅          | ✅           | ✅          | [ ]    |
| Mark all as read          | ✅          | ✅           | ✅          | [ ]    |
| Badge count               | -           | ✅           | ✅          | [ ]    |
| Push notification         | -           | -            | ✅          | [ ]    |
| Guest mode                | ✅          | ✅           | ✅          | [ ]    |
| Trigger: Odometer update  | ✅          | ✅           | ✅          | [ ]    |
| Trigger: Trip completion  | ✅          | ✅           | ✅          | [ ]    |
| Trigger: Service reminder | ✅          | ✅           | ✅          | [ ]    |
| Manual send               | ✅          | ✅           | -           | [ ]    |
| Template management       | ✅          | -            | -           | [ ]    |
| Category management       | ✅          | -            | -           | [ ]    |
| Statistics dashboard      | ✅          | -            | -           | [ ]    |

---

## 📊 Kategori Notifikasi yang Tersedia

| Key       | Nama Kategori         | Icon | Deskripsi                        | Trigger Examples              |
| --------- | --------------------- | ---- | -------------------------------- | ----------------------------- |
| `service` | Servis                | 🔧   | Notifikasi servis motor          | Service reminder, service due |
| `trip`    | Perjalanan            | 🛣️   | Notifikasi perjalanan & odometer | Trip completed, odometer add  |
| `alert`   | Peringatan            | 🚨   | Notifikasi prioritas tinggi      | Service overdue, critical     |
| `insight` | Insight & Rekomendasi | 💡   | Tips & rekomendasi               | Usage pattern, fuel tips      |
| `system`  | Sistem                | ⚙️   | Notifikasi sistem & pengumuman   | App update, maintenance       |

**Custom Category:** Bisa menambah kategori baru via admin panel tanpa coding! (Lihat [NOTIFICATION_CATEGORY_FILTER_API.md](NOTIFICATION_CATEGORY_FILTER_API.md) → Section "Menambah Kategori Baru")

---

## 🔥 API Endpoints Cheat Sheet

**Base URL:** `http://localhost/api/v1/motorcycle`

| Endpoint                       | Method | Fungsi             | Query Params                 |
| ------------------------------ | ------ | ------------------ | ---------------------------- |
| `/notifications`               | GET    | Get list           | `category`, `unread`, `page` |
| `/notifications?category=trip` | GET    | Filter trip        | -                            |
| `/notifications?unread=true`   | GET    | Filter unread      | -                            |
| `/notifications/{id}/read`     | POST   | Mark as read       | -                            |
| `/notifications/mark-all-read` | POST   | Mark all read      | -                            |
| `/device-tokens/register`      | POST   | Register FCM token | Body: `fcm_token`            |
| `/vehicles/{id}/odometer`      | POST   | Update odometer    | Body: `distance_km`          |
| `/trips/{id}/finish`           | POST   | Finish trip        | Body: `distance`, `duration` |

**Headers:**

- **Authenticated:** `Authorization: Bearer {token}`
- **Guest Mode:** `X-Device-ID: {device-uuid}`

---

## 🛠️ Tools yang Dibutuhkan

### Untuk Testing dari Web Browser

- ✅ Browser (Chrome/Firefox)
- ✅ Admin panel access (username/password)

### Untuk Testing via API

- ✅ Postman (recommended) atau cURL
- ✅ JWT token (dari login API)
- ✅ Backend server running (`http://localhost`)

### Untuk Testing dari Flutter

- ✅ Flutter SDK installed
- ✅ Android emulator/device
- ✅ Firebase configured
- ✅ FCM token registered

---

## 🎯 Testing Priority

**High Priority (Must Test):**

1. ✅ Get all notifications
2. ✅ Filter by category (service, trip)
3. ✅ Badge count akurat
4. ✅ Mark as read mengurangi badge count
5. ✅ Trigger: Odometer update → Notifikasi otomatis

**Medium Priority (Should Test):** 6. ✅ Filter unread only 7. ✅ Kombinasi filter (category + unread) 8. ✅ Guest mode 9. ✅ Trigger: Trip completion 10. ✅ Push notification (FCM)

**Low Priority (Nice to Have):** 11. ✅ Pagination 12. ✅ Search notifikasi 13. ✅ Statistics dashboard 14. ✅ Template management

---

## ✅ Checklist Testing Lengkap

Setelah selesai testing, pastikan semua ini sudah dicoba:

### Backend API

- [ ] GET `/notifications` → Success
- [ ] GET `/notifications?category=service` → Filter berfungsi
- [ ] GET `/notifications?category=trip` → Filter berfungsi
- [ ] GET `/notifications?unread=true` → Filter berfungsi
- [ ] POST `/notifications/{id}/read` → Badge count berkurang
- [ ] POST `/notifications/mark-all-read` → Badge count jadi 0

### Automated Triggers

- [ ] POST `/vehicles/{id}/odometer` → Notifikasi trip terkirim
- [ ] POST `/trips/{id}/finish` → Notifikasi trip terkirim
- [ ] Service reminder saat mendekati jadwal servis

### Flutter App

- [ ] Badge count akurat untuk semua tab
- [ ] Filter kategori berfungsi (semua tab)
- [ ] Mark as read mengurangi badge count
- [ ] Mark all as read reset badge count
- [ ] Pull-to-refresh load data terbaru
- [ ] Push notification muncul di foreground
- [ ] Push notification muncul di background
- [ ] Tap push notification navigate ke halaman

### Guest Mode

- [ ] Register device token sebagai guest
- [ ] Get notifications dengan `X-Device-ID`
- [ ] Filter kategori berfungsi (guest)
- [ ] Mark as read berfungsi (guest)
- [ ] Login → Data sync dari guest ke user

---

## 📞 Troubleshooting

**Masalah umum & solusi:**

### "Notifikasi tidak muncul di Flutter"

➡️ **Baca:** [TESTING_WEB_BROWSER.md](TESTING_WEB_BROWSER.md) → Troubleshooting section

**Quick fix:**

1. Check Firebase initialized? (console log)
2. Check FCM token registered? (debug page)
3. Pull-to-refresh di halaman notifikasi

---

### "Badge count tidak akurat"

➡️ **Baca:** [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md) → Troubleshooting

**Quick fix:**

1. Restart Flutter app
2. Check API response: `unread_count` field
3. Verify `read_at` column di database

---

### "Push notification tidak terkirim"

➡️ **Baca:** [TESTING_WEB_BROWSER.md](TESTING_WEB_BROWSER.md) → Troubleshooting

**Quick fix:**

1. Check `service-account.json` configured di backend
2. Check FCM token valid (Firebase Console → Test)
3. Check permission granted di Flutter

---

## 🚀 Rekomendasi Testing Flow

**Untuk Developer (Full Test):**

1. ✅ Read: [NOTIFICATION_CATEGORY_FILTER_API.md](NOTIFICATION_CATEGORY_FILTER_API.md) → Pahami API
2. ✅ Read: [QUICK_TEST_COMMANDS.md](QUICK_TEST_COMMANDS.md) → Test via cURL
3. ✅ Test: Semua endpoint via Postman
4. ✅ Test: Automated triggers (odometer, trip)
5. ✅ Read: [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md) → Flutter testing
6. ✅ Test: UI/UX di Flutter app
7. ✅ Test: Push notification (FCM)
8. ✅ Test: Guest mode

**Waktu Total:** ~1-2 jam (comprehensive testing)

---

**Untuk Tester (Quick Test):**

1. ✅ Read: [TESTING_WEB_BROWSER.md](TESTING_WEB_BROWSER.md) → Quick Start
2. ✅ Test: Kirim notifikasi manual via admin panel
3. ✅ Test: Filter kategori di web
4. ✅ Test: Verify di Flutter app (badge count, filter)
5. ✅ Test: Mark as read

**Waktu Total:** ~20-30 menit

---

**Untuk Demo/Presentasi:**

1. ✅ Prepare: Dummy data notifikasi di database
2. ✅ Web: Login admin panel, show statistics
3. ✅ Web: Kirim notifikasi manual
4. ✅ Flutter: Show real-time push notification
5. ✅ Flutter: Show filter kategori & badge count
6. ✅ Flutter: Demo mark as read

**Waktu Demo:** ~10 menit

---

## 📖 Summary

**4 Dokumentasi, 1 Tujuan: Testing Notifikasi dengan Filter Kategori**

| File                                | Tujuan                      | Target Audience   | Waktu  |
| ----------------------------------- | --------------------------- | ----------------- | ------ |
| NOTIFICATION_CATEGORY_FILTER_API.md | API reference lengkap       | Developer         | 30 min |
| TESTING_WEB_BROWSER.md              | Testing dari web browser    | Tester, Non-dev   | 10 min |
| QUICK_TEST_COMMANDS.md              | cURL/Postman commands       | Developer         | 15 min |
| TESTING_NOTIFICATION_GUIDE.md       | Comprehensive testing guide | Developer, Tester | 1-2 hr |

**Pilih sesuai kebutuhan Anda!**

---

**Good luck testing! 🎉**

Jika ada pertanyaan atau masalah, refer ke troubleshooting section di masing-masing dokumentasi.
