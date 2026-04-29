# API Documentation - Tips Perawatan Motor

## Base URL

### Development

```
http://localhost/api/v1/motorcycle
```

### Production (Future)

```
https://api.motorcare.com/v1/motorcycle
```

## Authentication

### Authenticated Users

Gunakan Bearer Token di header:

```
Authorization: Bearer {access_token}
```

### Guest Mode (Device ID)

Untuk fitur like, bookmark, dan share tanpa login:

```
X-Device-ID: {unique_device_id}
```

**Note**: Device ID harus unique per device, bisa menggunakan device UUID atau generate sendiri.

---

## 📋 Endpoints Overview

### Public Endpoints (No Authentication Required)

| Method | Endpoint            | Description                                |
| ------ | ------------------- | ------------------------------------------ |
| GET    | `/public/tips`      | Mendapatkan daftar tips published (public) |
| GET    | `/public/tips/{id}` | Mendapatkan detail tips published (public) |

### Protected Endpoints (Authentication Required)

| Method | Endpoint                  | Description                                      |
| ------ | ------------------------- | ------------------------------------------------ |
| GET    | `/tips`                   | Mendapatkan daftar tips (termasuk milik sendiri) |
| GET    | `/tips/{id}`              | Mendapatkan detail tips                          |
| POST   | `/tips`                   | Membuat tips baru                                |
| PUT    | `/tips/{id}`              | Update tips (owner only)                         |
| DELETE | `/tips/{id}`              | Hapus tips (owner only)                          |
| POST   | `/tips/{id}/like`         | Like/unlike tips (supports guest mode)           |
| POST   | `/tips/{id}/bookmark`     | Bookmark/unbookmark tips (supports guest mode)   |
| POST   | `/tips/{id}/share`        | Catat sharing tips (supports guest mode)         |
| POST   | `/tips/{id}/use-template` | Buat jadwal dari template tips                   |

---

## 1. GET /tips - List Tips Perawatan

**Endpoint**: `GET /tips` (Protected) atau `GET /public/tips` (Public)

**Note**:

- `/public/tips` - Hanya menampilkan tips dengan status `published`
- `/tips` - Menampilkan tips published + tips milik user sendiri (all status)
- `search` mencari keyword di `title`, `description`, dan `hashtags`

### Query Parameters

| Parameter      | Type    | Required | Description                                         | Example                 |
| -------------- | ------- | -------- | --------------------------------------------------- | ----------------------- |
| `page`         | integer | No       | Halaman (default: 1)                                | `1`                     |
| `limit`        | integer | No       | Jumlah per halaman (default: 10, max: 50)           | `10`                    |
| `search`       | string  | No       | Pencarian berdasarkan judul/deskripsi/hashtags      | `ganti oli`             |
| `brand`        | string  | No       | Filter merek motor                                  | `Honda,Yamaha`          |
| `difficulty`   | string  | No       | Filter tingkat kesulitan                            | `Mudah,Sedang,Sulit`    |
| `riding_style` | string  | No       | Filter gaya berkendara                              | `Harian / Commuter`     |
| `tags`         | string  | No       | Filter berdasarkan tags                             | `Trending,AI Verified`  |
| `hashtags`     | string  | No       | Filter hashtag (comma-separated, tanpa simbol `#`)  | `oli mesin,daily rider` |
| `sort_by`      | string  | No       | Sorting: `latest`, `popular`, `rating`, `relevance` | `popular`               |
| `user_id`      | string  | No       | Filter tips dari user tertentu                      | `user_123`              |

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Tips berhasil diambil",
  "data": {
    "tips": [
      {
        "id": "tip_001",
        "title": "Cara Efisien Ganti Oli untuk Pemakaian Harian",
        "description": "Metode ganti oli yang terbukti memperpanjang umur mesin hingga 30%",
        "tags": [
          {
            "id": "tag_001",
            "name": "Trending",
            "type": "trending",
            "color": "#FF8904"
          },
          {
            "id": "tag_002",
            "name": "Rekomendasi AI",
            "type": "ai_recommended",
            "color": "#6B7C4F"
          },
          {
            "id": "tag_003",
            "name": "Terbukti",
            "type": "verified",
            "color": "#51A2FF"
          }
        ],
        "author": {
          "id": "user_123",
          "name": "Budi Santoso",
          "avatar_emoji": "👨‍🔧",
          "badge": {
            "name": "Top Creator",
            "icon": "⭐",
            "color": "#F0B100"
          }
        },
        "vehicle": {
          "brand": "Honda",
          "model": "PCX 160",
          "year": 2023
        },
        "difficulty": {
          "level": "Mudah",
          "color": "#6B7C4F"
        },
        "stats": {
          "rating": 4.8,
          "likes_count": 234,
          "bookmarks_count": 89,
          "shares_count": 45,
          "views_count": 1523,
          "success_percentage": 96
        },
        "is_liked": false,
        "is_bookmarked": false,
        "created_at": "2026-03-10T10:30:00Z",
        "updated_at": "2026-03-10T10:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 47,
      "items_per_page": 10,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

---

## 2. GET /tips/{id} - Detail Tips Perawatan

**Endpoint**: `GET /tips/{id}` (Protected) atau `GET /public/tips/{id}` (Public)

**Note**:

- `/public/tips/{id}` - Hanya untuk tips dengan status `published`
- `/tips/{id}` - Bisa akses tips sendiri dengan status apapun

### Path Parameters

| Parameter | Type   | Required | Description |
| --------- | ------ | -------- | ----------- |
| `id`      | string | Yes      | ID tips     |

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Detail tips berhasil diambil",
  "data": {
    "id": "tip_001",
    "title": "Cara Efisien Ganti Oli untuk Pemakaian Harian",
    "description": "Metode ganti oli yang terbukti memperpanjang umur mesin hingga 30%",
    "tags": [
      {
        "id": "tag_001",
        "name": "Mudah",
        "type": "difficulty",
        "color": "#6B7C4F",
        "icon": "straighten"
      },
      {
        "id": "tag_002",
        "name": "Harian / Commuter",
        "type": "riding_style",
        "color": "#2B7FFF",
        "icon": "directions_bike"
      }
    ],
    "author": {
      "id": "user_123",
      "name": "Budi Santoso",
      "avatar_emoji": "👨‍🔧",
      "badge": {
        "name": "Top Creator",
        "icon": "⭐",
        "color": "#F0B100"
      },
      "bio": "Mekanik profesional dengan 15 tahun pengalaman",
      "stats": {
        "tips_count": 24,
        "followers_count": 1523
      }
    },
    "vehicle": {
      "brand": "Honda",
      "model": "PCX 160",
      "year": 2023,
      "riding_style": "Harian / Commuter"
    },
    "stats": {
      "rating": 4.8,
      "likes_count": 234,
      "bookmarks_count": 89,
      "shares_count": 45,
      "views_count": 1523,
      "success_percentage": 96
    },
    "difficulty": {
      "level": "Mudah",
      "color": "#6B7C4F",
      "estimated_time": "30 menit"
    },
    "tools": [
      {
        "id": "tool_001",
        "name": "Kunci Ring 17",
        "is_optional": false
      },
      {
        "id": "tool_002",
        "name": "Wadah Oli Bekas",
        "is_optional": false
      },
      {
        "id": "tool_003",
        "name": "Kain Lap",
        "is_optional": false
      },
      {
        "id": "tool_004",
        "name": "Oli Mesin Original (0.8L)",
        "is_optional": false
      },
      {
        "id": "tool_005",
        "name": "Filter Oli",
        "is_optional": true
      }
    ],
    "steps": [
      {
        "step_number": 1,
        "title": "Persiapan",
        "description": "Siapkan semua alat yang diperlukan: kunci ring 17, wadah oli bekas, kain lap, dan oli mesin original. Pastikan motor dalam kondisi dingin."
      },
      {
        "step_number": 2,
        "title": "Posisikan Motor",
        "description": "Parkirkan motor di tempat yang rata dan gunakan standar tengah. Pastikan motor dalam posisi stabil sebelum memulai."
      },
      {
        "step_number": 3,
        "title": "Kuras Oli Lama",
        "description": "Lepaskan baut pembuangan oli menggunakan kunci ring 17. Letakkan wadah di bawah untuk menampung oli bekas."
      },
      {
        "step_number": 4,
        "title": "Ganti Filter (Opsional)",
        "description": "Jika sudah waktunya, ganti juga filter oli. Pastikan filter terpasang dengan benar."
      },
      {
        "step_number": 5,
        "title": "Isi Oli Baru",
        "description": "Pasang kembali baut pembuangan dengan torsi yang tepat. Isi oli baru melalui lubang pengisian sesuai takaran."
      },
      {
        "step_number": 6,
        "title": "Cek Level Oli",
        "description": "Hidupkan mesin sebentar, matikan, dan cek level oli menggunakan dipstick. Tambahkan jika kurang."
      }
    ],
    "maintenance_interval": {
      "distance_km": 2000,
      "time_months": 3,
      "description": "Lakukan setiap 2000 km atau 3 bulan"
    },
    "important_notes": "⚠️ Pastikan oli yang digunakan sesuai spesifikasi pabrikan. Gunakan oli dengan viskositas yang tepat untuk iklim tropis. Jangan lupa buang oli bekas dengan cara yang ramah lingkungan.",
    "hashtags": ["#Oli Mesin", "#Perawatan Rutin", "#Daily Rider"],
    "is_copyable": true,
    "is_liked": false,
    "is_bookmarked": false,
    "created_at": "2026-03-10T10:30:00Z",
    "updated_at": "2026-03-10T10:30:00Z"
  }
}
```

### Response Error (404 Not Found)

```json
{
  "success": false,
  "message": "Tips tidak ditemukan",
  "error_code": "TIPS_NOT_FOUND"
}
```

---

## 3. POST /tips - Buat Tips Baru

**Endpoint**: `POST /tips` (Protected)

**Authentication**: Required

**Note**:

- Tips yang baru dibuat akan memiliki status `pending_review` (bisa diubah ke `published` untuk auto-publish)
- Tag untuk difficulty dan riding_style akan otomatis di-generate
- Jika product flow tidak menggunakan tingkat kesulitan, lihat rencana perubahan di `BACKEND_CHANGE_DIFFICULTY_OPTIONAL.md`

### Request Body

```json
{
  "title": "Cara Efisien Ganti Oli untuk Pemakaian Harian",
  "description": "Metode ganti oli yang terbukti memperpanjang umur mesin hingga 30%",
  "vehicle": {
    "brand": "Honda",
    "model": "PCX 160",
    "year": 2023,
    "riding_style": "Harian / Commuter"
  },
  "difficulty": "Mudah",
  "estimated_time": "30 menit",
  "tools": [
    {
      "name": "Kunci Ring 17",
      "is_optional": false
    },
    {
      "name": "Wadah Oli Bekas",
      "is_optional": false
    },
    {
      "name": "Filter Oli",
      "is_optional": true
    }
  ],
  "steps": [
    {
      "title": "Persiapan",
      "description": "Siapkan semua alat yang diperlukan: kunci ring 17, wadah oli bekas, kain lap, dan oli mesin original. Pastikan motor dalam kondisi dingin."
    },
    {
      "title": "Posisikan Motor",
      "description": "Parkirkan motor di tempat yang rata dan gunakan standar tengah. Pastikan motor dalam posisi stabil sebelum memulai."
    }
  ],
  "maintenance_interval": {
    "distance_km": 2000,
    "time_months": 3
  },
  "important_notes": "Pastikan oli yang digunakan sesuai spesifikasi pabrikan. Gunakan oli dengan viskositas yang tepat untuk iklim tropis.",
  "hashtags": ["Oli Mesin", "Perawatan Rutin", "Daily Rider"],
  "is_copyable": true
}
```

### Validation Rules

| Field                              | Type    | Required | Rules                              |
| ---------------------------------- | ------- | -------- | ---------------------------------- |
| `title`                            | string  | Yes      | Min: 10, Max: 200 characters       |
| `description`                      | string  | Yes      | Min: 20, Max: 500 characters       |
| `vehicle.brand`                    | string  | Yes      | Valid brand from list              |
| `vehicle.model`                    | string  | Yes      | Min: 2, Max: 100 characters        |
| `vehicle.year`                     | integer | Yes      | Range: 1990-current year           |
| `vehicle.riding_style`             | string  | Yes      | Valid riding style from list       |
| `difficulty`                       | string  | Yes      | One of: `Mudah`, `Sedang`, `Sulit` |
| `estimated_time`                   | string  | No       | Format: `{number} menit/jam`       |
| `tools`                            | array   | Yes      | Min: 1 item                        |
| `steps`                            | array   | Yes      | Min: 3 items                       |
| `maintenance_interval.distance_km` | integer | No       | Min: 100, Max: 50000               |
| `maintenance_interval.time_months` | integer | No       | Min: 1, Max: 60                    |
| `hashtags`                         | array   | No       | Max: 10 items, item 2-30 karakter  |

### Response Success (201 Created)

```json
{
  "success": true,
  "message": "Tips berhasil dibuat",
  "data": {
    "id": "tip_123",
    "title": "Cara Efisien Ganti Oli untuk Pemakaian Harian",
    "status": "pending_review",
    "created_at": "2026-03-14T08:30:00Z"
  }
}
```

### Response Error (400 Bad Request)

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "title": ["Judul harus diisi minimal 10 karakter"],
    "steps": ["Minimal 3 langkah diperlukan"]
  },
  "error_code": "VALIDATION_ERROR"
}
```

---

## 4. PUT /tips/{id} - Update Tips

**Endpoint**: `PUT /tips/{id}` (Protected)

**Authentication**: Required

**Authorization**: Only the owner of the tip can update it

### Path Parameters

| Parameter | Type    | Required | Description                |
| --------- | ------- | -------- | -------------------------- |
| `id`      | integer | Yes      | ID tips yang akan diupdate |

### Request Body

Same structure as POST /tips

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Tips berhasil diupdate",
  "data": {
    "id": "tip_001",
    "title": "Cara Efisien Ganti Oli untuk Pemakaian Harian",
    "updated_at": "2026-03-14T08:30:00Z"
  }
}
```

### Response Error (403 Forbidden)

```json
{
  "success": false,
  "message": "Anda tidak memiliki izin untuk mengupdate tips ini",
  "error_code": "FORBIDDEN"
}
```

---

## 5. DELETE /tips/{id} - Hapus Tips

**Endpoint**: `DELETE /tips/{id}` (Protected)

**Authentication**: Required

**Authorization**: Only the owner of the tip can delete it

**Note**: Menggunakan soft delete, data tidak benar-benar terhapus dari database

### Path Parameters

| Parameter | Type    | Required | Description               |
| --------- | ------- | -------- | ------------------------- |
| `id`      | integer | Yes      | ID tips yang akan dihapus |

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Tips berhasil dihapus"
}
```

---

## 6. POST /tips/{id}/like - Like/Unlike Tips

**Endpoint**: `POST /tips/{id}/like` (Protected/Guest)

**Authentication**: Optional (supports guest mode dengan X-Device-ID)

**Headers**:

- Jika authenticated: `Authorization: Bearer {token}`
- Jika guest: `X-Device-ID: {unique_device_id}`

### Path Parameters

| Parameter | Type    | Required | Description |
| --------- | ------- | -------- | ----------- |
| `id`      | integer | Yes      | ID tips     |

### Request Body

```json
{
  "action": "like"
}
```

**action**: `like` atau `unlike`

**Note**: System otomatis toggle jika action sama dengan status saat ini

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Tips berhasil dilike",
  "data": {
    "is_liked": true,
    "likes_count": 235
  }
}
```

---

## 7. POST /tips/{id}/bookmark - Bookmark/Unbookmark Tips

**Endpoint**: `POST /tips/{id}/bookmark` (Protected/Guest)

**Authentication**: Optional (supports guest mode dengan X-Device-ID)

**Headers**:

- Jika authenticated: `Authorization: Bearer {token}`
- Jika guest: `X-Device-ID: {unique_device_id}`

### Path Parameters

| Parameter | Type    | Required | Description |
| --------- | ------- | -------- | ----------- |
| `id`      | integer | Yes      | ID tips     |

### Request Body

```json
{
  "action": "bookmark"
}
```

**action**: `bookmark` atau `unbookmark`

**Note**: System otomatis toggle jika action sama dengan status saat ini

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Tips berhasil disimpan",
  "data": {
    "is_bookmarked": true,
    "bookmarks_count": 90
  }
}
```

---

## 8. POST /tips/{id}/share - Catat Share Tips

**Endpoint**: `POST /tips/{id}/share` (Protected/Guest)

**Authentication**: Optional (supports guest mode dengan X-Device-ID)

**Headers**:

- Jika authenticated: `Authorization: Bearer {token}`
- Jika guest: `X-Device-ID: {unique_device_id}`

### Path Parameters

| Parameter | Type    | Required | Description |
| --------- | ------- | -------- | ----------- |
| `id`      | integer | Yes      | ID tips     |

### Request Body

```json
{
  "platform": "whatsapp"
}
```

**platform**: `whatsapp`, `telegram`, `facebook`, `twitter`, `copy_link`

**Note**: Endpoint ini hanya untuk tracking, tidak menghandle actual sharing

### Response Success (200 OK)

```json
{
  "success": true,
  "message": "Share berhasil dicatat",
  "data": {
    "shares_count": 46
  }
}
```

---

## 9. POST /tips/{id}/use-template - Buat Jadwal dari Template

**Endpoint**: `POST /tips/{id}/use-template` (Protected)

**Authentication**: Required

**Note**: Endpoint ini membuat service schedule baru berdasarkan template tips

### Path Parameters

| Parameter | Type    | Required | Description |
| --------- | ------- | -------- | ----------- |
| `id`      | integer | Yes      | ID tips     |

### Request Body

```json
{
  "vehicle_id": "vehicle_123",
  "schedule_type": "interval",
  "interval_type": "distance",
  "interval_value": 2000,
  "start_date": "2026-03-15",
  "notes": "Ganti oli rutin sesuai rekomendasi"
}
```

| Field            | Type    | Required | Description                                     |
| ---------------- | ------- | -------- | ----------------------------------------------- |
| `vehicle_id`     | string  | Yes      | ID kendaraan user                               |
| `schedule_type`  | string  | Yes      | `interval` atau `one_time`                      |
| `interval_type`  | string  | No       | `distance`, `time`, atau `both` (jika interval) |
| `interval_value` | integer | No       | Nilai interval dalam km atau bulan              |
| `start_date`     | string  | No       | Format: YYYY-MM-DD                              |
| `notes`          | string  | No       | Catatan tambahan                                |

### Response Success (201 Created)

```json
{
  "success": true,
  "message": "Jadwal perawatan berhasil dibuat dari template",
  "data": {
    "schedule_id": "schedule_456",
    "tips_id": "tip_001",
    "vehicle_id": "vehicle_123",
    "next_maintenance_date": "2026-06-15",
    "created_at": "2026-03-14T08:30:00Z"
  }
}
```

---

## 📊 Data Models

### Tips Model

```json
{
  "id": "integer",
  "title": "string",
  "description": "string",
  "author_id": "integer",
  "difficulty": "enum: Mudah|Sedang|Sulit",
  "estimated_time": "string",
  "is_copyable": "boolean",
  "status": "enum: pending_review|published|rejected",
  "tags": "array of Tag objects",
  "vehicle": "Vehicle object",
  "tools": "array of Tool objects",
  "steps": "array of Step objects",
  "maintenance_interval": "MaintenanceInterval object",
  "important_notes": "string",
  "hashtags": "array of strings",
  "stats": "Stats object",
  "created_at": "ISO 8601 datetime",
  "updated_at": "ISO 8601 datetime"
}
```

### Tag Model

```json
{
  "id": "string",
  "name": "string",
  "type": "enum: trending|ai_recommended|verified|difficulty|riding_style",
  "color": "string (hex color)",
  "icon": "string (optional)"
}
```

### Vehicle Model

```json
{
  "brand": "string",
  "model": "string",
  "year": "integer",
  "riding_style": "string"
}
```

### Tool Model

```json
{
  "id": "string",
  "name": "string",
  "is_optional": "boolean"
}
```

### Step Model

```json
{
  "step_number": "integer",
  "title": "string",
  "description": "string"
}
```

### MaintenanceInterval Model

```json
{
  "distance_km": "integer (nullable)",
  "time_months": "integer (nullable)",
  "description": "string (auto-generated)"
}
```

### Stats Model

```json
{
  "rating": "float",
  "likes_count": "integer",
  "bookmarks_count": "integer",
  "shares_count": "integer",
  "views_count": "integer",
  "success_percentage": "integer"
}
```

---

## 🔑 Enum Values

### Merek Motor

```
Honda, Yamaha, Suzuki, Kawasaki, Vespa, TVS, Benelli, Viar, Lainnya
```

### Gaya Berkendara

```
Harian / Commuter, Touring, Sport / Track, Off-road, Urban / City, Kombinasi
```

### Difficulty Level

```
Mudah, Sedang, Sulit
```

### Tag Types

```
trending, ai_recommended, verified, difficulty, riding_style
```

### Status

```
pending_review, published, rejected
```

---

## 🔐 Error Codes

| Code                  | HTTP Status | Description                    |
| --------------------- | ----------- | ------------------------------ |
| `UNAUTHORIZED`        | 401         | Token tidak valid atau expired |
| `FORBIDDEN`           | 403         | Tidak memiliki akses           |
| `TIPS_NOT_FOUND`      | 404         | Tips tidak ditemukan           |
| `VALIDATION_ERROR`    | 400         | Validasi input gagal           |
| `DUPLICATE_TIPS`      | 409         | Tips sudah ada                 |
| `RATE_LIMIT_EXCEEDED` | 429         | Terlalu banyak request         |
| `INTERNAL_ERROR`      | 500         | Server error                   |

---

## 📝 Notes

1. **Rate Limiting**: Max 100 requests per menit per user
2. **Pagination**: Default 10 items, max 50 items per page
3. **Guest Mode**: Like, bookmark, dan share mendukung guest mode menggunakan `X-Device-ID` header
4. **Auto-publish**: Status tips bisa di-set `published` langsung saat create (skip review)
5. **Soft Delete**: Tips yang dihapus menggunakan soft delete
6. **Image Upload**: (Future) Akan ditambahkan endpoint untuk upload gambar langkah
7. **AI Recommendation**: Tips dengan tag "Rekomendasi AI" ditentukan oleh algoritma berdasarkan profile user
8. **Verification**: Tips dengan tag "Terbukti" sudah diverifikasi oleh admin atau memiliki success rate > 90% dengan minimal 50 penggunaan
9. **Trending**: Algoritma berdasarkan views, likes, dan shares dalam 7 hari terakhir
10. **Tags**: Tag untuk difficulty dan riding_style akan otomatis di-generate saat create/update tips

---

## 🚀 Implementation Priority

### Phase 1 (MVP)

- ✅ GET /tips (list with basic filters)
- ✅ GET /tips/{id} (detail)
- ✅ POST /tips (create)
- ✅ POST /tips/{id}/like
- ✅ POST /tips/{id}/bookmark

### Phase 2

- ✅ PUT /tips/{id} (update)
- ✅ DELETE /tips/{id}
- ✅ POST /tips/{id}/use-template
- ✅ POST /tips/{id}/share

### Phase 3 (Enhancement)

- 🔄 Image upload for steps
- 🔄 Comments/reviews system
- 🔄 Report inappropriate content
- 🔄 AI-based recommendation algorithm
- 🔄 Search with autocomplete

---

## 🧪 Testing Guide

### Development Setup

1. **Base URL**: `http://localhost/api/v1/motorcycle`
2. **Auth Token**: Dapatkan dari login endpoint
3. **Device ID**: Generate UUID untuk testing guest mode

### Sample Requests (Postman/Insomnia)

#### 1. Get Public Tips

```http
GET http://localhost/api/v1/motorcycle/public/tips?search=oli&difficulty=Mudah
```

#### 2. Create Tip (Authenticated)

```http
POST http://localhost/api/v1/motorcycle/tips
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "title": "Cara Efisien Ganti Oli",
  "description": "Metode ganti oli yang efisien",
  "vehicle": {
    "brand": "Honda",
    "model": "PCX 160",
    "year": 2023,
    "riding_style": "Harian / Commuter"
  },
  "difficulty": "Mudah",
  "tools": [
    {"name": "Kunci Ring 17", "is_optional": false}
  ],
  "steps": [
    {"title": "Persiapan", "description": "Siapkan alat"},
    {"title": "Posisikan Motor", "description": "Parkirkan motor"},
    {"title": "Kuras Oli", "description": "Lepaskan baut"}
  ]
}
```

#### 3. Like Tip (Guest Mode)

```http
POST http://localhost/api/v1/motorcycle/tips/1/like
X-Device-ID: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "action": "like"
}
```

#### 4. Use as Template (Authenticated)

```http
POST http://localhost/api/v1/motorcycle/tips/1/use-template
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "vehicle_id": 1,
  "schedule_type": "interval",
  "interval_type": "distance",
  "interval_value": 2000
}
```

### Common Issues & Troubleshooting

**401 Unauthorized**

- Check token validity
- Ensure `Authorization: Bearer {token}` header is set correctly

**403 Forbidden**

- Trying to update/delete someone else's tip
- Only the owner can modify their tips

**422 Validation Error**

- Check request body format matches documentation
- Ensure all required fields are present
- Verify data types (integer vs string)
- Steps minimum 3 items required

**404 Not Found**

- Tip ID doesn't exist or has been deleted
- For public endpoints, check if tip status is `published`

**Database Connection Error**

- Ensure MySQL server is running in Laragon
- Check `.env` database configuration

**500 SQLSTATE[42S02] Table `tips` doesn't exist**

- Penyebab: migration untuk tabel tips belum dijalankan di backend
- Solusi cepat:

```bash
php artisan migrate
php artisan migrate:status
```

- Pastikan endpoint yang dipakai frontend mengarah ke backend environment yang sama dengan database yang sudah dimigrate

---

## 📞 Support

Untuk pertanyaan lebih lanjut, hubungi:

- Email: api-support@motorcare.com
- Slack: #api-motorcycle-management
- Backend Hashtag Contract: Lihat `BACKEND_TIPS_HASHTAG_SEARCH.md`
- Backend Difficulty Optional Change: Lihat `BACKEND_CHANGE_DIFFICULTY_OPTIONAL.md`
- Flutter Integration Guide: Lihat `FLUTTER_TIPS_HASHTAG_SEARCH.md`
- Backend Implementation: Lihat `TIPS_API_IMPLEMENTATION.md` di backend repository
