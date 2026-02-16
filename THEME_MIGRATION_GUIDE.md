# Theme Migration Guide

Panduan untuk migrasi dari hardcoded colors ke theme-based colors.

## Mapping Warna ke Theme

### Background & Surface Colors

```dart
// LAMA → BARU
Color(0xFF0A0A0A) → Theme.of(context).scaffoldBackgroundColor
Color(0xFF1A1A1A) → colorScheme.surface
Color(0xFF252525) → colorScheme.surfaceContainerHighest
```

### Primary & Accent Colors

```dart
Color(0xFF6B7C4F) → colorScheme.primary
Color(0xFF51A2FF) → colorScheme.tertiary
```

### Text Colors

```dart
Colors.white → colorScheme.onSurface
Color(0xFF99A1AF) → colorScheme.secondary atau colorScheme.onSurfaceVariant
Color(0xFF6A7282) → colorScheme.onSurfaceVariant
Color(0xFFD1D5DC) → colorScheme.onSurface
Color(0xFF4A5565) → colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
```

### Border & Divider Colors

```dart
Color(0xFF364153) → colorScheme.outline
Color(0xFF1E2939) → colorScheme.outlineVariant
Color(0xFFD1D5DC) → Theme.of(context).dividerColor (light mode)
```

### Status Colors

```dart
Color(0xFFFF6467) → colorScheme.error
Color(0xFFFDC700) → colorScheme.warning (via extension)
Color(0xFFF0B100) → colorScheme.warningAlt (via extension)
```

## Langkah-langkah Refactoring

### 1. Tambahkan import (jika belum ada)

```dart
import 'package:flutter/material.dart';
```

### 2. Deklarasikan colorScheme di awal build method

```dart
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  // ... rest of code
}
```

### 3. Ganti hardcoded colors

Ikuti mapping di atas untuk mengganti setiap color.

### 4. Update SystemUiOverlayStyle

```dart
// LAMA
SystemUiOverlayStyle.light.copyWith(
  statusBarIconBrightness: Brightness.light,
)

// BARU
SystemUiOverlayStyle.light.copyWith(
  statusBarIconBrightness: colorScheme.brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light,
)
```

### 5. Remove const keywords

Jika widget menggunakan Theme.of(context), hilangkan `const` keyword.

## Custom Color Extensions

Untuk warna yang tidak ada di ColorScheme standar:

```dart
import 'package:app/core/utils/app_theme.dart';

// Gunakan extension
colorScheme.warning // untuk Color(0xFFFDC700)
colorScheme.warningAlt // untuk Color(0xFFF0B100)
colorScheme.cardBackground
colorScheme.inputFillColor
colorScheme.textSecondary
```

## Common Patterns

### Container dengan border

```dart
// LAMA
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF1A1A1A),
    border: Border.all(
      color: const Color(0xFF1E2939),
      width: 0.65,
    ),
  ),
)

// BARU
Container(
  decoration: BoxDecoration(
    color: colorScheme.surface,
    border: Border.all(
      color: colorScheme.outlineVariant,
      width: 0.65,
    ),
  ),
)
```

### TextField decoration

```dart
// LAMA
decoration: InputDecoration(
  fillColor: const Color(0xFF1A1A1A),
  border: OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color(0xFF364153),
      width: 0.65,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color(0xFF6B7C4F),
      width: 1,
    ),
  ),
)

// BARU
decoration: InputDecoration(
  fillColor: colorScheme.surface,
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: colorScheme.outline,
      width: 0.65,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: colorScheme.primary,
      width: 1,
    ),
  ),
)
```

### Button styles

```dart
// LAMA
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6B7C4F),
  ),
)

// BARU
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: colorScheme.primary,
  ),
)
```

## File Priority untuk Refactoring

1. ✅ Core widgets (bottom_navbar, page_transition)
2. ✅ Splash screen
3. ✅ Dashboard widgets (tambah_jarak)
4. ⏳ Dashboard main
5. ⏳ Service & Maintenance pages
6. ⏳ Auth pages
7. ⏳ Profile pages
8. ⏳ Onboarding pages
