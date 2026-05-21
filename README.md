# 🏍️ TringGo - Frontend (Mobile App)

![Flutter](https://img.shields.io/badge/Flutter-v3.41.6-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-v3.11.4-0175C2?style=for-the-badge&logo=dart)
![Platforms](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)

**TringGo** adalah aplikasi _motorcycle management_ dan _GPS tracking_ cerdas berbasis IoT yang membantu Anda mengatur perawatan motor, melacak perjalanan, serta memberikan rekomendasi otomatis berdasarkan pemakaian real-time.

---

## ✨ Fitur Utama

- **📍 Real-time GPS Tracking**: Melacak perjalanan (trip) secara langsung dan mengirimkan _command_ (Start/Stop) ke perangkat keras IoT di motor.
- **🛠️ Manajemen Perawatan (Maintenance)**: Pantau kondisi kilometer (odometer), pengingat jadwal servis berkala, serta rekap catatan riwayat servis.
- **💡 Wawasan Pintar (Smart Insights)**: Rekomendasi waktu servis dan prioritas perawatan menggunakan rekomendasi sistem pakar (Fuzzy Logic).
- **🔔 Notifikasi & Pengingat Pribadi**: Terintegrasi dengan Firebase (Push Notifications) agar tidak terlambat melakukan rotasi oli atau perawatan lainnya.
- **🌍 Multi-bahasa**: Mendukung perubahan bahasa secara bawaan (l10n localization).
- **🛡️ Aman & Cepat**: Menggunakan enkripsi Token dan Secure Storage untuk menjaga data Anda tetap aman.

---

## 🚀 Teknologi yang Digunakan

- **Framework Utama**: [Flutter](https://flutter.dev/)
- **Bahasa**: Dart
- **Location API & Peta**: Geolocator
- **Integrasi Cloud**: Firebase Cloud Messaging (FCM)
- **Komunikasi Backend**: HTTP / REST API (terhubung dengan Laravel Backend)

---

## 📂 Struktur Direktori Proyek

Proyek ini menggunakan struktur modular berbasis fitur (_feature-based_):

```text
lib/
 ├── core/          # Berisi networking API (ApiConfig), Base Models, Utils, dan Services umum tiap entitas
 ├── features/      # Modul UI setiap fitur (Dashboard, Notifikasi, Servis, Tracking, Rekomendasi/Fuzzy)
 ├── l10n/          # FIle string terjemahan untuk multi-bahasa (.arb localization)
 ├── widget/        # Kumpulan widget UI tambahan yang dapat digunakan ulang
 └── main.dart      # Entry point inisialisasi aplikasi TringGo
```

---

## 🛠️ Cara Instalasi & Menjalankan (Getting Started)

1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/afikque23/TringGo-FE.git
   cd TringGo-FE
   ```
2. **Pindah ke cabang (branch) pengembangan (khusus Tim Developer):**
   ```bash
   git checkout dev-arya   # Jika Anda Arya
   # atau
   git checkout dev-aji    # Jika Anda Aji
   ```
3. **Download semua dependensi library:**
   ```bash
   flutter pub get
   ```
4. _Opsional_: Set IP Backend (Laravel API) yang sesuai di file `lib/core/network/api_config.dart`.
5. **Jalankan aplikasi ke emulator atau perangkat asli (HP Fisik):**
   ```bash
   flutter run
   ```

---

## 👥 Kolaborasi Tim (Git Workflow)

Aplikasi ini dikembangkan bersama-sama. Berikut adalah daftar cabang (branch) aktif yang dipakai:

- `main` : Cabang paling stabil untuk siap dirilis ke Production.
- `dev-arya` : Area pengembangan terisolasi khusus _task_ atau fitur dari **Arya**.
- `dev-aji` : Area pengembangan terisolasi khusus _task_ atau fitur dari **Aji**.

> **Note:** Lakukan komit perubahan secara berkala ke branch spesifik masing-masing. Jangan push langsung ke `main` tanpa dipastikan stabil.

---

_Dibuat dengan ❤️ untuk sistem Manajemen Sepeda Motor yang Lebih Baik._
