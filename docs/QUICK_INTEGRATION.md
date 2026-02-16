# Quick Integration Guide - Service API

## ✅ Yang Sudah Dikerjakan

### 1. Model Classes

- ✅ `ServiceScheduleModel` di `lib/core/model/service_schedule_model.dart`
- ✅ `ServiceHistoryModel` di `lib/core/model/service_history_model.dart`

### 2. Service Classes

- ✅ `ServiceScheduleService` di `lib/core/services/service_schedule_service.dart`
- ✅ `ServiceHistoryService` di `lib/core/services/service_history_service.dart`

### 3. Dokumentasi

- ✅ Dokumentasi lengkap di `docs/FLUTTER_SERVICE_INTEGRATION.md`

### 4. Auto Header

- ✅ Support guest mode (device_id) dan authenticated mode (token)
- ✅ Otomatis mengirim header yang sesuai

## 🔧 Cara Menggunakan di Page yang Ada

### Contoh: Riwayat Service Page

#### 1. Import yang diperlukan

```dart
import '../../../core/services/service_history_service.dart';
import '../../../core/model/service_history_model.dart';
import 'package:intl/intl.dart';
```

#### 2. Inisialisasi Service

```dart
class _RiwayatServicePageState extends State<RiwayatServicePage> {
  final _historyService = ServiceHistoryService();
  List<ServiceHistoryModel> _histories = [];
  Map<String, dynamic>? _costSummary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
```

#### 3. Load Data dari API

```dart
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final histories = await _historyService.getAllHistories();
    final summary = await _historyService.getCostSummary();
    if (mounted) {
      setState(() {
        _histories = histories;
        _costSummary = summary;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
```

#### 4. Display Data

```dart
ListView.builder(
  itemCount: _histories.length,
  itemBuilder: (context, index) {
    final history = _histories[index];
    return ListTile(
      title: Text(history.serviceName),
      subtitle: Text(
        '${DateFormat('d MMMM yyyy').format(history.serviceDate)} • ${history.mileage} km'
      ),
      trailing: Text(_formatCurrency(history.cost)),
      onTap: () {
        // Navigate to detail/edit
      },
    );
  },
)
```

#### 5. Create New Record

```dart
Future<void> _createHistory() async {
  final newHistory = ServiceHistoryModel(
    vehicleId: primaryVehicle!.id!,
    serviceName: _serviceNameController.text,
    serviceDate: _selectedDate!,
    mileage: int.parse(_mileageController.text),
    cost: double.parse(_costController.text),
    workshopName: _workshopController.text,
    notes: _notesController.text,
  );

  try {
    await _historyService.createHistory(newHistory);
    Navigator.pop(context, true); // Return success
    _loadData(); // Reload list
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
    );
  }
}
```

#### 6. Update Record

```dart
Future<void> _updateHistory(int id) async {
  final updated = existingHistory.copyWith(
    cost: double.parse(_costController.text),
    notes: _notesController.text,
  );

  try {
    await _historyService.updateHistory(id, updated);
    Navigator.pop(context, true);
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal update: ${e.toString()}')),
    );
  }
}
```

#### 7. Delete Record

```dart
Future<void> _deleteHistory(int id) async {
  try {
    await _historyService.deleteHistory(id);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data berhasil dihapus')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
    );
  }
}
```

### Contoh: Jadwal Service Page

#### 1. Import

```dart
import '../../../core/services/service_schedule_service.dart';
import '../../../core/model/service_schedule_model.dart';
```

#### 2. Inisialisasi

```dart
class _JadwalPageState extends State<JadwalPage> {
  final _scheduleService = ServiceScheduleService();
  List<ServiceScheduleModel> _schedules = [];
  bool _isLoading = false;
```

#### 3. Load Schedules

```dart
Future<void> _loadSchedules() async {
  setState(() => _isLoading = true);
  try {
    final schedules = await _scheduleService.getAllSchedules();
    if (mounted) {
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    }
  } catch (e) {
    // Handle error
  }
}
```

#### 4. Display Status Badge

```dart
Widget _buildStatusBadge(String? status) {
  Color color;
  String text;

  switch (status) {
    case 'upcoming':
      color = Colors.blue;
      text = 'Akan Datang';
      break;
    case 'due':
      color = Colors.orange;
      text = 'Jatuh Tempo';
      break;
    case 'overdue':
      color = Colors.red;
      text = 'Terlambat';
      break;
    default:
      color = Colors.grey;
      text = 'Unknown';
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 12)),
  );
}
```

#### 5. Create Schedule

```dart
Future<void> _createSchedule() async {
  final newSchedule = ServiceScheduleModel(
    vehicleId: primaryVehicle!.id!,
    serviceName: _serviceNameController.text,
    intervalType: _isKmBased ? 'mileage' : 'time',
    intervalValue: int.parse(_intervalController.text),
    lastServiceMileage: _isKmBased ? int.parse(_lastMileageController.text) : null,
    lastServiceDate: !_isKmBased ? _lastServiceDate : null,
    reminderEnabled: _reminderEnabled,
    reminderThreshold: int.parse(_reminderThresholdController.text),
    notes: _notesController.text,
  );

  try {
    await _scheduleService.createSchedule(newSchedule);
    Navigator.pop(context, true);
    _loadSchedules();
  } catch (e) {
    // Handle error
  }
}
```

## 📝 Format Helper Functions

### Currency Formatter

```dart
String _formatCurrency(dynamic amount) {
  final value = amount is int ? amount : (amount as num).toInt();
  return 'Rp ${value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}
```

### Date Formatter

```dart
String _formatDate(DateTime date) {
  return DateFormat('d MMMM yyyy', 'id_ID').format(date);
}
```

### Odometer Formatter

```dart
String _formatOdometer(int km) {
  return '${km.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )} km';
}
```

## 🎯 Next Steps

1. **Generate model files**:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Update tambah_riwayat_service.dart**:
   - Tambahkan import service dan model
   - Ganti logic save dengan API call
   - Handle vehicle ID (get from primary vehicle)

3. **Update edit_riwayat_service.dart**:
   - Load data dari API berdasarkan ID
   - Update logic save dengan API call

4. **Update tambah_jadwal.dart**:
   - Tambahkan import service dan model
   - Implementasi create schedule

5. **Update jadwal.dart**:
   - Load schedules dari API
   - Display status yang sesuai

6. **Test semua flow**:
   - Create, Read, Update, Delete
   - Guest mode dan Auth mode
   - Error handling

## 🚀 Tips

- Selalu cek `mounted` sebelum `setState()` setelah async operation
- Gunakan loading indicator saat fetch data
- Handle error dengan user-friendly message
- Implement pull-to-refresh untuk better UX
- Cache data di local storage untuk offline support

## 📚 Dokumentasi Lengkap

Lihat `docs/FLUTTER_SERVICE_INTEGRATION.md` untuk:

- API endpoints detail
- Request/response examples
- Error handling guide
- Best practices
- Complete examples
