# Troubleshooting: Data Hilang / Data Loss Issue

## 🐛 Masalah yang Sudah Diperbaiki

**Gejala:**

- Data kendaraan dan jadwal servis hilang setelah app dibuka kembali
- Error: `TimeoutException after 0:00:30.000000: Future not completed`
- Data ada di database tapi tidak muncul di app

**Penyebab:**
Bug di `vehicle_service.dart` yang menghapus local storage ketika server merespons dengan data kosong (walaupun sebenarnya data ada di local storage).

**Solusi:**
✅ Sudah diperbaiki! Sekarang app akan mempertahankan data lokal jika server return empty.

---

## 🔍 Cara Debugging Masalah Serupa

### 1. Cek Log dengan Attention

Setelah fix ini, log akan menampilkan informasi lebih detail:

```
✓ Primary vehicle from server: Honda PCX (ID: 2)     ← Berhasil dari server
📦 Fallback: Using 3 vehicles from local storage    ← Menggunakan data lokal
⚠️ WARNING: Server returned empty vehicles...        ← Peringatan masalah sync
❌ Failed to fetch from server: TimeoutException    ← Error koneksi
```

### 2. Periksa Koneksi Server

```bash
# Di terminal, cek apakah server Laravel berjalan
php artisan serve --host=0.0.0.0 --port=8000

# Test koneksi dari emulator/device
curl http://10.0.2.2:8000/api/v1/motorcycle/vehicles
```

### 3. Cek Token Authentication

Jika log menunjukkan "Server returned empty vehicles":

**Kemungkinan penyebab:**

1. Token expired → User perlu login ulang
2. Device ID berubah → Clear app data & login ulang
3. Bearer token tidak dikirim dengan benar

**Solusi:**

- Logout dan login kembali
- Clear app cache
- Restart app

### 4. Verifikasi Data di Database

```sql
-- Cek vehicles milik user
SELECT * FROM vehicles WHERE user_id = [YOUR_USER_ID];

-- Cek vehicles dengan device_id (untuk guest mode)
SELECT * FROM vehicles WHERE device_id = '[YOUR_DEVICE_ID]';
```

---

## 🛡️ Pencegahan di Masa Depan

### Best Practices yang Sudah Diterapkan:

1. ✅ **Data Protection**: Tidak menghapus local data jika server return empty
2. ✅ **Better Logging**: Log yang informatif untuk debugging
3. ✅ **Graceful Fallback**: Selalu fallback ke local storage jika server error
4. ✅ **Data Sync Validation**: Validasi sebelum replace local storage

### Recommended untuk Development:

1. **Selalu cek log** saat testing:

   ```bash
   flutter run
   # Perhatikan output log dengan emoji indicator
   ```

2. **Test offline scenario**:
   - Matikan WiFi/data
   - Buka app → harus bisa load data dari local storage
   - Nyalakan internet → data otomatis sync

3. **Test token expiration**:
   - Login → buat data
   - Tunggu token expire (biasanya 1 jam)
   - Buka app lagi → lihat log warning
   - Login ulang → data sync kembali

---

## 🔧 Manual Recovery (Jika Data Sudah Hilang)

Jika data sudah terhapus dan tidak bisa di-recover dari local storage:

### Option 1: Restore dari Server

1. Pastikan koneksi internet stabil
2. Logout dari app
3. Login kembali
4. Data akan di-sync dari server

### Option 2: Re-input Manual

Jika data tidak ada di server, harus input ulang:

1. Tambah kendaraan baru
2. Set sebagai primary vehicle
3. Tambah jadwal servis
4. Tambah riwayat servis (jika ada)

---

## 📊 Monitoring Logs

### Log Normal (Semua Baik):

```
Fetching vehicles from server: http://10.0.2.2:8000/api/v1/motorcycle/vehicles
Server response: 200
Server returned 3 vehicles
Syncing 3 vehicles to local storage
✓ Primary vehicle from server: Honda PCX (ID: 2)
```

### Log Warning (Perlu Perhatian):

```
Server response: 200
Server returned 0 vehicles
⚠️ WARNING: Server returned empty vehicles but local storage has 3 vehicles.
⚠️ Keeping local data as safeguard. This may indicate:
  - Token expiration or invalid auth
  - Device ID mismatch
  - Server filtering issue
📦 Fallback: Using 3 vehicles from local storage
```

### Log Error (Fallback ke Local):

```
❌ Failed to fetch from server: TimeoutException after 0:00:30.000000
📦 Fallback: Using 3 vehicles from local storage
```

### Log Critical (Tidak Ada Data):

```
❌ Failed to fetch from server: TimeoutException
📦 Fallback: Using 0 vehicles from local storage
⚠️ No primary vehicle found in local storage either
```

---

## 💡 Tips untuk User

### Jika Melihat Warning di Log:

1. **Jangan panic** - data Anda masih aman di local storage
2. **Cek koneksi internet** - pastikan stabil
3. **Restart app** - kadang membantu
4. **Login ulang** - refresh token dan session

### Untuk Menghindari Data Loss:

1. ✅ Jangan clear app data/cache sembarangan
2. ✅ Pastikan koneksi stabil saat input data penting
3. ✅ Login saat online agar data ter-sync ke server
4. ✅ Update app secara berkala

---

## 🆘 Masih Bermasalah?

Jika setelah fix ini masih ada masalah:

1. **Capture full log** dari terminal saat app berjalan
2. **Note kondisi**:
   - User logged in atau guest mode?
   - Koneksi internet stabil?
   - Sudah berapa lama login terakhir?
3. **Kirim info ke developer** dengan format:
   ```
   Issue: [deskripsi masalah]
   Log: [copy paste log]
   Steps to reproduce: [langkah-langkah]
   ```

---

**Last Updated:** February 17, 2026
**Fixed in Version:** Current
**Priority:** Critical (RESOLVED ✅)
