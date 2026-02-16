# Panduan Multi-Bahasa (Localization) - Motorcycle Management App

## 📋 Ringkasan

Aplikasi ini sudah mendukung 2 bahasa:

- 🇮🇩 Bahasa Indonesia (Default)
- 🇬🇧 English

## 🚀 Cara Menggunakan

### 1. Mengakses Teks Terjemahan di Widget

```dart
import '../../l10n/app_localizations.dart'; // Sesuaikan path relatif

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dapatkan instance AppLocalizations
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle), // Menggunakan terjemahan
      ),
      body: Column(
        children: [
          Text(l10n.welcome),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }
}
```

### 2. Mengubah Bahasa Secara Programatis

```dart
import 'package:flutter/material.dart';
import '../core/utils/language_manager.dart';

// Di dalam widget Anda
void changeTo Indonesian(BuildContext context) {
  final languageManager = LanguageProvider.of(context);
  languageManager.setLocale(const Locale('id'));
}

void changeToEnglish(BuildContext context) {
  final languageManager = LanguageProvider.of(context);
  languageManager.setLocale(const Locale('en'));
}
```

### 3. Mendapatkan Bahasa yang Sedang Aktif

```dart
final languageManager = LanguageProvider.of(context);
String currentLang = languageManager.locale.languageCode; // 'id' atau 'en'
```

## 📝 Menambah Terjemahan Baru

### Langkah 1: Tambahkan di file ARB Bahasa Inggris

Edit: `lib/l10n/app_en.arb`

```json
{
  "@@locale": "en",
  "myNewText": "My New Text",
  "..."
}
```

### Langkah 2: Tambahkan di file ARB Bahasa Indonesia

Edit: `lib/l10n/app_id.arb`

```json
{
  "@@locale": "id",
  "myNewText": "Teks Baru Saya",
  "..."
}
```

### Langkah 3: Generate ulang file localization

```bash
flutter pub get
# File akan otomatis di-generate
```

### Langkah 4: Gunakan di kode

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewText)
```

## 📂 Struktur File Localization

```
lib/
  ├── l10n/
  │   ├── app_en.arb    # Terjemahan Bahasa Inggris
  │   └── app_id.arb    # Terjemahan Bahasa Indonesia
  └── core/
      └── utils/
          └── language_manager.dart  # Manager untuk mengelola bahasa
```

## 🎯 Terjemahan yang Sudah Tersedia

| Key                      | Indonesia       | English               |
| ------------------------ | --------------- | --------------------- |
| `appTitle`               | Manajemen Motor | Motorcycle Management |
| `welcome`                | Selamat Datang  | Welcome               |
| `login`                  | Masuk           | Login                 |
| `logout`                 | Keluar          | Logout                |
| `email`                  | Email           | Email                 |
| `password`               | Kata Sandi      | Password              |
| `home`                   | Beranda         | Home                  |
| `profile`                | Profil          | Profile               |
| `settings`               | Pengaturan      | Settings              |
| `darkMode`               | Mode Gelap      | Dark Mode             |
| `language`               | Bahasa          | Language              |
| `save`                   | Simpan          | Save                  |
| `cancel`                 | Batal           | Cancel                |
| `delete`                 | Hapus           | Delete                |
| `edit`                   | Ubah            | Edit                  |
| `add`                    | Tambah          | Add                   |
| Dan masih banyak lagi... |                 |                       |

_Lihat file `lib/l10n/app_en.arb` dan `app_id.arb` untuk daftar lengkap_

## 💡 Contoh Penggunaan di Halaman Settings

Sudah disediakan contoh halaman settings di:
`lib/features/settings/settings_example_page.dart`

Anda bisa menavigasi ke halaman ini untuk mengganti bahasa:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SettingsExamplePage(),
  ),
);
```

## 🔧 Menambah Bahasa Baru (Opsional)

Jika ingin menambah bahasa lain (misal Jepang):

1. Buat file `lib/l10n/app_ja.arb`
2. Tambahkan di `main.dart`:

```dart
supportedLocales: const [
  Locale('id'),
  Locale('en'),
  Locale('ja'), // Tambahkan ini
],
```

3. Jalankan `flutter pub get`

## 📱 Fitur

- ✅ Otomatis menyimpan pilihan bahasa user (menggunakan SharedPreferences)
- ✅ Bahasa default: Indonesia
- ✅ Mendukung hot reload
- ✅ Integrasi dengan Theme Manager (Dark/Light mode)

## 🐛 Troubleshooting

### Error: "AppLocalizations not found"

**Solusi**: Jalankan `flutter pub get` untuk generate file localization

### Teks tidak berubah setelah ganti bahasa

**Solusi**: Pastikan Anda menggunakan `AppLocalizations.of(context)!` untuk mendapatkan teks, bukan hardcode string

### Build error setelah tambah terjemahan baru

**Solusi**:

1. Jalankan `flutter clean`
2. Jalankan `flutter pub get`
3. Restart aplikasi

## 📚 Resources

- [Flutter Internationalization Guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle)
