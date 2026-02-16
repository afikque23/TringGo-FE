# Quick Start - Menggunakan Multi-Bahasa

## 🚀 Cara Cepat Menggunakan

### 1. Import AppLocalizations di widget Anda:

```dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart'; // Sesuaikan path relatif dari file Anda

class ContohPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dapatkan instance localization
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle), // "Manajemen Motor" atau "Motorcycle Management"
      ),
      body: Column(
        children: [
          Text(l10n.welcome),  // "Selamat Datang" atau "Welcome"
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.login), // "Masuk" atau "Login"
          ),
        ],
      ),
    );
  }
}
```

### 2. Mengganti Bahasa

Sudah ada halaman settings siap pakai di:
`lib/features/settings/settings_example_page.dart`

Navigasi ke halaman ini:

```dart
import 'package:flutter/material.dart';
import 'features/settings/settings_example_page.dart';

// Di dalam onTap atau onPressed:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SettingsExamplePage(),
  ),
);
```

### 3. Ganti Bahasa Secara Programatis

```dart
import '../core/utils/language_manager.dart';

// Ganti ke Bahasa Indonesia
LanguageProvider.of(context).setLocale(const Locale('id'));

// Ganti ke English
LanguageProvider.of(context).setLocale(const Locale('en'));
```

## 📝 Teks yang Sudah Tersedia

Berikut beberapa teks yang sudah bisa langsung digunakan:

| Kode                  | Indonesia       | English               |
| --------------------- | --------------- | --------------------- |
| `l10n.appTitle`       | Manajemen Motor | Motorcycle Management |
| `l10n.welcome`        | Selamat Datang  | Welcome               |
| `l10n.login`          | Masuk           | Login                 |
| `l10n.logout`         | Keluar          | Logout                |
| `l10n.home`           | Beranda         | Home                  |
| `l10n.profile`        | Profil          | Profile               |
| `l10n.settings`       | Pengaturan      | Settings              |
| `l10n.save`           | Simpan          | Save                  |
| `l10n.cancel`         | Batal           | Cancel                |
| `l10n.delete`         | Hapus           | Delete                |
| `l10n.edit`           | Ubah            | Edit                  |
| `l10n.add`            | Tambah          | Add                   |
| `l10n.search`         | Cari            | Search                |
| `l10n.motorcycle`     | Motor           | Motorcycle            |
| `l10n.service`        | Servis          | Service               |
| `l10n.serviceHistory` | Riwayat Servis  | Service History       |

Dan masih banyak lagi! Lihat file `lib/l10n/app_en.arb` untuk daftar lengkap.

## ✅ Selesai!

Aplikasi Anda sekarang sudah mendukung 2 bahasa dan pilihan bahasa akan otomatis tersimpan!
