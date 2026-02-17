# Trip Service - Panduan Penggunaan

Dokumentasi cara menggunakan `TripService` dan `TrackingService` untuk menyimpan trip dan update odometer ke backend.

## Overview

Sistem tracking trip sudah terintegrasi dengan backend. Ketika user selesai melakukan trip:

1. ✅ Trip otomatis disimpan ke backend
2. ✅ Odometer kendaraan otomatis diupdate
3. ✅ Data juga disimpan di local storage sebagai backup
4. ✅ Mendukung offline mode (sync manual)

---

## 1. Automatic Trip Saving (Sudah Terintegrasi)

Trip akan **otomatis disimpan** ke backend saat user menyelesaikan tracking.

### Di TrackingService:

```dart
// Ketika user menekan tombol "Stop Tracking"
final completedTrip = await trackingService.stopTracking();

// Di dalam stopTracking(), otomatis akan:
// 1. Save trip ke backend via TripService.createTrip()
// 2. Update odometer kendaraan
// 3. Save ke local storage sebagai backup
```

**Tidak perlu kode tambahan!** Semuanya sudah otomatis.

---

## 2. Manual Trip Sync (Untuk Offline Trips)

Jika user melakukan trip saat offline, trip hanya tersimpan di local storage.
User bisa sync manual ke backend:

```dart
import 'package:motorcycle_management/core/services/tracking_service.dart';

final trackingService = TrackingService();

// Sync semua local trips ke backend
final syncedCount = await trackingService.syncLocalTripsToBackend();

print('Berhasil sync $syncedCount trip ke backend');
```

### Contoh di UI:

```dart
// Di halaman riwayat trip, tambahkan tombol sync
ElevatedButton(
  onPressed: () async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Syncing...'),
        content: CircularProgressIndicator(),
      ),
    );

    final syncedCount = await TrackingService().syncLocalTripsToBackend();

    Navigator.pop(context); // Close loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ $syncedCount trip berhasil di-sync')),
    );
  },
  child: Row(
    children: [
      Icon(Icons.cloud_upload),
      SizedBox(width: 8),
      Text('Sync to Server'),
    ],
  ),
)
```

---

## 3. Get Trips from Backend

Untuk menampilkan trip dari server (bukan hanya dari local storage):

```dart
import 'package:motorcycle_management/core/services/tracking_service.dart';

final trackingService = TrackingService();

// Get trips dari backend
final trips = await trackingService.getTripsFromBackend(
  limit: 50,              // Optional: jumlah maksimal trip
  vehicleId: '1',         // Optional: filter by vehicle
);

// Display trips
for (var trip in trips) {
  print('Trip: ${trip.totalDistance.toStringAsFixed(2)} km');
  print('Duration: ${trip.formattedDuration}');
  print('Avg Speed: ${trip.averageSpeed.toStringAsFixed(1)} km/h');
}
```

### Contoh UI - Trip List dari Backend:

```dart
class TripHistoryPage extends StatefulWidget {
  @override
  _TripHistoryPageState createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);

    // Try to load from backend first
    var trips = await TrackingService().getTripsFromBackend(limit: 100);

    // Fallback to local if backend fails
    if (trips.isEmpty) {
      trips = await TrackingService().getTripHistory();
    }

    setState(() {
      _trips = trips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return ListTile(
          leading: Icon(Icons.route),
          title: Text('${trip.totalDistance.toStringAsFixed(2)} km'),
          subtitle: Text('${trip.formattedDuration} • ${trip.motorcycleName}'),
          trailing: Text('${trip.averageSpeed.toStringAsFixed(1)} km/h'),
        );
      },
    );
  }
}
```

---

## 4. Manual Odometer Update

Jika perlu update odometer secara manual (tidak dari trip):

```dart
import 'package:motorcycle_management/core/services/trip_service.dart';

final tripService = TripService();

// Update odometer kendaraan
final success = await tripService.updateVehicleOdometer(
  vehicleId: 1,
  newOdometer: 8500.5,  // dalam km
  notes: 'Manual update by user',
);

if (success) {
  print('✅ Odometer updated successfully');
} else {
  print('❌ Failed to update odometer');
}
```

---

## 5. Delete Trip

Delete trip dari backend:

```dart
import 'package:motorcycle_management/core/services/trip_service.dart';

final tripService = TripService();

final success = await tripService.deleteTrip('trip-id-123');

if (success) {
  print('✅ Trip deleted');
} else {
  print('❌ Failed to delete trip');
}
```

---

## 6. Flow Lengkap - Mulai s/d Selesai Trip

```dart
import 'package:motorcycle_management/core/services/tracking_service.dart';

final trackingService = TrackingService();

// ============ START TRIP ============
void startTrip() async {
  // Check GPS ready
  final gpsReady = await trackingService.checkGpsReady();
  if (!gpsReady) {
    // Show dialog to enable GPS
    await trackingService.openLocationSettings();
    return;
  }

  // Start tracking
  final started = await trackingService.startTracking(
    motorcycleName: 'Ninja 250',
  );

  if (started) {
    print('✅ Trip started!');

    // Listen to trip updates
    trackingService.tripStream.listen((trip) {
      print('Distance: ${trip.totalDistance.toStringAsFixed(2)} km');
      print('Duration: ${trip.formattedDuration}');
      print('Speed: ${trip.averageSpeed.toStringAsFixed(1)} km/h');
    });
  } else {
    print('❌ Failed to start tracking');
  }
}

// ============ STOP TRIP ============
void stopTrip() async {
  final completedTrip = await trackingService.stopTracking();

  if (completedTrip != null) {
    print('✅ Trip completed!');
    print('Total Distance: ${completedTrip.totalDistance.toStringAsFixed(2)} km');
    print('Duration: ${completedTrip.formattedDuration}');
    print('Avg Speed: ${completedTrip.averageSpeed.toStringAsFixed(1)} km/h');
    print('Max Speed: ${completedTrip.maxSpeed.toStringAsFixed(1)} km/h');
    print('Points: ${completedTrip.points.length}');

    // Trip sudah otomatis:
    // ✅ Disimpan ke backend
    // ✅ Odometer sudah diupdate
    // ✅ Disimpan ke local storage

    // Navigate to trip summary page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripSummaryPage(trip: completedTrip),
      ),
    );
  }
}

// ============ CANCEL TRIP ============
void cancelTrip() {
  trackingService.cancelTracking();
  print('Trip cancelled (not saved)');
}
```

---

## 7. Monitoring Trip Status

```dart
import 'package:motorcycle_management/core/services/tracking_service.dart';

final trackingService = TrackingService();

// Check if currently tracking
if (trackingService.isTracking) {
  print('Currently tracking...');

  // Get current trip
  final currentTrip = trackingService.currentTrip;
  print('Distance: ${currentTrip?.totalDistance ?? 0} km');
}
```

---

## 8. Error Handling

```dart
try {
  final completed = await trackingService.stopTracking();

  if (completed != null) {
    // Success - trip saved
    print('✅ Trip saved successfully');
  } else {
    // No active trip to stop
    print('⚠️ No active trip');
  }
} catch (e) {
  // Handle error
  print('❌ Error: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to save trip: $e')),
  );
}
```

---

## 9. Offline Mode

Sistem sudah mendukung offline mode:

- ✅ Trip disimpan di local storage jika backend tidak tersedia
- ✅ User bisa sync manual saat kembali online
- ✅ Log di console menunjukkan status sync: `✅ Synced` atau `❌ Local only`

```dart
// Cek status sync trip terakhir di console log:
// ✅ Trip saved locally! Total trips: 10
//    Distance: 25.50 km
//    Duration: 01:15:00
//    Points: 450
//    Backend: ✅ Synced  <-- Ini menunjukkan berhasil sync
```

---

## 10. Best Practices

### ✅ DO:

- Gunakan `stopTracking()` untuk save trip (otomatis sync ke backend)
- Implementasi sync button untuk user yang sering offline
- Handle GPS permission dengan baik
- Show loading indicator saat sync

### ❌ DON'T:

- Jangan manual save trip dengan `TripService.createTrip()` (kecuali kasus khusus)
- Jangan lupa handle offline scenario
- Jangan skip error handling

---

## 11. Testing

### Test Create Trip:

```dart
void testCreateTrip() async {
  final trip = TripModel(
    id: DateTime.now().toString(),
    motorcycleName: 'Test Bike',
    startTime: DateTime.now().subtract(Duration(hours: 1)),
    endTime: DateTime.now(),
    totalDistance: 25.5,
    duration: 3600,
    averageSpeed: 45.0,
    maxSpeed: 80.0,
    points: [], // Add test points
    status: 'completed',
  );

  final saved = await TripService().createTrip(trip);
  print(saved != null ? '✅ Test passed' : '❌ Test failed');
}
```

### Test Odometer Update:

```dart
void testOdometerUpdate() async {
  final success = await TripService().updateVehicleOdometer(
    vehicleId: 1,
    newOdometer: 8500.0,
    notes: 'Test update',
  );
  print(success ? '✅ Test passed' : '❌ Test failed');
}
```

---

## 12. Debugging

Enable verbose logging untuk debug:

```dart
// Semua service sudah include print statements
// Check console untuk melihat flow:

// 🚀 Starting tracking...
// ✅ Trip created with ID: 123
// 📍 Distance from last point: 50m, Speed: 45.0 km/h
// ✅ Point added! Total distance: 0.050 km
// 💾 Saving trip...
// 📤 Sending trip to backend...
// ✅ Trip saved to backend successfully
// 📊 Updating odometer: 8450.0 → 8475.5 km
// ✅ Odometer updated successfully
```

---

## Kontak

Jika ada pertanyaan atau issue, silakan hubungi tim backend untuk memastikan endpoint sudah tersedia.

**Dokumentasi Backend API**: Lihat file `BACKEND_API_TRIP_ODOMETER.md`
