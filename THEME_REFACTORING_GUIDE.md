# Theme Refactoring Progress & Guide

## ✅ **COMPLETED FILES (15/22 - 68%)**

### Core System (3 files)

- ✓ `lib/core/utils/theme_manager.dart` - Theme management with ChangeNotifier
- ✓ `lib/main.dart` - ThemeMode integration
- ✓ `lib/features/splash_screen.dart` - Adaptive splash screen

### Feature Pages (12 files)

1. ✓ `lib/features/dashboard/preferensi_aplikasi.dart` - All colors theme-aware
2. ✓ `lib/features/profil/edit_profil.dart` - Profile editing with image picker
3. ✓ `lib/features/dashboard/gps_tracking_page.dart` - GPS tracking UI
4. ✓ `lib/features/dashboard/gps_tracking_active_page.dart` - Active tracking screen
5. ✓ `lib/features/dashboard/widgets/trip/detail_trip.dart` - Trip details with map
6. ✓ `lib/features/dashboard/widgets/trip/riwayat_trip.dart` - Trip history list
7. ✓ `lib/features/dashboard/widgets/tambah_motor/tambah_motor.dart` - Add vehicle form
8. ✓ `lib/features/dashboard/widgets/tambah_motor/list_motor.dart` - Vehicle list with cards, dialogs
9. ✓ `lib/features/dashboard/widgets/tambah_motor/edit_motor.dart` - Edit vehicle form
10. ✓ `lib/features/dashboard/widgets/tren_mingguan/pola_mingguan.dart` - Weekly patterns with charts
11. ✓ `lib/features/dashboard/widgets/tren_mingguan/statistik_mingguan.dart` - Weekly statistics
12. ✓ `lib/features/dashboard/widgets/sistem_work.dart` - System documentation

---

## 🚧 **IN PROGRESS (7 Settings/Profile Pages)**

### Headers DONE ✓ - Sections/Cards Need Update

All 7 files have been updated with:

- ✓ Adaptive `SystemUiOverlayStyle` (dark/light status bar)
- ✓ `final colorScheme = Theme.of(context).colorScheme` in build method
- ✓ `Scaffold backgroundColor: colorScheme.surfaceContainerLow`
- ✓ Header text colors updated

**Files:**

1. `lib/features/profil/bantuan_dukungan/bantuan_dukungan.dart`
2. `lib/features/profil/notifikasi/notifikasi_setting.dart`
3. `lib/features/profil/privasi_keamanan/privasi_dan_keamanan.dart`
4. `lib/features/profil/bantuan_dukungan/kebijakan_privasi.dart`
5. `lib/features/profil/bantuan_dukungan/syarat_ketentuan.dart`
6. `lib/features/profil/bantuan_dukungan/panduan_pengguna.dart`
7. `lib/features/profil/tentang/tentang.dart`

**Remaining Work:**
For each `_buildXxxSection()` method:

1. Add `BuildContext context` parameter (or use `this.context` if StatefulWidget)
2. Add `final colorScheme = Theme.of(context).colorScheme;` at top of method
3. Replace all hardcoded colors using the mapping below

---

## 🚧 **IN PROGRESS (1 Service Page)**

### `lib/features/servis/history/tambah_riwayat_service.dart`

**Status:**

- ✓ Header updated
- ✓ Build method has adaptive SystemUiOverlayStyle
- ⏳ Form fields need color updates
- ⏳ Date picker theme needs updating (line ~46-58)

**Remaining Work:**

1. Update `_buildDateField()`, `_buildServiceTypeDropdown()`, etc. with colorScheme
2. Update date picker theme in `_selectDate()`:

```dart
builder: (context, child) {
  return Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: colorScheme.primary,
        onPrimary: colorScheme.onPrimary,
        surface: colorScheme.surface,
        onSurface: colorScheme.onSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
      ),
    ),
    child: child!,
  );
}
```

---

## 📋 **COLOR MAPPING REFERENCE**

### Established Pattern

```dart
// In build() or any Widget method:
final colorScheme = Theme.of(context).colorScheme;
final isDark = colorScheme.brightness == Brightness.dark;
```

### Direct Color Mappings

| Hardcoded Color             | ColorScheme Property              | Usage                                  |
| --------------------------- | --------------------------------- | -------------------------------------- |
| `Color(0xFF0A0A0A)`         | `colorScheme.surfaceContainerLow` | Scaffold backgrounds                   |
| `Color(0xFF1A1A1A)`         | `colorScheme.surface`             | Cards, containers                      |
| `Color(0xFFFFFFFF)`         | `colorScheme.onSurface`           | Primary text, headings                 |
| `Color(0xFF99A1AF)`         | `colorScheme.onSurfaceVariant`    | Secondary text, hints, placeholders    |
| `Color(0xFF6B7C4F)`         | `colorScheme.primary`             | Accent color, buttons, primary actions |
| `Color(0xFF1E2939)`         | `colorScheme.outlineVariant`      | Borders, dividers                      |
| `Colors.white` (on primary) | `colorScheme.onPrimary`           | Text on primary colored backgrounds    |
| `Colors.red` (errors)       | `colorScheme.error`               | Delete buttons, error states           |

### Opacity Adjustments

```dart
// Background with opacity:
color: colorScheme.primary.withOpacity(0.1)  // Light accent background

// Text with opacity:
color: colorScheme.onSurface.withOpacity(0.5)  // Disabled text
```

---

## 🔧 **HELPER METHOD PATTERN**

### Before:

```dart
Widget _buildCard() {
  return Container(
    color: const Color(0xFF1A1A1A),
    child: Text(
      'Title',
      style: TextStyle(color: Color(0xFFFFFFFF)),
    ),
  );
}
```

### After (Option 1 - Pass Context):

```dart
Widget _buildCard(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    color: colorScheme.surface,
    child: Text(
      'Title',
      style: TextStyle(color: colorScheme.onSurface),
    ),
  );
}

// Usage:
_buildCard(context)
```

### After (Option 2 - Use this.context in StatefulWidget):

```dart
Widget _buildCard() {
  final colorScheme = Theme.of(context).colorScheme;  // Uses this.context
  return Container(
    color: colorScheme.surface,
    child: Text(
      'Title',
      style: TextStyle(color: colorScheme.onSurface),
    ),
  );
}

// Usage (no changes needed):
_buildCard()
```

---

## 📐 **COMMON PATTERNS**

### 1. Container with Border

```dart
// Before:
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF1A1A1A),
    border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
    borderRadius: BorderRadius.circular(16),
  ),
)

// After:
Container(
  decoration: BoxDecoration(
    color: colorScheme.surface,
    border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
    borderRadius: BorderRadius.circular(16),
  ),
)
```

### 2. Icon with Accent Color

```dart
// Before:
Icon(Icons.check, color: Color(0xFF6B7C4F))

// After:
Icon(Icons.check, color: colorScheme.primary)
```

### 3. Primary Button

```dart
// Before:
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF6B7C4F),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Icon(Icons.save, color: Color(0xFFFFFFFF)),
)

// After:
Container(
  decoration: BoxDecoration(
    color: colorScheme.primary,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Icon(Icons.save, color: colorScheme.onPrimary),
)
```

### 4. Switch/Toggle

```dart
// Before:
Switch(
  activeColor: const Color(0xFFFFFFFF),
  activeTrackColor: const Color(0xFF6B7C4F),
  inactiveThumbColor: const Color(0xFFFFFFFF),
  inactiveTrackColor: const Color(0xFF364153),
)

// After:
Switch(
  activeColor: colorScheme.onPrimary,
  activeTrackColor: colorScheme.primary,
  inactiveThumbColor: colorScheme.onSurface,
  inactiveTrackColor: colorScheme.outlineVariant,
)
```

### 5. Dialog/AlertDialog

```dart
// Before:
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text('Title', style: TextStyle(color: Color(0xFFFFFFFF))),
      content: Text('Message', style: TextStyle(color: Color(0xFF99A1AF))),
    );
  },
);

// After:
showDialog(
  context: context,
  builder: (dialogContext) {  // Use different name to avoid confusion
    final colorScheme = Theme.of(dialogContext).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text('Title', style: TextStyle(color: colorScheme.onSurface)),
      content: Text('Message', style: TextStyle(color: colorScheme.onSurfaceVariant)),
    );
  },
);
```

---

## ⚡ **QUICK SEARCH & REPLACE GUIDE**

Use these grep searches to find remaining hardcoded colors:

```bash
# Find all surface container colors (dark backgrounds):
grep -r "Color(0xFF0A0A0A)" lib/features/profil/

# Find all surface colors (cards):
grep -r "Color(0xFF1A1A1A)" lib/features/profil/

# Find all primary text:
grep -r "Color(0xFFFFFFFF)" lib/features/profil/

# Find all secondary text:
grep -r "Color(0xFF99A1AF)" lib/features/profil/

# Find all primary/accent colors:
grep -r "Color(0xFF6B7C4F)" lib/features/profil/

# Find all borders:
grep -r "Color(0xFF1E2939)" lib/features/profil/
```

---

## ✅ **TESTING CHECKLIST**

After refactoring each file:

1. **Build Check**: Ensure no compilation errors

   ```bash
   flutter analyze
   ```

2. **Visual Test (Dark Mode)**:
   - Navigate to the page
   - Verify all text is readable
   - Check all borders are visible
   - Confirm buttons/actions stand out

3. **Visual Test (Light Mode)**:
   - Switch theme in Preferensi Aplikasi
   - Navigate to same page
   - Verify text contrast is good
   - Check all colors adapt correctly

4. **Interaction Test**:
   - Test all buttons/taps
   - Verify dialogs show correct colors
   - Check form inputs are usable
   - Test toggles/switches work

---

## 🎯 **PRIORITY ORDER**

To complete refactoring efficiently:

1. **HIGH**: `notifikasi_setting.dart` - Has many interactive toggles
2. **HIGH**: `privasi_dan_keamanan.dart` - Has toggles and dialogs
3. **MEDIUM**: `tambah_riwayat_service.dart` - Has forms and date picker
4. **MEDIUM**: `bantuan_dukungan.dart` - Has FAQ expansion and contact cards
5. **LOW**: `tentang.dart` - Mostly text-based info
6. **LOW**: `kebijakan_privasi.dart` - Text-based policy
7. **LOW**: `syarat_ketentuan.dart` - Text-based terms
8. **LOW**: `panduan_pengguna.dart` - Text-based guide

---

## 📊 **PROGRESS SUMMARY**

- **Completed**: 15/22 files (68%)
- **In Progress**: 8/22 files (36% - headers done, sections pending)
- **Core Files**: 3/3 ✅ (100%)
- **Feature Pages**: 12/12 ✅ (100%)
- **Settings Pages**: 0/7 (0% sections, 100% headers)
- **Service Pages**: 0/1 (Header only)

**Estimated Remaining Work**:

- ~2-3 hours for interactive pages (notifikasi, privasi, bantuan, service)
- ~1 hour for text-based pages (tentang, kebijakan, syarat, panduan)
- Total: ~3-4 hours

---

## 🔍 **VALIDATION**

Run this command to check for any remaining hardcoded colors in profile/settings:

```bash
# Check for any missed hardcoded colors:
grep -r "Color(0x" lib/features/profil/ lib/features/servis/ | grep -v "// " | wc -l

# Should return a number - that's how many replacements remain
```

---

**Last Updated**: January 30, 2026
**Refactoring Pattern Version**: 1.0
**Theme System**: Material 3 with ColorScheme
