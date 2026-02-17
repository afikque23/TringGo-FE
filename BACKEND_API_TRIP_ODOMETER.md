# Backend API Endpoints untuk Trip & Odometer

Dokumentasi ini menjelaskan endpoint yang perlu dibuat di backend Laravel untuk fitur Trip Tracking dan Odometer Update.

## Base URL

```
http://192.168.1.11:8000/api/v1/motorcycle
```

## Authentication

Semua endpoint mendukung 2 mode:

1. **Authenticated Mode**: Header `Authorization: Bearer {token}`
2. **Guest Mode**: Header `X-Device-ID: {device_id}`

---

## 1. Trip Management Endpoints

### 1.1 Create Trip (Save Trip History)

**POST** `/trips`

**Request Headers:**

```
Content-Type: application/json
Authorization: Bearer {token}  // or X-Device-ID: {device_id}
```

**Request Body:**

```json
{
  "vehicle_id": "1", // ID kendaraan atau nama kendaraan
  "start_time": "2026-02-17T10:30:00.000Z",
  "end_time": "2026-02-17T11:45:00.000Z",
  "total_distance": 25.5, // dalam km
  "duration": 4500, // dalam detik
  "average_speed": 45.2, // km/h
  "max_speed": 80.5, // km/h
  "status": "completed",
  "points": [
    {
      "latitude": -6.2,
      "longitude": 106.816666,
      "speed": 45.0, // m/s
      "altitude": 10.0,
      "accuracy": 5.0,
      "timestamp": "2026-02-17T10:30:00.000Z"
    },
    {
      "latitude": -6.201,
      "longitude": 106.817666,
      "speed": 50.0,
      "altitude": 12.0,
      "accuracy": 5.0,
      "timestamp": "2026-02-17T10:30:10.000Z"
    }
    // ... more points
  ]
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Trip saved successfully",
  "data": {
    "id": 1,
    "vehicle_id": 1,
    "user_id": 1, // or null for guest
    "device_id": "abc123", // for guest mode
    "start_time": "2026-02-17T10:30:00.000Z",
    "end_time": "2026-02-17T11:45:00.000Z",
    "total_distance": 25.5,
    "duration": 4500,
    "average_speed": 45.2,
    "max_speed": 80.5,
    "status": "completed",
    "created_at": "2026-02-17T11:45:05.000Z",
    "updated_at": "2026-02-17T11:45:05.000Z"
  }
}
```

---

### 1.2 Get All Trips

**GET** `/trips?limit=50&offset=0&vehicle_id=1`

**Query Parameters:**

- `limit` (optional): Jumlah maksimal trip yang dikembalikan (default: 50)
- `offset` (optional): Offset untuk pagination (default: 0)
- `vehicle_id` (optional): Filter berdasarkan kendaraan tertentu

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "vehicle_id": 1,
      "vehicle_name": "Ninja 250",
      "start_time": "2026-02-17T10:30:00.000Z",
      "end_time": "2026-02-17T11:45:00.000Z",
      "total_distance": 25.5,
      "duration": 4500,
      "average_speed": 45.2,
      "max_speed": 80.5,
      "status": "completed",
      "points_count": 450, // jumlah GPS points
      "created_at": "2026-02-17T11:45:05.000Z"
    }
    // ... more trips
  ],
  "meta": {
    "total": 150,
    "limit": 50,
    "offset": 0
  }
}
```

---

### 1.3 Get Trip by ID

**GET** `/trips/{id}`

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "vehicle_id": 1,
    "vehicle_name": "Ninja 250",
    "start_time": "2026-02-17T10:30:00.000Z",
    "end_time": "2026-02-17T11:45:00.000Z",
    "total_distance": 25.5,
    "duration": 4500,
    "average_speed": 45.2,
    "max_speed": 80.5,
    "status": "completed",
    "points": [
      {
        "latitude": -6.2,
        "longitude": 106.816666,
        "speed": 45.0,
        "altitude": 10.0,
        "accuracy": 5.0,
        "timestamp": "2026-02-17T10:30:00.000Z"
      }
      // ... all GPS points
    ],
    "created_at": "2026-02-17T11:45:05.000Z"
  }
}
```

---

### 1.4 Delete Trip

**DELETE** `/trips/{id}`

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Trip deleted successfully"
}
```

---

## 2. Odometer Update Endpoint

### 2.1 Update Vehicle Odometer

**PUT** `/vehicles/{vehicleId}/odometer`

**Request Headers:**

```
Content-Type: application/json
Authorization: Bearer {token}  // or X-Device-ID: {device_id}
```

**Request Body:**

```json
{
  "odometer": 8475.5, // nilai odometer baru dalam km
  "notes": "Auto-updated after trip on 2026-02-17T11:45:05.000Z"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Odometer updated successfully",
  "data": {
    "id": 1,
    "title": "Ninja 250",
    "odometer": 8475.5,
    "previous_odometer": 8450.0,
    "updated_at": "2026-02-17T11:45:05.000Z"
  }
}
```

---

## Database Schema Suggestions

### trips table

```sql
CREATE TABLE trips (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT UNSIGNED NULL,  -- NULL for guest trips
    user_id BIGINT UNSIGNED NULL,  -- NULL for guest trips
    device_id VARCHAR(255) NULL,  -- For guest mode tracking
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    total_distance DECIMAL(10, 2) NOT NULL,  -- in km
    duration INT NOT NULL,  -- in seconds
    average_speed DECIMAL(10, 2) NOT NULL,  -- km/h
    max_speed DECIMAL(10, 2) NOT NULL,  -- km/h
    status VARCHAR(50) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_device_id (device_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_start_time (start_time)
);
```

### trip_points table (untuk menyimpan GPS coordinates)

```sql
CREATE TABLE trip_points (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    trip_id BIGINT UNSIGNED NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    speed DECIMAL(10, 2) NOT NULL,  -- m/s
    altitude DECIMAL(10, 2) NULL,
    accuracy DECIMAL(10, 2) NULL,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
    INDEX idx_trip_id (trip_id)
);
```

### Catatan:

- GPS points bisa disimpan di tabel terpisah (`trip_points`) untuk optimasi
- Atau bisa disimpan sebagai JSON di kolom `points` pada tabel `trips`
- Field `device_id` untuk guest mode tracking
- Field `user_id` dan `vehicle_id` bisa NULL untuk guest users

---

## Laravel Controller Example

```php
// app/Http/Controllers/API/V1/TripController.php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Trip;
use App\Models\TripPoint;

class TripController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'vehicle_id' => 'nullable|exists:vehicles,id',
            'start_time' => 'required|date',
            'end_time' => 'nullable|date|after:start_time',
            'total_distance' => 'required|numeric|min:0',
            'duration' => 'required|integer|min:0',
            'average_speed' => 'required|numeric|min:0',
            'max_speed' => 'required|numeric|min:0',
            'status' => 'required|in:active,completed',
            'points' => 'required|array',
            'points.*.latitude' => 'required|numeric',
            'points.*.longitude' => 'required|numeric',
            'points.*.speed' => 'required|numeric',
            'points.*.timestamp' => 'required|date',
        ]);

        // Get user_id or device_id
        $userId = auth()->id();
        $deviceId = $request->header('X-Device-ID');

        $trip = Trip::create([
            'vehicle_id' => $validated['vehicle_id'] ?? null,
            'user_id' => $userId,
            'device_id' => $deviceId,
            'start_time' => $validated['start_time'],
            'end_time' => $validated['end_time'] ?? null,
            'total_distance' => $validated['total_distance'],
            'duration' => $validated['duration'],
            'average_speed' => $validated['average_speed'],
            'max_speed' => $validated['max_speed'],
            'status' => $validated['status'],
        ]);

        // Save GPS points
        foreach ($validated['points'] as $point) {
            TripPoint::create([
                'trip_id' => $trip->id,
                'latitude' => $point['latitude'],
                'longitude' => $point['longitude'],
                'speed' => $point['speed'],
                'altitude' => $point['altitude'] ?? null,
                'accuracy' => $point['accuracy'] ?? null,
                'timestamp' => $point['timestamp'],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Trip saved successfully',
            'data' => $trip,
        ], 201);
    }

    public function index(Request $request)
    {
        $limit = $request->input('limit', 50);
        $offset = $request->input('offset', 0);
        $vehicleId = $request->input('vehicle_id');

        $userId = auth()->id();
        $deviceId = $request->header('X-Device-ID');

        $query = Trip::query()
            ->where(function ($q) use ($userId, $deviceId) {
                $q->where('user_id', $userId)
                  ->orWhere('device_id', $deviceId);
            });

        if ($vehicleId) {
            $query->where('vehicle_id', $vehicleId);
        }

        $total = $query->count();
        $trips = $query->orderBy('start_time', 'desc')
                       ->skip($offset)
                       ->take($limit)
                       ->get();

        return response()->json([
            'success' => true,
            'data' => $trips,
            'meta' => [
                'total' => $total,
                'limit' => $limit,
                'offset' => $offset,
            ],
        ]);
    }

    public function show($id)
    {
        $userId = auth()->id();
        $deviceId = request()->header('X-Device-ID');

        $trip = Trip::with('points')
            ->where('id', $id)
            ->where(function ($q) use ($userId, $deviceId) {
                $q->where('user_id', $userId)
                  ->orWhere('device_id', $deviceId);
            })
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $trip,
        ]);
    }

    public function destroy($id)
    {
        $userId = auth()->id();
        $deviceId = request()->header('X-Device-ID');

        $trip = Trip::where('id', $id)
            ->where(function ($q) use ($userId, $deviceId) {
                $q->where('user_id', $userId)
                  ->orWhere('device_id', $deviceId);
            })
            ->firstOrFail();

        $trip->delete();

        return response()->json([
            'success' => true,
            'message' => 'Trip deleted successfully',
        ]);
    }
}
```

```php
// app/Http/Controllers/API/V1/VehicleController.php

public function updateOdometer(Request $request, $id)
{
    $validated = $request->validate([
        'odometer' => 'required|numeric|min:0',
        'notes' => 'nullable|string|max:500',
    ]);

    $userId = auth()->id();
    $deviceId = $request->header('X-Device-ID');

    $vehicle = Vehicle::where('id', $id)
        ->where(function ($q) use ($userId, $deviceId) {
            $q->where('user_id', $userId)
              ->orWhere('device_id', $deviceId);
        })
        ->firstOrFail();

    $previousOdometer = $vehicle->odometer;
    $vehicle->odometer = $validated['odometer'];
    $vehicle->save();

    // Optional: Log odometer changes
    // OdometerHistory::create([...]);

    return response()->json([
        'success' => true,
        'message' => 'Odometer updated successfully',
        'data' => [
            'id' => $vehicle->id,
            'title' => $vehicle->title,
            'odometer' => $vehicle->odometer,
            'previous_odometer' => $previousOdometer,
            'updated_at' => $vehicle->updated_at,
        ],
    ]);
}
```

---

## Routes (routes/api.php)

```php
Route::prefix('v1/motorcycle')->group(function () {
    // Trips
    Route::get('/trips', [TripController::class, 'index']);
    Route::post('/trips', [TripController::class, 'store']);
    Route::get('/trips/{id}', [TripController::class, 'show']);
    Route::delete('/trips/{id}', [TripController::class, 'destroy']);

    // Odometer
    Route::put('/vehicles/{id}/odometer', [VehicleController::class, 'updateOdometer']);
});
```

---

## Testing dengan Postman/cURL

### Create Trip:

```bash
curl -X POST http://192.168.1.11:8000/api/v1/motorcycle/trips \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "vehicle_id": "1",
    "start_time": "2026-02-17T10:30:00.000Z",
    "end_time": "2026-02-17T11:45:00.000Z",
    "total_distance": 25.5,
    "duration": 4500,
    "average_speed": 45.2,
    "max_speed": 80.5,
    "status": "completed",
    "points": [...]
  }'
```

### Update Odometer:

```bash
curl -X PUT http://192.168.1.11:8000/api/v1/motorcycle/vehicles/1/odometer \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "odometer": 8475.5,
    "notes": "Auto-updated after trip"
  }'
```
