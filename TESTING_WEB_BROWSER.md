# 🌐 Testing Notifikasi dari Web Browser - Step by Step

## 📋 Overview

Panduan ini menjelaskan cara **testing notifikasi tanpa coding** menggunakan Admin Panel web interface. Paling mudah untuk testing cepat!

---

## 🚀 Quick Start (5 Menit)

### 1. Akses Admin Panel

**URL:** `http://localhost/admin/login`

**Login:**

- Email: (sesuai user admin Anda)
- Password: (password admin)

**Expected:** Dashboard admin terbuka

---

### 2. Kirim Notifikasi Test

**Menu:** Notifikasi → **Kirim Notifikasi**

**Isi Form:**

```
Template: Pilih dari dropdown (contoh: "Trip Completed")
Kategori: Perjalanan
Kendaraan: Pilih salah satu motor
Penerima: Pilih user target
```

**Klik:** **"Kirim"**

**Expected:**

- ✅ Success message: "Notifikasi berhasil dikirim"
- ✅ Notifikasi muncul di list
- ✅ Push notification terkirim ke device

---

### 3. Verifikasi di Flutter App

**Buka Flutter App:**

1. Lihat **badge count** di icon notifikasi (bottom nav)
2. Tap icon notifikasi
3. Switch ke tab sesuai kategori (contoh: **"Perjalanan"**)
4. ✅ Notifikasi baru muncul
5. ✅ Status: **Belum dibaca** (dot merah)

---

## 📊 Testing Scenarios

### Scenario 1: Test Kategori "Servis"

#### Step 1: Buat/Pilih Template Servis

**Menu:** Notifikasi → **Template Notifikasi**

**Jika belum ada, klik "Tambah Template":**

```
Nama Template: Pengingat Servis Ganti Oli
Kategori: Servis (pilih dari dropdown)
Trigger Type: service_reminder
Channel: Push + In-App
Priority: Normal

Judul Template:
⏰ Waktunya Ganti Oli!

Pesan Template:
Halo {user_name},

{vehicle_name} sudah menempuh {km_remaining} km dari servis terakhir.
Target servis berikutnya: {target_km} km.

Jangan lupa servis ya!

Status: ✅ Aktif
```

**Klik "Simpan"**

---

#### Step 2: Kirim Notifikasi Servis

**Menu:** Notifikasi → **Kirim Notifikasi**

**Isi Form:**

```
Template: Pengingat Servis Ganti Oli
Kendaraan: Honda Beat 2023 (pilih dari dropdown)
Penerima: John Doe (pilih user)

Variabel Custom (jika ada):
- km_remaining: 950
- target_km: 6000
```

**Klik "Kirim"**

---

#### Step 3: Verifikasi

**Di Web Admin:**

- Menu: Notifikasi → **Daftar Notifikasi**
- ✅ Notifikasi baru muncul
- Kategori: **Servis**
- Status: **Belum Dibaca**

**Di Flutter App:**

- Badge **"Servis"** bertambah
- Tab **"Servis"** ada notifikasi baru
- Isi: "⏰ Waktunya Ganti Oli! Honda Beat sudah menempuh 950 km..."

---

### Scenario 2: Test Kategori "Perjalanan"

#### Step 1: Trigger Otomatis via Odometer Update

**Option A: Via Web Form (jika ada)**

**Menu:** Kendaraan → Pilih motor → **Update Odometer**

**Isi:**

```
Jarak: 25.5 km
Catatan: Perjalanan Jogja - Solo
```

**Klik "Simpan"**

**Expected:**

- ✅ Odometer ter-update
- ✅ **Notifikasi otomatis terkirim**
- Kategori: **Perjalanan**
- Message: "✅ Jarak 25.5 km berhasil ditambahkan. Odometer: 5,375.5 km."

---

**Option B: Via API (Postman/cURL)**

Lihat [QUICK_TEST_COMMANDS.md](QUICK_TEST_COMMANDS.md) → Test 8

```bash
curl -X POST "http://localhost/api/v1/motorcycle/vehicles/1/odometer" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"distance_km": 25.5, "notes": "Test perjalanan"}'
```

---

#### Step 2: Trigger via Trip Completion

**Menu:** Perjalanan → **Trip Aktif**

**Pilih trip yang sedang berjalan**

**Klik "Selesaikan Perjalanan"**

**Isi Form:**

```
Lokasi Akhir: Monas, Jakarta
Jarak: 15.5 km
Durasi: 25 menit
Kecepatan Rata-rata: 37.2 km/h
```

**Klik "Simpan"**

**Expected:**

- ✅ Trip status jadi **Completed**
- ✅ Odometer motor bertambah
- ✅ **Notifikasi otomatis terkirim**
- Kategori: **Perjalanan**
- Message: "✅ Perjalanan selesai! Honda Beat menempuh 15.5 km dalam 25 menit."

---

#### Step 3: Verifikasi

**Di Web Admin:**

- Menu: Notifikasi → **Filter Kategori** → Pilih **"Perjalanan"**
- ✅ Notifikasi trip muncul
- Klik detail → Lihat info lengkap

**Di Flutter App:**

- Badge **"Perjalanan"** bertambah
- Tab **"Perjalanan"** ada notifikasi baru
- Tap notifikasi → Lihat detail
- Mark as read → Badge count berkurang

---

### Scenario 3: Test Kategori "Peringatan"

#### Step 1: Buat Template Alert

**Menu:** Notifikasi → **Template Notifikasi** → **Tambah**

```
Nama Template: Servis Terlambat
Kategori: Peringatan
Trigger Type: service_overdue
Priority: High

Judul:
🚨 SERVIS TERLAMBAT!

Pesan:
⚠️ PERHATIAN!

{vehicle_name} sudah terlambat {km_overdue} km dari jadwal servis.
Target servis: {target_km} km
Odometer sekarang: {current_km} km

Segera servis untuk menjaga performa motor!

Status: ✅ Aktif
```

---

#### Step 2: Kirim Manual

**Menu:** Notifikasi → **Kirim Notifikasi**

```
Template: Servis Terlambat
Kendaraan: Honda Beat 2023
Penerima: John Doe

Variabel:
- km_overdue: 500
- target_km: 5000
- current_km: 5500
```

**Klik "Kirim"**

---

#### Step 3: Verifikasi Alert

**Di Flutter App:**

- Badge **"Peringatan"** bertambah (warna merah)
- Tab **"Peringatan"** ada notifikasi baru
- Priority: **High** (icon khusus/warna menonjol)
- Push notification dengan sound/vibrate

---

### Scenario 4: Test Guest Mode

#### Step 1: Simulate Guest User

**Di Flutter App:**

1. **Logout** dari akun (jika sedang login)
2. Buka app sebagai **guest**
3. Buka halaman **Notifikasi Debug** (icon bug 🐛)
4. **Copy Device ID** (contoh: `guest-device-abc123-xyz789`)

---

#### Step 2: Kirim Notifikasi ke Guest

**Menu:** Notifikasi → **Kirim Notifikasi**

**Isi Form:**

```
Template: (pilih template)
Mode: Guest
Device ID: guest-device-abc123-xyz789  (paste dari Flutter)
Kendaraan: (optional)
```

**Klik "Kirim"**

---

#### Step 3: Verifikasi di Flutter (Guest)

- ✅ Push notification muncul
- ✅ Badge count bertambah
- ✅ Notifikasi muncul di list
- ✅ Filter kategori berfungsi
- ✅ Mark as read berfungsi

**Lalu test Login:**

1. Login dengan akun user
2. ✅ Notifikasi guest ter-sync ke user account
3. ✅ Badge count tetap akurat

---

## 🔍 Filter & Search di Admin Panel

### Filter by Category

**Menu:** Notifikasi → **Daftar Notifikasi**

**Filter Dropdown:**

```
Kategori:
- [x] Semua
- [ ] Servis
- [ ] Perjalanan
- [ ] Peringatan
- [ ] Insight
- [ ] Sistem

Status:
- [x] Semua
- [ ] Belum Dibaca
- [ ] Sudah Dibaca

Tanggal:
- Dari: 2026-02-01
- Sampai: 2026-02-28
```

**Klik "Filter"**

**Expected:** List notifikasi ter-filter sesuai pilihan

---

### Search Notifikasi

**Search Box:**

```
Cari: "ganti oli"
```

**Expected:** Notifikasi yang mengandung kata "ganti oli" muncul

---

## 📊 Dashboard Analytics (Optional)

### Menu: Notifikasi → **Statistik**

**View:**

- 📊 **Chart:** Notifikasi per kategori (pie chart)
- 📈 **Graph:** Notifikasi per hari (line chart)
- 📋 **Table:** Top 10 notifikasi most viewed

**Contoh Output:**

```
Kategori Notifikasi (This Month):
- Perjalanan: 45 notifikasi (60%)
- Servis: 20 notifikasi (26%)
- Peringatan: 8 notifikasi (11%)
- Sistem: 2 notifikasi (3%)

Total Notifikasi: 75
Unread: 12
Read: 63
```

---

## 🧪 Testing Matrix

### Complete Testing Checklist

| #   | Test Case                       | Menu                     | Expected Result                       | Status |
| --- | ------------------------------- | ------------------------ | ------------------------------------- | ------ |
| 1   | Login admin panel               | /admin/login             | Dashboard terbuka                     | [ ]    |
| 2   | Lihat daftar notifikasi         | Notifikasi → Daftar      | List semua notifikasi                 | [ ]    |
| 3   | Filter kategori "Servis"        | Daftar → Filter          | Hanya notifikasi servis               | [ ]    |
| 4   | Filter kategori "Perjalanan"    | Daftar → Filter          | Hanya notifikasi trip                 | [ ]    |
| 5   | Filter status "Belum Dibaca"    | Daftar → Filter          | Hanya unread notifications            | [ ]    |
| 6   | Search notifikasi               | Daftar → Search          | Hasil sesuai keyword                  | [ ]    |
| 7   | Buat template baru              | Template → Tambah        | Template tersimpan                    | [ ]    |
| 8   | Edit template existing          | Template → Edit          | Update berhasil                       | [ ]    |
| 9   | Kirim notifikasi manual         | Kirim Notifikasi         | Notifikasi terkirim                   | [ ]    |
| 10  | Kirim ke guest (Device ID)      | Kirim Notifikasi → Guest | Guest terima notifikasi               | [ ]    |
| 11  | Trigger via odometer update     | Kendaraan → Update       | Notifikasi otomatis terkirim          | [ ]    |
| 12  | Trigger via trip completion     | Perjalanan → Selesaikan  | Notifikasi trip terkirim              | [ ]    |
| 13  | Lihat detail notifikasi         | Daftar → Klik item       | Detail lengkap tampil                 | [ ]    |
| 14  | Delete notifikasi               | Daftar → Delete          | Notifikasi terhapus                   | [ ]    |
| 15  | Verify di Flutter - Badge count | Flutter App              | Badge count akurat                    | [ ]    |
| 16  | Verify di Flutter - Filter tab  | Flutter → Tab kategori   | Filter berfungsi                      | [ ]    |
| 17  | Verify di Flutter - Mark read   | Flutter → Tap notifikasi | Badge count berkurang                 | [ ]    |
| 18  | Verify di Flutter - Push notif  | Trigger dari web         | Push notification muncul              | [ ]    |
| 19  | Guest mode sync after login     | Guest → Login            | Notifikasi guest sync ke user         | [ ]    |
| 20  | Statistics dashboard            | Notifikasi → Statistik   | Chart & graph tampil (jika implement) | [ ]    |

---

## 🎯 Quick Test Flow (10 Menit)

### Test End-to-End

**1. Prepare (2 menit)**

- ✅ Login admin panel
- ✅ Login Flutter app (atau gunakan guest mode)
- ✅ Check initial badge count di Flutter

**2. Test Manual Send (3 menit)**

- ✅ Web: Kirim notifikasi kategori "Servis"
- ✅ Flutter: Verify badge "Servis" bertambah
- ✅ Flutter: Notifikasi muncul di tab "Servis"
- ✅ Flutter: Push notification muncul

**3. Test Automated Trigger (3 menit)**

- ✅ Web/Postman: POST update odometer +30 km
- ✅ Flutter: Verify badge "Perjalanan" bertambah
- ✅ Flutter: Notifikasi "Jarak ditambahkan" muncul
- ✅ Web: Check di daftar notifikasi (kategori: trip)

**4. Test Mark as Read (2 menit)**

- ✅ Flutter: Tap 1 notifikasi belum dibaca
- ✅ Flutter: Badge count berkurang
- ✅ Web: Refresh daftar → Notifikasi status jadi "Dibaca"
- ✅ Flutter: Tap "Tandai Semua Dibaca"
- ✅ Flutter: Badge count jadi 0

**Expected Total Time:** ~10 menit

---

## 📝 Notes & Tips

### Tip 1: Gunakan Incognito untuk Multiple Users

Test multi-user scenario:

1. **Window 1 (normal):** Login sebagai Admin
2. **Window 2 (incognito):** Login sebagai User A
3. **Window 3 (incognito):** Login sebagai User B

Kirim notifikasi dari admin → Verify di user windows

---

### Tip 2: Test Variabel Template

Saat buat template, gunakan variabel:

```
Message: "Halo {user_name}, {vehicle_name} Anda..."
```

Saat kirim, sistem otomatis replace:

```
Output: "Halo John Doe, Honda Beat 2023 Anda..."
```

**Available Variables:** Lihat [NOTIFICATION_CATEGORY_FILTER_API.md](NOTIFICATION_CATEGORY_FILTER_API.md) → Section "Variabel Template"

---

### Tip 3: Test Priority

Buat 2 template dengan priority berbeda:

- **Template A:** Priority = Normal → Icon biasa
- **Template B:** Priority = High → Icon alert, vibrate

Kirim keduanya, verify di Flutter app beda tampilan.

---

### Tip 4: Test Pagination

Jika notifikasi >20:

1. Web: Lihat pagination di bottom table
2. Klik page 2, 3, dst
3. Flutter: Scroll kebawah → Lazy load page berikutnya

---

### Tip 5: Browser DevTools untuk Debug

**Open DevTools (F12):**

**Network Tab:**

- Monitor API calls: `/api/v1/motorcycle/notifications`
- Check response time
- Verify payload

**Console Tab:**

- Check JavaScript errors
- Monitor real-time events

---

## 🔧 Troubleshooting

### Problem: Notifikasi tidak muncul di Flutter

**Check:**

1. ✅ Web admin: Notifikasi tersimpan di database?
2. ✅ Web admin: Target user/device ID benar?
3. ✅ Flutter: FCM token registered?
4. ✅ Flutter: Firebase initialized successfully?
5. ✅ Backend: FCM credentials configured?

**Debug:**

```bash
# Check database
SELECT * FROM notifications
WHERE user_id = 5
ORDER BY created_at DESC
LIMIT 5;

# Check device tokens
SELECT * FROM device_tokens
WHERE user_id = 5;
```

---

### Problem: Badge count tidak akurat

**Check:**

1. ✅ Flutter: Pull-to-refresh di halaman notifikasi
2. ✅ Web admin: Filter "Belum Dibaca" → Count sama dengan badge?
3. ✅ Backend: `read_at` column NULL untuk unread?

**Fix:**

- Flutter: Restart app
- Web: Clear cache & refresh
- Backend: Run migration/seeder ulang

---

### Problem: Push notification tidak terkirim

**Check:**

1. ✅ Backend: `service-account.json` configured?
2. ✅ Backend: FCM library installed?
3. ✅ Flutter: Permission granted?
4. ✅ Flutter: FCM token valid?

**Test Manual:**

- Firebase Console → Cloud Messaging → Send test message
- Target: FCM token dari Flutter debug page

---

## ✅ Success Criteria

**Test dianggap berhasil jika:**

1. ✅ Notifikasi manual terkirim dari admin panel
2. ✅ Notifikasi otomatis terkirim saat trigger event
3. ✅ Filter kategori berfungsi (web & Flutter)
4. ✅ Badge count akurat untuk setiap tab
5. ✅ Mark as read mengurangi badge count
6. ✅ Push notification muncul di device
7. ✅ Guest mode berfungsi normal
8. ✅ Data sync setelah login dari guest

---

## 📚 Related Documentation

- [NOTIFICATION_CATEGORY_FILTER_API.md](NOTIFICATION_CATEGORY_FILTER_API.md) - API documentation lengkap
- [QUICK_TEST_COMMANDS.md](QUICK_TEST_COMMANDS.md) - cURL commands untuk testing
- [TESTING_NOTIFICATION_GUIDE.md](TESTING_NOTIFICATION_GUIDE.md) - Panduan testing komprehensif

---

**Happy Testing! 🎉**

Jika ada masalah, check troubleshooting section atau contact developer.
