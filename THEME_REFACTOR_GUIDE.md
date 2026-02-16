# Theme Refactoring Guide - Batch Update

## File yang Sudah Direfactor ✅

1. edit_profil.dart
2. preferensi_aplikasi.dart ✅
3. gps_tracking_page.dart ✅ (Partial - perlu dilanjutkan)

## File yang Perlu Direfactor 🔧

### Dashboard & Tracking

- [ ] gps_tracking_active_page.dart
- [ ] detail_trip.dart
- [ ] riwayat_trip.dart
- [ ] pola_mingguan.dart
- [ ] statistik_mingguan.dart
- [ ] sistem_work.dart

### Motor Management

- [ ] list_motor.dart
- [ ] tambah_motor.dart
- [ ] edit_motor.dart

### Service

- [ ] tambah_riwayat_service.dart

### Profile & Settings

- [ ] bantuan_dukungan.dart
- [ ] kebijakan_privasi.dart
- [ ] panduan_pengguna.dart
- [ ] syarat_ketentuan.dart
- [ ] notifikasi_setting.dart
- [ ] privasi_dan_keamanan.dart
- [ ] tentang.dart

## Pattern Refactoring

### 1. Background Colors

```dart
// BEFORE
backgroundColor: const Color(0xFF0A0A0A),

// AFTER
final colorScheme = Theme.of(context).colorScheme;
backgroundColor: colorScheme.surfaceContainerLow,
```

### 2. Surface/Card Colors

```dart
// BEFORE
color: const Color(0xFF1A1A1A),

// AFTER
color: colorScheme.surface,
```

### 3. Text Colors

```dart
// Primary Text
// BEFORE: Color(0xFFFFFFFF)
// AFTER: colorScheme.onSurface

// Secondary Text
// BEFORE: Color(0xFF99A1AF)
// AFTER: colorScheme.onSurfaceVariant
```

### 4. Border Colors

```dart
// BEFORE
border: Border.all(color: const Color(0xFF1E2939), width: 0.65),

// AFTER
border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
```

### 5. Primary Color

```dart
// BEFORE
color: const Color(0xFF6B7C4F),

// AFTER
color: colorScheme.primary,
```

### 6. Status Bar

```dart
// BEFORE
value: SystemUiOverlayStyle.light.copyWith(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
),

// AFTER
final colorScheme = Theme.of(context).colorScheme;
value: SystemUiOverlayStyle.light.copyWith(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: colorScheme.brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light,
),
```

## Color Mapping Reference

| Old Hardcoded Color | Theme Property                                        | Usage                     |
| ------------------- | ----------------------------------------------------- | ------------------------- |
| `Color(0xFF0A0A0A)` | `colorScheme.surfaceContainerLow`                     | Background                |
| `Color(0xFF1A1A1A)` | `colorScheme.surface`                                 | Cards, containers         |
| `Color(0xFFFFFFFF)` | `colorScheme.onSurface`                               | Primary text              |
| `Color(0xFF99A1AF)` | `colorScheme.onSurfaceVariant`                        | Secondary text            |
| `Color(0xFF6A7282)` | `colorScheme.onSurfaceVariant.withValues(alpha: 0.7)` | Tertiary text             |
| `Color(0xFF6B7C4F)` | `colorScheme.primary`                                 | Primary color             |
| `Color(0xFF1E2939)` | `colorScheme.outlineVariant`                          | Borders                   |
| `Color(0xFF364153)` | `colorScheme.outline`                                 | Dividers                  |
| `Color(0xFFEFEFEF)` | `colorScheme.surfaceContainerHighest`                 | Input backgrounds (light) |
| `Color(0xFF252525)` | `colorScheme.surfaceContainerHighest`                 | Input backgrounds (dark)  |
| `Color(0xFF51A2FF)` | `colorScheme.tertiary`                                | Tertiary/accent           |
| `Color(0xFFFF6467)` | `colorScheme.error`                                   | Error states              |

## Quick Refactor Steps

1. **Add colorScheme variable at start of build/method:**

   ```dart
   final colorScheme = Theme.of(context).colorScheme;
   ```

2. **Replace hardcoded colors** with theme properties

3. **Update status bar** brightness to adapt to theme

4. **Remove const** from widgets using colorScheme (can't be const)

5. **Test** in both light and dark modes

## Automated Find & Replace (VSCode)

### Find All Background Colors

```regex
const Color\(0xFF0A0A0A\)
```

Replace with: `colorScheme.surfaceContainerLow`

### Find All Surface Colors

```regex
const Color\(0xFF1A1A1A\)
```

Replace with: `colorScheme.surface`

### Find All Primary Text

```regex
Color\(0xFFFFFFFF\)
```

Replace with: `colorScheme.onSurface`

**⚠️ Warning:** Always review auto-replacements as context matters!

## Testing Checklist

After refactoring each file:

- [ ] No compilation errors
- [ ] Test in Dark Mode
- [ ] Test in Light Mode
- [ ] Check all text is readable
- [ ] Verify borders/dividers are visible
- [ ] Test navigation between screens
- [ ] Check dialogs/modals adapt to theme

---

**Status:** 3/22 files refactored (13.6%)
**Next Priority:** Complete gps_tracking_page, then dashboard files
