# 🌍 Quick Reference - Multi-Bahasa

## ✅ Sudah Terimplementasi

### 📄 File Localization

- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_id.arb` - Indonesian translations (Bahasa Indonesia)
- `lib/l10n/app_localizations.dart` - Auto-generated

### 📱 Halaman yang Sudah Menggunakan Localization

- ✅ **[service.dart](lib/features/servis/service.dart)** - Halaman maintenance/service
- ✅ **[preferensi_aplikasi.dart](lib/features/profil/preferensi_aplikasi/preferensi_aplikasi.dart)** - Language switcher

## 🚀 Cara Cepat Implementasi di Halaman Baru

### 1. Import AppLocalizations

```dart
import '../../l10n/app_localizations.dart'; // Sesuaikan path relatif
```

### 2. Get Instance di Widget

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.appTitle), // Gunakan l10n.namaKey
    ),
    body: Column(
      children: [
        Text(l10n.welcome),
        Text(l10n.service),
        ElevatedButton(
          onPressed: () {},
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
```

### 3. Untuk StatefulWidget dengan Multiple Methods

```dart
class MyPage extends StatefulWidget {
  // ...
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context), // Pass context
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get lagi di setiap method

    return Text(l10n.welcome);
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(l10n.home),
        Text(l10n.profile),
      ],
    );
  }
}
```

## 📋 Daftar Terjemahan yang Tersedia

### Common

- `appTitle` - Judul aplikasi
- `welcome` - Selamat Datang / Welcome
- `home` - Beranda / Home
- `profile` - Profil / Profile
- `settings` - Pengaturan / Settings
- `service` - Servis / Service

### Actions

- `save` - Simpan / Save
- `cancel` - Batal / Cancel
- `delete` - Hapus / Delete
- `edit` - Ubah / Edit
- `add` - Tambah / Add
- `search` - Cari / Search
- `confirm` - Konfirmasi / Confirm
- `yes` - Ya / Yes
- `no` - Tidak / No

### Status

- `loading` - Memuat... / Loading...
- `success` - Berhasil / Success
- `failed` - Gagal / Failed
- `error` - Kesalahan / Error
- `noData` - Tidak Ada Data / No Data Available

### Service Page Specific

- `overview` - Overview
- `schedule` - Schedule
- `history` - History
- `overallStatus` - Status Keseluruhan / Overall Status
- `good` - Baik / Good
- `urgent` - Darurat / Urgent
- `soon` - Segera / Soon
- `recommendations` - Rekomendasi / Recommendations
- `urgentMaintenance` - Segera Lakukan Perawatan / Urgent Maintenance Required
- `planMaintenance` - Rencanakan Perawatan / Plan Maintenance
- `totalComponents` - Total Komponen / Total Components
- `needsAttention` - Perlu Perhatian / Needs Attention
- `monitored` - dipantau / monitored
- `item` - item / item
- `usagePatternSummary` - Ringkasan Pola Penggunaan Kendaraan / Vehicle Usage Pattern Summary
- `lightUsage` - Penggunaan Ringan / Light Usage
- `average` - Rata-rata / Average
- `thisWeek` - Minggu ini / This Week
- `odometer` - Odometer / Odometer
- `km` - km / km
- `kmPerDay` - km/hari / km/day
- `kmTotal` - km total / km total

### Auth

- `login` - Masuk / Login
- `logout` - Keluar / Logout
- `register` - Daftar / Register
- `email` - Email
- `password` - Kata Sandi / Password
- `name` - Nama / Name

### Motorcycle

- `motorcycle` - Motor / Motorcycle
- `motorcyclePlate` - Nomor Plat / Plate Number
- `motorcycleBrand` - Merek / Brand
- `motorcycleModel` - Model / Model
- `motorcycleYear` - Tahun / Year

**Lihat file lengkap:** [app_en.arb](lib/l10n/app_en.arb) dan [app_id.arb](lib/l10n/app_id.arb)

## 🎯 Menambah Terjemahan Baru

### Step 1: Tambah ke file ARB

**app_en.arb:**

```json
{
  "@@locale": "en",
  "existingKey": "Existing Text",
  "newKey": "New English Text"
}
```

**app_id.arb:**

```json
{
  "@@locale": "id",
  "existingKey": "Teks Yang Ada",
  "newKey": "Teks Bahasa Indonesia Baru"
}
```

### Step 2: Generate ulang

```bash
flutter pub get
```

### Step 3: Gunakan!

```dart
Text(l10n.newKey)
```

## 🌐 Mengganti Bahasa

### Dari UI (Preferensi Aplikasi):

1. Profile → Preferensi Aplikasi → Bahasa
2. Pilih 🇮🇩 Bahasa Indonesia atau 🇬🇧 English
3. Selesai! Bahasa berubah otomatis

### Dari Kode:

```dart
import '../core/utils/language_manager.dart';

// Get manager
final languageManager = LanguageProvider.of(context);

// Ganti bahasa
languageManager.setLocale(const Locale('id')); // Indonesia
languageManager.setLocale(const Locale('en')); // English

// Cek bahasa aktif
String currentLang = languageManager.locale.languageCode; // 'id' or 'en'
```

## ⚡ Tips & Best Practices

### ✅ DO:

- Selalu gunakan `l10n.namaKey` untuk semua teks UI
- Get `AppLocalizations` di setiap method yang butuh
- Test kedua bahasa (Indonesia & English)
- Nama key harus camelCase: `myNewKey`, `vehicleCondition`

### ❌ DON'T:

- Jangan hardcode string: ~~`Text('Selamat Datang')`~~ ❌
- Jangan simpan `l10n` di variable class
- Jangan lupa menjalankan `flutter pub get` setelah update ARB

## 🐛 Troubleshooting

### Error: "AppLocalizations not found"

**Solusi:** Jalankan `flutter pub get`

### Teks tidak berubah setelah ganti bahasa

**Solusi:** Pastikan sudah menggunakan `l10n.namaKey`, bukan hardcoded string

### Error: "The getter 'namaKey' isn't defined"

**Solusi:**

1. Pastikan key ada di file ARB
2. Jalankan `flutter pub get`
3. Restart IDE/Editor

## 📚 File Dokumentasi

- [LOCALIZATION_GUIDE.md](LOCALIZATION_GUIDE.md) - Panduan lengkap
- [LOCALIZATION_QUICK_START.md](LOCALIZATION_QUICK_START.md) - Quick start guide
- [SERVICE_LOCALIZATION_IMPLEMENTATION.md](SERVICE_LOCALIZATION_IMPLEMENTATION.md) - Detail implementasi service page

---

**Happy Coding! 🚀**
