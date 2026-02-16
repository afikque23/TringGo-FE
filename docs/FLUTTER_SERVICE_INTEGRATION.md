# Integrasi Flutter — Service Schedule & Service History API

Panduan untuk menghubungkan aplikasi Flutter ke API Service Schedule dan Service History

pada Motorcycle Management. Support untuk guest mode (device_id) dan authenticated mode (token).

## Base URL

```
http://{host}:{port}/api/v1/motorcycle
```

Contoh lokal: `http://10.0.2.2:8000/api/v1/motorcycle`

## 1. Model yang Tersedia

### ServiceScheduleModel

Model untuk jadwal servis berkala:

- `id`: ID jadwal
- `vehicleId`: ID kendaraan
- `serviceTypeId`: ID tipe servis (opsional)
- `serviceName`: Nama servis (contoh: "Ganti Oli")
- `intervalType`: Tipe interval ("mileage" atau "time")
- `intervalValue`: Nilai interval (km atau hari)
- `lastServiceMileage`: Odometer servis terakhir
- `lastServiceDate`: Tanggal servis terakhir
- `nextServiceMileage`: Odometer servis berikutnya
- `nextServiceDate`: Tanggal servis berikutnya
- `reminderThreshold`: Threshold reminder (km atau hari sebelum)
- `reminderEnabled`: Status reminder aktif/nonaktif
- `notes`: Catatan
- `status`: Status jadwal ("upcoming", "due", "overdue")

### ServiceHistoryModel

Model untuk riwayat servis:

- `id`: ID riwayat
- `vehicleId`: ID kendaraan
- `serviceTypeId`: ID tipe servis (opsional)
- `serviceName`: Nama servis
- `serviceDate`: Tanggal servis dilakukan
- `mileage`: Odometer saat servis
- `cost`: Biaya servis
- `workshopName`: Nama bengkel
- `workshopLocation`: Lokasi bengkel
- `notes`: Catatan
- `receiptImage`: URL gambar struk (opsional)

## 2. Service Classes

### ServiceScheduleService

Singleton service untuk mengelola jadwal servis. Sudah include header otomatis (token/device_id).

```dart
final scheduleService = ServiceScheduleService();
```

### ServiceHistoryService

Singleton service untuk mengelola riwayat servis. Sudah include header otomatis (token/device_id).

```dart
final historyService = ServiceHistoryService();
```

## 3. Service Schedule API

### 3.1 Get All Schedules

Mengambil semua jadwal servis untuk kendaraan user/device.

```dart
try {
  final schedules = await scheduleService.getAllSchedules();
  print('Total schedules: ${schedules.length}');
  for (var schedule in schedules) {
    print('${schedule.serviceName} - Status: ${schedule.status}');
  }
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `GET /service-schedules`

**Response:**

```json
{
  "success": true,
  "message": "Service schedules retrieved successfully",
  "data": [
    {
      "id": 1,
      "vehicle_id": 1,
      "service_name": "Ganti Oli",
      "interval_type": "mileage",
      "interval_value": 2000,
      "last_service_mileage": 8000,
      "next_service_mileage": 10000,
      "status": "upcoming",
      ...
    }
  ]
}
```

### 3.2 Get Schedule by ID

```dart
try {
  final schedule = await scheduleService.getScheduleById(1);
  print('Schedule: ${schedule.serviceName}');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `GET /service-schedules/{id}`

### 3.3 Get Schedule Status by Vehicle

Mendapatkan status jadwal servis untuk kendaraan tertentu (upcoming, due, overdue).

```dart
try {
  final status = await scheduleService.getScheduleStatus(vehicleId);
  print('Due schedules: ${status['due_count']}');
  print('Overdue schedules: ${status['overdue_count']}');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `GET /service-schedules/status/{vehicle_id}`

### 3.4 Create Schedule

```dart
try {
  final newSchedule = ServiceScheduleModel(
    vehicleId: 1,
    serviceName: 'Ganti Oli',
    intervalType: 'mileage',
    intervalValue: 2000,
    lastServiceMileage: 8000,
    reminderThreshold: 200,
    reminderEnabled: true,
    notes: 'Gunakan oli full synthetic',
  );

  final created = await scheduleService.createSchedule(newSchedule);
  print('Schedule created with ID: ${created.id}');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `POST /service-schedules`

**Request Body:**

```json
{
  "vehicle_id": 1,
  "service_name": "Ganti Oli",
  "interval_type": "mileage",
  "interval_value": 2000,
  "last_service_mileage": 8000,
  "reminder_threshold": 200,
  "reminder_enabled": true,
  "notes": "Gunakan oli full synthetic"
}
```

### 3.5 Update Schedule

```dart
try {
  final updated = schedule.copyWith(
    reminderThreshold: 300,
    notes: 'Updated notes',
  );

  await scheduleService.updateSchedule(schedule.id!, updated);
  print('Schedule updated');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `PUT/PATCH /service-schedules/{id}`

### 3.6 Delete Schedule

```dart
try {
  await scheduleService.deleteSchedule(scheduleId);
  print('Schedule deleted');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `DELETE /service-schedules/{id}`

## 4. Service History API

### 4.1 Get All Histories

```dart
try {
  final histories = await historyService.getAllHistories();
  print('Total histories: ${histories.length}');
  for (var history in histories) {
    print('${history.serviceName} - Rp ${history.cost}');
  }
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `GET /service-histories`

### 4.2 Get History by ID

```dart
try {
  final history = await historyService.getHistoryById(1);
  print('Service: ${history.serviceName}');
  print('Cost: Rp ${history.cost}');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `GET /service-histories/{id}`

### 4.3 Get Cost Summary

Mendapatkan ringkasan biaya servis (total, rata-rata, dll).

```dart
try {
  final summary = await historyService.getCostSummary();
  print('Total cost: Rp ${summary['total_cost']}');
  print('Average cost: Rp ${summary['average_cost']}');
  print('Service count: ${summary['service_count']}');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `GET /service-histories/cost-summary`

**Response:**

```json
{
  "success": true,
  "data": {
    "total_cost": 1895000,
    "average_cost": 473750,
    "service_count": 4,
    "last_30_days_cost": 295000,
    "this_month_cost": 295000,
    "this_year_cost": 1895000
  }
}
```

### 4.4 Create History

```dart
try {
  final newHistory = ServiceHistoryModel(
    vehicleId: 1,
    serviceName: 'Ganti Oli',
    serviceDate: DateTime.now(),
    mileage: 8000,
    cost: 295000,
    workshopName: 'Kawasaki Authorized',
    notes: 'Full synthetic oil used',
  );

  final created = await historyService.createHistory(newHistory);
  print('History created with ID: ${created.id}');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `POST /service-histories`

**Request Body:**

```json
{
  "vehicle_id": 1,
  "service_name": "Ganti Oli",
  "service_date": "2026-02-14",
  "mileage": 8000,
  "cost": 295000,
  "workshop_name": "Kawasaki Authorized",
  "notes": "Full synthetic oil used"
}
```

### 4.5 Update History

```dart
try {
  final updated = history.copyWith(
    cost: 300000,
    notes: 'Updated notes',
  );

  await historyService.updateHistory(history.id!, updated);
  print('History updated');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `PUT/PATCH /service-histories/{id}`

### 4.6 Delete History

```dart
try {
  await historyService.deleteHistory(historyId);
  print('History deleted');
} catch (e) {
  print('Error: $e');
}
```

**API Endpoint:** `DELETE /service-histories/{id}`

## 5. Contoh Penggunaan di Widget

### Jadwal Servis Page

```dart
class JadwalPage extends StatefulWidget {
  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final _scheduleService = ServiceScheduleService();
  List<ServiceScheduleModel> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _scheduleService.getAllSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat jadwal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();

    return ListView.builder(
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        return ListTile(
          title: Text(schedule.serviceName),
          subtitle: Text('Status: ${schedule.status}'),
          trailing: Text('${schedule.nextServiceMileage} km'),
        );
      },
    );
  }
}
```

### Riwayat Servis Page

```dart
class RiwayatServicePage extends StatefulWidget {
  @override
  State<RiwayatServicePage> createState() => _RiwayatServicePageState();
}

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final histories = await _historyService.getAllHistories();
      final summary = await _historyService.getCostSummary();
      setState(() {
        _histories = histories;
        _costSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  String _formatCurrency(dynamic amount) {
    final value = amount is int ? amount : (amount as double).toInt();
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();

    return Column(
      children: [
        // Total Cost Card
        if (_costSummary != null)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total Biaya Servis'),
                  Text(
                    _formatCurrency(_costSummary!['total_cost']),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('dari ${_costSummary!['service_count']} servis'),
                ],
              ),
            ),
          ),

        // History List
        Expanded(
          child: ListView.builder(
            itemCount: _histories.length,
            itemBuilder: (context, index) {
              final history = _histories[index];
              return ListTile(
                title: Text(history.serviceName),
                subtitle: Text('${history.workshopName} • ${history.mileage} km'),
                trailing: Text(_formatCurrency(history.cost)),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 6. Error Handling

Semua method sudah include try-catch dan akan throw exception jika terjadi error. Best practice:

```dart
try {
  await scheduleService.createSchedule(newSchedule);
} catch (e) {
  if (e.toString().contains('401')) {
    // Unauthorized - mungkin perlu login ulang
  } else if (e.toString().contains('404')) {
    // Resource not found
  } else {
    // Generic error
  }
  print('Error: $e');
}
```

## 7. Tips & Best Practices

1. **Auto-refresh setelah create/update/delete:**

   ```dart
   await scheduleService.createSchedule(newSchedule);
   await _loadSchedules(); // Refresh list
   ```

2. **Loading state:** Selalu tampilkan loading indicator saat fetch data
3. **Error messages:** Tampilkan error message yang user-friendly
4. **Optimistic updates:** Update UI dulu, lalu sync ke server
5. **Pull-to-refresh:** Implement pull to refresh untuk list
6. **Cache data:** Simpan data di local storage untuk offline access

## 8. Integrasi dengan Vehicle

Service schedule dan history otomatis terhubung dengan vehicle yang aktif. Pastikan:

1. `vehicleId` selalu diisi dengan ID kendaraan yang sedang aktif
2. Gunakan `VehicleService().getPrimaryVehicle()` untuk mendapatkan kendaraan aktif
3. Saat ganti kendaraan aktif, reload data schedule dan history

```dart
final primaryVehicle = await VehicleService().getPrimaryVehicle();
if (primaryVehicle != null) {
  final schedules = await scheduleService.getAllSchedules();
  // Filter by vehicle_id if needed
  final vehicleSchedules = schedules
      .where((s) => s.vehicleId == primaryVehicle.id)
      .toList();
}
```

---

**Support:** Guest mode (device_id) dan Authenticated mode (token) sudah otomatis dihandle oleh service class. Tidak perlu konfigurasi tambahan.
