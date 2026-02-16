# Theme Refactoring Progress

## ✅ Completed Files (7/22 = 31.8%)

### Core Theme System

1. ✅ `lib/core/utils/app_theme.dart` - Theme definitions with light/dark modes
2. ✅ `lib/core/utils/theme_manager.dart` - Theme state management with SharedPreferences
3. ✅ `lib/main.dart` - App-level theme integration with ThemeProvider

### Feature Pages

4. ✅ `lib/features/profil/preferensi_aplikasi/preferensi_aplikasi.dart` - Settings with theme toggle
5. ✅ `lib/features/profil/edit_profil.dart` - Profile editing (UI refinements included)
6. ✅ `lib/features/dashboard/widgets/tracking/gps_tracking_page.dart` - GPS tracking main page
7. ✅ `lib/features/dashboard/widgets/tracking/gps_tracking_active_page.dart` - Live tracking page
8. ✅ `lib/features/dashboard/widgets/tambah_motor/tambah_motor.dart` - Add vehicle form
9. ✅ `lib/features/dashboard/widgets/riwayat_trip/detail_trip.dart` - Trip details page
10. ✅ `lib/features/dashboard/widgets/riwayat_trip/riwayat_trip.dart` - Trip history list

## 🔄 Remaining Files (12 files)

### Dashboard & Tracking

- `lib/features/dashboard/widgets/tren_mingguan/pola_mingguan.dart`
- `lib/features/dashboard/widgets/tren_mingguan/statistik_mingguan.dart`
- `lib/features/dashboard/widgets/sistem_work.dart`

### Motor Management

- `lib/features/dashboard/widgets/tambah_motor/list_motor.dart`
- `lib/features/dashboard/widgets/tambah_motor/edit_motor.dart`

### Service Management

- `lib/features/dashboard/widgets/tambah_riwayat_service.dart` (need to find exact path)

### Profile & Settings (7 files)

- `lib/features/profil/bantuan_dukungan/bantuan_dukungan.dart`
- `lib/features/profil/kebijakan_privasi/kebijakan_privasi.dart`
- `lib/features/profil/panduan_pengguna/panduan_pengguna.dart`
- `lib/features/profil/syarat_ketentuan/syarat_ketentuan.dart`
- `lib/features/profil/notifikasi_setting/notifikasi_setting.dart`
- `lib/features/profil/privasi_dan_keamanan/privasi_dan_keamanan.dart`
- `lib/features/profil/tentang/tentang.dart`

## 📋 Color Mapping Reference

Use this reference for consistent theming:

| Hardcoded Color     | ColorScheme Property              | Usage               |
| ------------------- | --------------------------------- | ------------------- |
| `Color(0xFF0A0A0A)` | `colorScheme.surfaceContainerLow` | Scaffold background |
| `Color(0xFF1A1A1A)` | `colorScheme.surface`             | Cards, containers   |
| `Color(0xFFFFFFFF)` | `colorScheme.onSurface`           | Primary text        |
| `Color(0xFFD1D5DC)` | `colorScheme.onSurface`           | Secondary text      |
| `Color(0xFF99A1AF)` | `colorScheme.onSurfaceVariant`    | Hints, labels       |
| `Color(0xFF6B7C4F)` | `colorScheme.primary`             | Buttons, accents    |
| `Color(0xFF1E2939)` | `colorScheme.outlineVariant`      | Borders             |
| `Color(0xFF6A7282)` | `colorScheme.onSurfaceVariant`    | Disabled text       |
| `Colors.white`      | `colorScheme.onSurface`           | General text        |

## 🔧 Refactoring Pattern for Each File

### Step 1: Update build() method

```dart
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Scaffold(
    backgroundColor: colorScheme.surfaceContainerLow,
    // ... rest of code
```

### Step 2: Update SystemUiOverlayStyle (if present)

```dart
AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle(
    statusBarColor: colorScheme.surfaceContainerLow,
    statusBarIconBrightness: colorScheme.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light,
    statusBarBrightness: colorScheme.brightness,
  ),
```

### Step 3: Add colorScheme to helper methods

```dart
Widget _buildSomeWidget() {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    color: colorScheme.surface,
    // ...
```

### Step 4: Replace all hardcoded colors

- Background: `Color(0xFF0A0A0A)` → `colorScheme.surfaceContainerLow`
- Cards: `Color(0xFF1A1A1A)` → `colorScheme.surface`
- Text: `Color(0xFFFFFFFF)` → `colorScheme.onSurface`
- Hints: `Color(0xFF99A1AF)` → `colorScheme.onSurfaceVariant`
- Primary: `Color(0xFF6B7C4F)` → `colorScheme.primary`
- Borders: `Color(0xFF1E2939)` → `colorScheme.outlineVariant`

### Step 5: Remove `const` where needed

Remove `const` from widgets that use `colorScheme` since they're no longer compile-time constants.

## 🎯 Quick Find & Replace Regex Patterns

Use these in VS Code for faster refactoring:

1. **Find all hardcoded colors:**

   ```regex
   Color\(0xFF[0-9A-F]{6}\)
   ```

2. **Common replacements:**
   - `const Color(0xFF0A0A0A)` → `colorScheme.surfaceContainerLow`
   - `const Color(0xFF1A1A1A)` → `colorScheme.surface`
   - `const Color(0xFFFFFFFF)` → `colorScheme.onSurface`
   - `const Color(0xFF99A1AF)` → `colorScheme.onSurfaceVariant`
   - `const Color(0xFF6B7C4F)` → `colorScheme.primary`
   - `const Color(0xFF1E2939)` → `colorScheme.outlineVariant`

## ✅ Testing Checklist

After refactoring each file:

- [ ] File compiles without errors
- [ ] App runs in light mode - all colors visible
- [ ] App runs in dark mode - all colors visible
- [ ] Theme toggle works without restart
- [ ] Text is readable in both modes
- [ ] Borders/dividers are visible in both modes
- [ ] Icons have appropriate contrast
- [ ] No hardcoded `Color(0xFF...)` remaining (except special cases like yellow warning)

## 📊 Overall Progress: 10/22 files (45.5%)

Last Updated: Current session
