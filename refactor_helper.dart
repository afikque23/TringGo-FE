#!/usr/bin/env dart
// Script untuk membantu refactor hardcoded colors ke theme
//
// Cara penggunaan:
// 1. Buka file yang ingin di-refactor
// 2. Gunakan find & replace dengan pattern berikut
// 3. Review manual setelah replace

// =================================================================
// MAPPING COLORS - COPY PASTE KE FIND & REPLACE DI VS CODE
// =================================================================

/*
LANGKAH 1: Tambahkan di awal build method (setelah parameter context)
--------------------------------------------------------------------
final colorScheme = Theme.of(context).colorScheme;


LANGKAH 2: Find & Replace Pattern (gunakan Regex)
--------------------------------------------------------------------

Pattern 1 - Background Color
FIND:    const Color\(0xFF0A0A0A\)
REPLACE: Theme.of(context).scaffoldBackgroundColor

Pattern 2 - Surface Color
FIND:    const Color\(0xFF1A1A1A\)
REPLACE: colorScheme.surface

Pattern 3 - Surface Variant
FIND:    const Color\(0xFF252525\)
REPLACE: colorScheme.surfaceContainerHighest

Pattern 4 - Primary Color
FIND:    const Color\(0xFF6B7C4F\)
REPLACE: colorScheme.primary

Pattern 5 - Secondary/Inactive Color
FIND:    const Color\(0xFF99A1AF\)
REPLACE: colorScheme.secondary

Pattern 6 - Border Dark
FIND:    const Color\(0xFF364153\)
REPLACE: colorScheme.outline

Pattern 7 - Border Light/Divider
FIND:    const Color\(0xFF1E2939\)
REPLACE: colorScheme.outlineVariant

Pattern 8 - Text Color (white)
FIND:    Colors\.white
REPLACE: colorScheme.onSurface

Pattern 9 - Text Secondary
FIND:    const Color\(0xFF6A7282\)
REPLACE: colorScheme.onSurfaceVariant

Pattern 10 - Text Light
FIND:    const Color\(0xFFD1D5DC\)
REPLACE: colorScheme.onSurface

Pattern 11 - Error Color
FIND:    const Color\(0xFFFF6467\)
REPLACE: colorScheme.error

Pattern 12 - Tertiary/Blue
FIND:    const Color\(0xFF51A2FF\)
REPLACE: colorScheme.tertiary

Pattern 13 - Warning Color (import extension dari app_theme.dart)
FIND:    const Color\(0xFFFDC700\)
REPLACE: colorScheme.warning

Pattern 14 - Warning Alt
FIND:    const Color\(0xFFF0B100\)  
REPLACE: colorScheme.warningAlt


LANGKAH 3: Hapus 'const' keyword dari widget yang menggunakan Theme.of(context)
--------------------------------------------------------------------
Gunakan Find & Replace dengan hati-hati:

FIND:    const (.*?)BoxDecoration\(
REPLACE: BoxDecoration(

FIND:    const (.*?)TextStyle\(
REPLACE: TextStyle(

NOTE: Setelah replace, review manual dan tambahkan kembali 'const' 
      untuk widget yang tidak bergantung pada context


LANGKAH 4: Update SystemUiOverlayStyle
--------------------------------------------------------------------
FIND:    
SystemUiOverlayStyle\.light\.copyWith\(
        statusBarColor: Colors\.transparent,
        statusBarIconBrightness: Brightness\.light,
      \)

REPLACE:
SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
      )


LANGKAH 5: Cleanup - Hapus unused const yang menyebabkan error
--------------------------------------------------------------------
Jalankan:
dart analyze

Atau gunakan VS Code Quick Fix untuk menghapus const yang tidak perlu


LANGKAH 6: Format code
--------------------------------------------------------------------
Jalankan:
dart format lib/


=================================================================
SPECIAL CASES - Manual Editing Required
=================================================================

1. Colors with opacity/alpha:
   BEFORE: Color(0xFF6B7C4F).withOpacity(0.1)
   AFTER:  colorScheme.primary.withOpacity(0.1)
   atau:   colorScheme.primary.withValues(alpha: 0.1)

2. Conditional colors:
   BEFORE: isActive ? Color(0xFF6B7C4F) : Color(0xFF252525)
   AFTER:  isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest

3. showDatePicker/showDialog themes:
   Lihat contoh di tambah_jarak.dart

4. SnackBar:
   BEFORE: backgroundColor: Color(0xFFFF6467)
   AFTER:  backgroundColor: colorScheme.error

5. Date Picker Theme:
   Lihat contoh di tambah_jarak.dart line 50-70

6. Dropdown colors:
   dropdownColor: colorScheme.surface


=================================================================
CHECKLIST SETELAH REFACTORING
=================================================================

☐ Tambahkan: final colorScheme = Theme.of(context).colorScheme;
☐ Replace semua hardcoded Color(...) sesuai mapping
☐ Update SystemUiOverlayStyle brightness
☐ Hapus const yang tidak perlu
☐ Test di light mode
☐ Test di dark mode
☐ Jalankan: dart analyze
☐ Jalankan: dart format lib/
☐ Test fungsionalitas app


=================================================================
FILES PRIORITY - Urutan Refactoring
=================================================================

DONE ✅:
- lib/core/utils/app_theme.dart
- lib/main.dart  
- lib/features/widget/bottom_navbar.dart
- lib/features/splashscreen/splashcreen.dart
- lib/features/dashboard/widgets/tambah_jarak.dart

TODO (High Priority) ⏳:
- lib/features/dashboard/dashboard.dart
- lib/features/servis/service.dart
- lib/features/servis/schedule/jadwal.dart
- lib/features/servis/schedule/tambah_jadwal.dart
- lib/features/servis/schedule/detail_jadwal.dart
- lib/features/servis/history/riwayat_service.dart
- lib/features/servis/history/tambah_riwayat_service.dart
- lib/features/auth/login_page.dart
- lib/features/auth/register_page.dart
- lib/features/profil/profil_page.dart

TODO (Medium Priority):
- All other dashboard widgets
- All other auth pages
- All profile sub-pages
- Notification page

TODO (Low Priority):
- Onboarding pages (bisa tetap hardcoded jika mau)


=================================================================
TESTING GUIDE
=================================================================

1. Ubah main.dart themeMode untuk test:
   - ThemeMode.light  // Test light mode
   - ThemeMode.dark   // Test dark mode (default)
   - ThemeMode.system // Follow system

2. Test semua halaman yang sudah di-refactor

3. Pastikan tidak ada color yang "aneh" atau tidak matching

4. Check console untuk errors


=================================================================
TIPS & TRICKS
=================================================================

1. Gunakan VS Code Multi-cursor (Alt+Click) untuk edit multiple lines

2. Gunakan VS Code Find & Replace dengan Regex enabled

3. Commit setelah selesai refactor 1-2 file untuk mudah rollback

4. Test di device/emulator untuk lihat hasil real

5. Jika bingung warna apa yang dipakai, check THEME_MIGRATION_GUIDE.md

*/

void main() {
  print('Baca komentar di file ini untuk panduan refactoring!');
  print('Lihat juga THEME_MIGRATION_GUIDE.md');
}
