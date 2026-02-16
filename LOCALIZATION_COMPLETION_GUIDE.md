# 🌐 Localization Implementation Guide

## ✅ COMPLETED (100%)

### 1. **Translation Files (130+ keys)**

- ✅ `lib/l10n/app_en.arb` - English translations
- ✅ `lib/l10n/app_id.arb` - Indonesian translations
- ✅ Auto-generated files (app_localizations.dart, app_localizations_en.dart, app_localizations_id.dart)

### 2. **Fully Localized Pages**

#### Service Module (100%)

- ✅ `lib/features/servis/service.dart`
- ✅ `lib/features/servis/schedule/jadwal.dart`
- ✅ `lib/features/servis/schedule/detail_jadwal.dart`
- ✅ `lib/features/servis/schedule/tambah_jadwal.dart`
- ✅ `lib/features/servis/history/riwayat_service.dart`
- ✅ `lib/features/servis/history/tambah_riwayat_service.dart`
- ✅ `lib/features/servis/history/edit_riwayat_service.dart`

#### Core Components (100%)

- ✅ `lib/features/widget/bottom_navbar.dart`
- ✅ `lib/features/splashscreen/splashcreen.dart`

#### Profile Module (Partial)

- ✅ `lib/features/profil/profil_page.dart` (Main profile page - DONE)
- ✅ `lib/features/profil/edit_profil.dart` (Edit profile - DONE)
- 🔧 `lib/features/profil/preferensi_aplikasi/preferensi_aplikasi.dart` (Structure added)
- 📝 `lib/features/profil/notifikasi/notifikasi_setting.dart` (Import needed)
- 📝 `lib/features/profil/privasi_keamanan/privasi_dan_keamanan.dart` (Import needed)
- 📝 `lib/features/profil/bantuan_dukungan/bantuan_dukungan.dart` (Import needed)
- 📝 `lib/features/profil/tentang/tentang.dart` (Import needed)

---

## 📋 QUICK IMPLEMENTATION PATTERN

For remaining pages, follow this 3-step pattern:

### Step 1: Add Import

```dart
import '../../l10n/app_localizations.dart';
// or '../../../l10n/app_localizations.dart' (adjust path)
```

### Step 2: Add l10n Variable

In `build()` method or any method that uses Text widgets:

```dart
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!; // ADD THIS LINE

  return Scaffold(...);
}
```

### Step 3: Replace Text Strings

```dart
// BEFORE:
Text('Notifikasi')

// AFTER:
Text(l10n.notificationSettings)
```

---

## 🔑 AVAILABLE TRANSLATION KEYS

### Profile & Settings

```dart
l10n.editProfile              // "Edit Profil" / "Edit Profile"
l10n.fullName                 // "Nama Lengkap" / "Full Name"
l10n.phoneNumber              // "Nomor Telepon" / "Phone Number"
l10n.location                 // "Lokasi" / "Location"
l10n.optional                 // "Opsional" / "Optional"
l10n.saveChanges              // "Simpan Perubahan" / "Save Changes"
l10n.updateProfilePhoto       // "Perbarui foto profil" / "Update profile photo"
l10n.profileUpdateTip         // Tips for profile update
```

### Theme & Display

```dart
l10n.theme                    // "Tema" / "Theme"
l10n.systemDefault            // "Sistem Default" / "System Default"
l10n.lightTheme               // "Tema Terang" / "Light Theme"
l10n.darkTheme                // "Tema Gelap" / "Dark Theme"
l10n.display                  // "Tampilan" / "Display"
```

### Units & Settings

```dart
l10n.units                    // "Satuan" / "Units"
l10n.distanceUnit             // "Satuan Jarak" / "Distance Unit"
l10n.kilometers               // "Kilometer" / "Kilometers"
l10n.miles                    // "Mil" / "Miles"
l10n.fuelUnit                 // "Satuan Bahan Bakar" / "Fuel Unit"
l10n.liters                   // "Liter" / "Liters"
l10n.gallons                  // "Galon" / "Gallons"
```

### GPS & Battery

```dart
l10n.gpsAndBattery            // "GPS & Baterai" / "GPS & Battery"
l10n.autoStartGPS             // "Mulai GPS Otomatis" / "Auto-start GPS"
l10n.autoStartGPSDesc         // Description
l10n.batteryOptimization      // "Optimasi Baterai" / "Battery Optimization"
l10n.batteryOptimizationDesc  // Description
```

###Notifications

```dart
l10n.allNotifications                // "Semua Notifikasi" / "All Notifications"
l10n.enableDisableAll                // Enable/disable text
l10n.maintenanceNotifications        // "Notifikasi Perawatan"
l10n.scheduleReminders               // "Pengingat Jadwal"
l10n.scheduleRemindersDesc           // Description
l10n.urgentMaintenanceNotif          // "Perawatan Mendesak"
l10n.urgentMaintenanceNotifDesc      // Description
l10n.periodicServiceNotif            // "Servis Berkala"
l10n.periodicServiceNotifDesc        // Description
l10n.tripNotifications               // "Notifikasi Perjalanan"
l10n.dailySummary                    // "Ringkasan Harian"
l10n.dailySummaryDesc                // Description
l10n.weeklySummary                   // "Ringkasan Mingguan"
l10n.weeklySummaryDesc               // Description
l10n.longTripAlert                   // "Peringatan Perjalanan Jauh"
l10n.longTripAlertDesc               // Description
l10n.vehicleNotifications            // "Notifikasi Kendaraan"
l10n.vehicleSwitching                // "Pergantian Kendaraan"
l10n.vehicleSwitchingDesc            // Description
l10n.vehicleStatus                   // "Status Kendaraan"
l10n.vehicleStatusDesc               // Description
l10n.systemNotifications             // "Notifikasi Sistem"
l10n.appUpdates                      // "Update Aplikasi"
l10n.appUpdatesDesc                  // Description
l10n.syncErrors                      // "Error Sinkronisasi"
l10n.syncErrorsDesc                  // Description
l10n.recommendedSettings             // "Pengaturan Direkomendasikan"
l10n.recommendedSettingsDesc         // Description
```

### Privacy & Security

```dart
l10n.privacySettings          // "Pengaturan Privasi"
l10n.shareLocation            // "Bagikan Data Lokasi"
l10n.shareLocationDesc        // Description
l10n.shareTripData            // "Bagikan Data Perjalanan"
l10n.shareTripDataDesc        // Description
l10n.analyticsUsage           // "Analitik & Data Penggunaan"
l10n.analyticsUsageDesc       // Description
l10n.accountSecurity          // "Keamanan Akun"
l10n.changePassword           // "Ubah Kata Sandi"
l10n.changePasswordDesc       // Description
l10n.twoFactorAuth            // "Autentikasi Dua Faktor"
l10n.twoFactorAuthDesc        // Description
l10n.activeSessions           // "Sesi Aktif"
l10n.activeSessionsDesc       // Description
l10n.dataManagement           // "Manajemen Data"
l10n.downloadMyData           // "Unduh Data Saya"
l10n.downloadMyDataDesc       // Description
l10n.clearCache               // "Hapus Cache"
l10n.clearCacheDesc           // Description
l10n.dangerZone               // "Zona Berbahaya"
l10n.deleteAccount            // "Hapus Akun"
l10n.deleteAccountDesc        // Description
l10n.deleteAccountConfirm     // Confirmation message
l10n.clearCacheConfirm        // Confirmation message
```

### Help & Support

```dart
l10n.contactUs                // "Hubungi Kami"
l10n.getInTouch               // "Hubungi tim dukungan"
l10n.emailSupport             // "Dukungan Email"
l10n.emailSupportDesc         // Description
l10n.sendEmail                // "Kirim Email"
l10n.whatsappSupport          // "Dukungan WhatsApp"
l10n.whatsappSupportDesc      // Description
l10n.openWhatsApp             // "Buka WhatsApp"
l10n.phoneSupport             // "Dukungan Telepon"
l10n.phoneSupportDesc         // Description
l10n.callNow                  // "Hubungi Sekarang"
l10n.faq                      // "Pertanyaan yang Sering Diajukan"
l10n.findAnswers              // "Temukan jawaban"
l10n.resources                // "Sumber Daya"
l10n.helpfulLinks             // "Link berguna"
l10n.userGuide                // "Panduan Pengguna"
l10n.userGuideDesc            // Description
l10n.termsConditions          // "Syarat & Ketentuan"
l10n.termsConditionsDesc      // Description
l10n.privacyPolicy            // "Kebijakan Privasi"
l10n.privacyPolicyDesc        // Description
```

### About & Version

```dart
l10n.about                    // "Tentang"
l10n.appVersion               // "Versi Aplikasi"
l10n.buildNumber              // "Nomor Build"
l10n.lastUpdated              // "Terakhir Diperbarui"
l10n.madeWithLove             // "Dibuat dengan ❤️ di Indonesia"
l10n.followUs                 // "Ikuti Kami"
l10n.instagram                // "Instagram"
l10n.twitter                  // "Twitter"
l10n.facebook                 // "Facebook"
```

### Common Actions

```dart
l10n.save                     // "Simpan" / "Save"
l10n.cancel                   // "Batal" / "Cancel"
l10n.delete                   // "Hapus" / "Delete"
l10n.edit                     // "Ubah" / "Edit"
l10n.confirm                  // "Konfirmasi" / "Confirm"
l10n.yes                      // "Ya" / "Yes"
l10n.no                       // "Tidak" / "No"
l10n.loading                  // "Memuat" / "Loading"
```

---

## 📝 EXAMPLE: Localization Template

Here's a complete example for any page:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart'; // STEP 1

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!; // STEP 2

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // STEP 3: Use l10n
      ),
      body: Column(
        children: [
          Text(l10n.appPreferences),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 PRIORITY FOR REMAINING PAGES

1. **HIGH PRIORITY** (User-facing, frequently accessed):
   - `preferensi_aplikasi.dart` - App settings
   - `notifikasi_setting.dart` - Notification preferences
2. **MEDIUM PRIORITY** (Security & privacy):
   - `privasi_dan_keamanan.dart` - Privacy settings
3. **LOW PRIORITY** (Info pages, rarely changed):
   - `bantuan_dukungan.dart` - Help pages
   - `panduan_pengguna.dart` - User guide
   - `kebijakan_privasi.dart` - Privacy policy
   - `syarat_ketentuan.dart` - Terms & conditions
   - `tentang.dart` - About page

---

## 🚀 HOW TO TEST

1. Run the app:

   ```bash
   flutter run
   ```

2. Go to **Profil** → **Preferensi Aplikasi** → **Bahasa**

3. Switch between **Bahasa Indonesia** and **English**

4. All completed pages will automatically change language! 🎉

---

## ✨ WHAT'S WORKING NOW

- ✅ Bottom navigation automatically switches language
- ✅ Service pages (overview, schedule, history) are bilingual
- ✅ Profile page shows correct language
- ✅ Language selection persists across app restarts
- ✅ All service records, forms, and schedules support both languages

---

## 📊 COMPLETION STATUS

| Module                | Progress | Status                |
| --------------------- | -------- | --------------------- |
| Service & Maintenance | 100%     | ✅ Complete           |
| Navigation & Splash   | 100%     | ✅ Complete           |
| Profile Main          | 100%     | ✅ Complete           |
| Edit Profile          | 100%     | ✅ Complete           |
| App Preferences       | 50%      | 🟡 Structure Ready    |
| Notifications         | 0%       | 📝 Translations Ready |
| Privacy & Security    | 0%       | 📝 Translations Ready |
| Help & Support        | 0%       | 📝 Translations Ready |
| About                 | 0%       | 📝 Translations Ready |

**Overall: ~75% Complete**

All translations are ready, only implementation needed for remaining pages.

---

## 💡 PRO TIPS

1. **Use Find & Replace** in VS Code for batch text replacement:
   - Find: `'Notifikasi'`
   - Replace: `l10n.notificationSettings`

2. **Check for Dialog Context**: When using l10n in dialogs, make sure to get it from the correct context:

   ```dart
   showDialog(
     context: context,
     builder: (BuildContext dialogContext) {
       final l10n = AppLocalizations.of(dialogContext)!;
       return AlertDialog(title: Text(l10n.confirm));
     },
   );
   ```

3. **Handle null safety**: Always use `!` after `AppLocalizations.of(context)` since we guarantee it's not null.

4. **Test both languages**: Always test with both Indonesian and English to ensure all text is properly translated.

---

## 🎓 LEARNING RESOURCES

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/googlei18n/app-resource-bundle)
- Project localization guide: `LOCALIZATION_GUIDE.md`

---

**Created:** February 5, 2026  
**Last Updated:** February 5, 2026  
**Status:** Ready for completion
