# Tips Perawatan API Integration Guide

## 📋 Overview

API service untuk fitur Tips Perawatan Motor sudah terintegrasi dengan backend. Dokumentasi ini menjelaskan cara menggunakan API service di Flutter.

## 📁 File Structure

```
lib/
├── core/
│   ├── model/
│   │   └── tip_model.dart          # Model classes untuk Tips
│   ├── services/
│   │   └── tips_service.dart       # API service untuk Tips
│   └── network/
│       ├── api_client.dart         # HTTP client (shared)
│       └── api_config.dart         # API endpoints config
└── features/
    └── tips_perawatan/
        ├── tips_perawatan.dart     # List Tips page
        ├── detail_tips_perawatan.dart  # Detail Tips page
        └── profil/
            └── tambah_tips.dart    # Create/Edit Tips page
```

## 🔧 Setup

### 1. Generate Model Files

Model menggunakan `json_serializable`. Sebelum run, generate file `.g.dart`:

```bash
# Generate semua .g.dart files
flutter pub run build_runner build --delete-conflicting-outputs

# Atau watch mode (auto-generate saat file berubah)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 2. Update Base URL

Edit `lib/core/network/api_config.dart`:

```dart
// Untuk Emulator Android
static const String baseUrl = 'http://10.0.2.2:8000/api/v1/motorcycle';

// Untuk Physical Device (ganti dengan IP Anda)
static const String baseUrl = 'http://192.168.1.100:8000/api/v1/motorcycle';

// Untuk Ngrok (recommended untuk testing)
static const String baseUrl = 'https://your-ngrok-url.ngrok-free.dev/api/v1/motorcycle';
```

## 🚀 Usage

### Status Integrasi UI

- Halaman list tips `tips_perawatan.dart` sudah menggunakan API `getAllTips()`.
- Search bar mendukung keyword + hashtag (contoh: `ganti oli #daily rider`).
- Filter merek dan tingkat kesulitan langsung dipetakan ke query parameter backend.
- Form create tips saat ini mengirim fallback `difficulty: Mudah` untuk kompatibilitas backend lama yang masih mewajibkan difficulty.

### Import Service

```dart
import 'package:motorcycle_management/core/services/tips_service.dart';
import 'package:motorcycle_management/core/model/tip_model.dart';
```

### 1. Get All Tips (Public - No Auth)

```dart
final tipsService = TipsService();

try {
  // Basic get all tips
  final response = await tipsService.getAllTips();

  List<TipModel> tips = response.data.tips;
  PaginationData pagination = response.data.pagination;

  print('Total tips: ${pagination.totalItems}');
  print('Current page: ${pagination.currentPage}');

  // With filters
  final filtered = await tipsService.getAllTips(
    page: 1,
    limit: 10,
    search: 'ganti oli',
    brand: 'Honda',
    difficulty: 'Mudah',
    hashtags: 'oli mesin,daily rider',
    sortBy: 'popular',
  );

} catch (e) {
  print('Error: $e');
}
```

### 2. Get Tip Detail

```dart
try {
  final response = await tipsService.getTipById(1);
  TipModel tip = response.data;

  print('Title: ${tip.title}');
  print('Author: ${tip.author.name}');
  print('Steps: ${tip.steps?.length}');
  print('Tools: ${tip.tools?.length}');

} catch (e) {
  print('Error: $e');
}
```

### 3. Create New Tip (Authenticated)

```dart
try {
  final request = CreateTipRequest(
    title: 'Cara Efisien Ganti Oli',
    description: 'Metode ganti oli yang efisien untuk motor matic',
    vehicle: TipVehicle(
      brand: 'Honda',
      model: 'PCX 160',
      year: 2023,
      ridingStyle: 'Harian / Commuter',
    ),
    estimatedTime: '30 menit',
    tools: [
      TipTool(name: 'Kunci Ring 17', isOptional: false),
      TipTool(name: 'Wadah Oli Bekas', isOptional: false),
      TipTool(name: 'Filter Oli', isOptional: true),
    ],
    steps: [
      TipStep(
        title: 'Persiapan',
        description: 'Siapkan semua alat yang diperlukan',
      ),
      TipStep(
        title: 'Posisikan Motor',
        description: 'Parkirkan motor di tempat yang rata',
      ),
      TipStep(
        title: 'Kuras Oli Lama',
        description: 'Lepaskan baut pembuangan oli',
      ),
    ],
    maintenanceInterval: TipMaintenanceInterval(
      distanceKm: 2000,
      timeMonths: 3,
    ),
    importantNotes: 'Pastikan oli sesuai spesifikasi pabrikan',
    hashtags: ['Oli Mesin', 'Perawatan Rutin'],
    isCopyable: true,
  );

  final response = await tipsService.createTip(request);
  print('Tip created with ID: ${response.data.id}');

} catch (e) {
  print('Error: $e');
}
```

Catatan kompatibilitas:

- Jika backend Anda masih mewajibkan `difficulty`, gunakan fallback nilai default di layer UI/service.
- Rekomendasi perubahan backend agar `difficulty` optional ada di `BACKEND_CHANGE_DIFFICULTY_OPTIONAL.md`.

### 4. Update Tip (Authenticated - Owner Only)

```dart
try {
  final request = CreateTipRequest(
    // ... same as create
  );

  final response = await tipsService.updateTip(tipId, request);
  print('Tip updated successfully');

} catch (e) {
  if (e.toString().contains('permission')) {
    print('You do not own this tip');
  }
}
```

### 5. Delete Tip (Authenticated - Owner Only)

```dart
try {
  await tipsService.deleteTip(tipId);
  print('Tip deleted successfully');

} catch (e) {
  print('Error deleting tip: $e');
}
```

### 6. Like/Unlike Tip (Guest Mode Support)

```dart
try {
  // Toggle like (works for both authenticated and guest users)
  final result = await tipsService.toggleLike(tipId, true); // true = like

  print('Is liked: ${result['is_liked']}');
  print('Likes count: ${result['likes_count']}');

  // Unlike
  await tipsService.toggleLike(tipId, false); // false = unlike

} catch (e) {
  print('Error: $e');
}
```

### 7. Bookmark/Unbookmark Tip (Guest Mode Support)

```dart
try {
  // Toggle bookmark
  final result = await tipsService.toggleBookmark(tipId, true);

  print('Is bookmarked: ${result['is_bookmarked']}');
  print('Bookmarks count: ${result['bookmarks_count']}');

} catch (e) {
  print('Error: $e');
}
```

### 8. Share Tip (Guest Mode Support)

```dart
try {
  // Track share (for analytics)
  final result = await tipsService.shareTip(
    tipId,
    'whatsapp', // Platform: whatsapp, telegram, facebook, twitter, copy_link
  );

  print('Shares count: ${result['shares_count']}');

  // Then implement actual sharing using share_plus package
  // await Share.share('Check this tip: $tipUrl');

} catch (e) {
  print('Error: $e');
}
```

### 9. Use Tip as Template (Authenticated)

```dart
try {
  final request = TipUseTemplateRequest(
    vehicleId: 1,
    scheduleType: 'interval',
    intervalType: 'distance',
    intervalValue: 2000,
    startDate: '2026-03-15',
    notes: 'Ganti oli rutin sesuai rekomendasi',
  );

  final result = await tipsService.useAsTemplate(tipId, request);

  print('Schedule created with ID: ${result['schedule_id']}');
  print('Next maintenance: ${result['next_maintenance_date']}');

} catch (e) {
  print('Error: $e');
}
```

## 🎨 UI Integration Examples

### Example: Tips List with StatefulWidget

```dart
class TipsPerawatanPage extends StatefulWidget {
  @override
  _TipsPerawatanPageState createState() => _TipsPerawatanPageState();
}

class _TipsPerawatanPageState extends State<TipsPerawatanPage> {
  final _tipsService = TipsService();
  List<TipModel> _tips = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _tipsService.getAllTips(
        page: _currentPage,
        limit: 10,
      );

      setState(() {
        _tips.addAll(response.data.tips);
        _hasMore = response.data.pagination.hasNext;
        _currentPage++;
        _isLoading = false;
        _error = null;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _tips.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tips.length) {
            _loadTips(); // Load more
            return Center(child: CircularProgressIndicator());
          }

          final tip = _tips[index];
          return TipCard(tip: tip);
        },
      ),
    );
  }
}
```

### Example: Like Button Widget

```dart
class LikeButton extends StatefulWidget {
  final int tipId;
  final bool initialIsLiked;
  final int initialLikesCount;

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final _tipsService = TipsService();
  late bool _isLiked;
  late int _likesCount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
    _likesCount = widget.initialLikesCount;
  }

  Future<void> _toggleLike() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _tipsService.toggleLike(
        widget.tipId,
        !_isLiked,
      );

      setState(() {
        _isLiked = result['is_liked'];
        _likesCount = result['likes_count'];
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Row(
        children: [
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.grey,
          ),
          SizedBox(width: 4),
          Text('$_likesCount'),
          if (_isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
```

## ⚠️ Error Handling

```dart
try {
  final response = await tipsService.getAllTips();
  // Handle success

} on Exception catch (e) {
  if (e.toString().contains('401')) {
    // Unauthorized - redirect to login
    Navigator.pushNamed(context, '/login');
  } else if (e.toString().contains('403')) {
    // Forbidden - show permission error
    showDialog(/* ... */);
  } else if (e.toString().contains('404')) {
    // Not found
    showDialog(/* ... */);
  } else {
    // General error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## 🔐 Guest Mode vs Authenticated

### Guest Mode (Device ID)

- ✅ View tips list
- ✅ View tip detail
- ✅ Like/unlike tips
- ✅ Bookmark tips
- ✅ Share tips
- ❌ Create tips
- ❌ Update tips
- ❌ Delete tips
- ❌ Use as template

### Authenticated Mode

- ✅ All guest features
- ✅ Create tips
- ✅ Update own tips
- ✅ Delete own tips
- ✅ Use tips as template
- ✅ View own tips (all statuses)

## 📝 Notes

1. **Model Generation**: Jangan lupa run `build_runner` setiap kali mengubah model
2. **Device ID**: Otomatis di-generate dan di-cache untuk guest users
3. **Pagination**: Gunakan `hasNext` dan `hasPrev` untuk load more
4. **Filtering**: Semua filter bisa dikombinasikan
5. **Sorting**: Options: `latest`, `popular`, `rating`, `relevance`
6. **Status Tips**: `pending_review`, `published`, `rejected`

## 🐛 Debugging

Enable debug print di service:

```dart
// Service sudah include debug print
// Check terminal/console untuk logs:
// 🔍 FETCHING TIPS FROM API
// 📍 URL: http://...
// 📥 Response status: 200
// ✅ Tips loaded successfully
```

## 📚 Additional Resources

- [API Documentation](API_TIPS_PERAWATAN.md)
- [Backend Hashtag Search Contract](BACKEND_TIPS_HASHTAG_SEARCH.md)
- [Backend Difficulty Optional Change](BACKEND_CHANGE_DIFFICULTY_OPTIONAL.md)
- [Flutter Hashtag Search Guide](FLUTTER_TIPS_HASHTAG_SEARCH.md)
- [Backend Implementation](../../backend/TIPS_API_IMPLEMENTATION.md)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [device_info_plus](https://pub.dev/packages/device_info_plus)
