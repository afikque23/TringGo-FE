# 🚨 Quick Fix: Data Hilang / Data Loss

## 📊 Berdasarkan Log Anda

```
Server response: 200
Server returned 0 vehicles
Syncing 0 vehicles to local storage
Primary vehicle response: 404
❌ No primary vehicle found in local storage either
```

## 🔍 Diagnosis

**Masalah Utama**: Server return **0 vehicles** padahal data ada di database.

**Penyebab Paling Mungkin**:

1. 🔐 **Token Authentication Expired/Invalid**
2. 📱 **Device ID berubah atau tidak match**
3. 👤 **User ID tidak match** (login dengan user berbeda)
4. 💾 **Local storage kosong** (sudah terhapus sebelumnya)

---

## ✅ SOLUSI CEPAT

### 1️⃣ **Logout dan Login Ulang** (RECOMMENDED)

Ini akan refresh token dan sync ulang semua data:

```dart
// Di Settings > Logout
// Kemudian Login kembali
```

**Kenapa ini berhasil?**

- Token baru akan di-generate
- Device ID akan di-register ulang
- Data dari server akan di-sync kembali

### 2️⃣ **Clear App Data** (jika logout tidak work)

**Android:**

```
Settings > Apps > Motorcycle Management > Storage > Clear Data
```

**Kemudian:**

1. Buka app
2. Login dengan akun yang sama
3. Data akan di-sync dari server

### 3️⃣ **Manual Check - Jalankan Debug Mode**

Setelah update code terbaru, jalankan:

```bash
flutter run
```

**Perhatikan log baru:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CURRENT AUTH STATUS
Logged in: true/false
Token: eyJ0eXBlIjoiSldUIiwiYWxn...
User ID: 123
Device ID: abc-def-ghi
Local vehicles count: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Cek ini:**

- ✅ `Logged in: true` → Auth OK
- ✅ `Token: eyJ...` → Token ada dan valid
- ✅ `User ID: [number]` → User ID match dengan database
- ❌ `Local vehicles count: 0` → Konfirmasi local storage kosong

---

## 🔧 Debug Step-by-Step

### Step 1: Cek Token di Database

```sql
-- Di database, cek user yang login
SELECT id, email, created_at FROM users WHERE id = [USER_ID_FROM_LOG];

-- Cek vehicles milik user tsb
SELECT * FROM vehicles WHERE user_id = [USER_ID_FROM_LOG];
```

**Hasil yang diharapkan:**

- Ada user dengan ID sesuai
- Ada vehicles dengan user_id yang sama

### Step 2: Cek di Log App (dengan code terbaru)

Setelah run `flutter run`, cari baris ini:

```
🔐 Auth mode: AUTHENTICATED (token: eyJ0eXBlIjoiSldU...)
```

atau

```
👤 Auth mode: GUEST (device: abc-123-def)
```

**Jika AUTHENTICATED:**

- Token harus valid
- User ID harus match dengan yang di database

**Jika GUEST:**

- Device ID harus sama dengan yang terdaftar
- Cek di database: `SELECT * FROM vehicles WHERE device_id = 'abc-123-def'`

### Step 3: Interpretasi Response

#### ✅ Scenario NORMAL (Seharusnya):

```
Server response: 200
Server returned 3 vehicles
💾 Syncing 3 vehicles to local storage
✓ Primary vehicle from server:
   • Name: Honda PCX
   • ID: 2
   • User ID: 1
```

#### ⚠️ Scenario ANDA (Masalah Auth):

```
🔐 Auth mode: AUTHENTICATED (token: eyJ...)
Server response: 200
Server returned 0 vehicles       ← Server tidak return data untuk user/token ini
❌ Both server AND local storage are empty!
💡 Possible causes:
   • Auth failed - showing empty for wrong user    ← INI MASALAHNYA
   • Token expired
   • Device ID mismatch
```

#### 🛡️ Scenario PROTECTED (Code baru akan lakukan ini):

```
Server response: 200
Server returned 0 vehicles
📦 Local storage has 3 vehicles
🛡️ PROTECTING LOCAL DATA!
⚠️ Server returned empty but local storage has 3 vehicles
✅ Using local data instead of syncing empty array
```

---

## 🎯 Action Plan

### Immediate (LAKUKAN SEKARANG):

1. **Run app dengan code terbaru:**

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Perhatikan log** - Akan ada info lengkap tentang auth status

3. **Jika log menunjukkan "Auth mode: GUEST"** padahal seharusnya logged in:
   - Token expired atau hilang
   - **FIX**: Logout dan login ulang

4. **Jika log menunjukkan "Auth mode: AUTHENTICATED"** tapi server return 0:
   - User ID tidak match
   - **FIX**:
     - Cek database - vehicles punya user_id yang mana?
     - Pastikan login dengan user yang benar
     - Clear app data dan login ulang

### Verification:

Setelah fix, log seharusnya seperti ini:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CURRENT AUTH STATUS
Logged in: true
Token: eyJ0eXBlIjoiSldUIiwiYWxn... (length: 500+)
User ID: 1
Device ID: abc-123-def-456
Local vehicles count: 3
Local vehicles:
  • Honda PCX (ID: 2, UserID: 1, Primary: true)
  • Yamaha NMAX (ID: 8, UserID: 1, Primary: false)
  • Kawasaki Ninja (ID: 9, UserID: 1, Primary: true)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 FETCHING VEHICLES FROM SERVER
🔐 Auth mode: AUTHENTICATED (token: eyJ0eXBlIjoiSldU...)
📥 Server response: 200
📊 Server returned 3 vehicles
✅ Sync completed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🆘 Masih Tidak Berhasil?

### Cek Backend Laravel:

```bash
# Di terminal Laravel, tambahkan log
# File: app/Http/Controllers/VehicleController.php

public function index(Request $request)
{
    \Log::info('Vehicle request', [
        'user_id' => $request->user()?->id,
        'device_id' => $request->header('X-Device-ID'),
        'has_token' => !empty($request->bearerToken()),
    ]);

    // ... rest of code
}
```

Kemudian cek `storage/logs/laravel.log` untuk melihat apa yang diterima server.

### Expected vs Actual:

**Expected:**

```json
{
  "user_id": 1,
  "device_id": "abc-123",
  "has_token": true
}
```

**Jika actual berbeda**, berarti ada masalah di auth middleware atau request header.

---

## 💡 Prevention (Setelah Fix)

1. ✅ **Jangan logout sembarangan** - data bisa hilang jika tidak sync
2. ✅ **Pastikan internet stabil** saat add/edit data
3. ✅ **Regular sync** - buka app saat online untuk sync data
4. ✅ **Jangan clear app data** kecuali benar-benar perlu

---

## 📝 Summary

**Root Cause**: Token/Auth issue → Server return empty → Local storage kosong

**Fix**: Logout & Login ulang untuk refresh token dan re-sync data

**Prevention**: Code update sudah protect local data dari sync empty array

---

**Need Help?** Share full log output dari step-by-step di atas! 🚀
