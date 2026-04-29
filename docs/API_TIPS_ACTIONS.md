# API Tips Actions — Like, Simpan, Rating, Share

Dokumen ini berisi spesifikasi endpoint yang dibutuhkan frontend untuk fitur interaksi tips.  
Frontend sudah siap memanggil semua endpoint ini. Backend tinggal menyesuaikan response-nya.

---

## Autentikasi

Semua endpoint di bawah memerlukan **Bearer Token** di header. User harus login terlebih dahulu.

```
Authorization: Bearer <token>
Content-Type: application/json
```

---

## 1. Like / Unlike Tips

**Endpoint:** `POST /tips/:id/like`

### Request Body

```json
{
  "action": "like"
}
```

atau untuk unlike:

```json
{
  "action": "unlike"
}
```

| Field    | Type   | Nilai            | Keterangan               |
| -------- | ------ | ---------------- | ------------------------ |
| `action` | string | `like`, `unlike` | Aksi yang dilakukan user |

### Response 200 OK

```json
{
  "success": true,
  "message": "Like berhasil",
  "data": {
    "is_liked": true,
    "likes_count": 42
  }
}
```

| Field         | Type    | Keterangan                        |
| ------------- | ------- | --------------------------------- |
| `is_liked`    | boolean | Status like user saat ini         |
| `likes_count` | integer | Total likes terbaru pada tips ini |

### Response Error

```json
{
  "success": false,
  "message": "Tips tidak ditemukan"
}
```

- `404` — tips tidak ditemukan
- `401` — tidak terautentikasi

### Catatan Backend

- Jika user sudah like lalu kirim `"action": "unlike"`, hapus like-nya
- Jika kirim `"like"` padahal sudah liked, abaikan (idempotent)
- Update kolom `likes_count` di tabel tips secara realtime

---

## 2. Simpan / Unsimpan Tips (Bookmark)

**Endpoint:** `POST /tips/:id/bookmark`

### Request Body

```json
{
  "action": "bookmark"
}
```

atau untuk hapus simpanan:

```json
{
  "action": "unbookmark"
}
```

| Field    | Type   | Nilai                    | Keterangan               |
| -------- | ------ | ------------------------ | ------------------------ |
| `action` | string | `bookmark`, `unbookmark` | Aksi yang dilakukan user |

### Response 200 OK

```json
{
  "success": true,
  "message": "Tips disimpan",
  "data": {
    "is_bookmarked": true,
    "bookmarks_count": 15
  }
}
```

| Field             | Type    | Keterangan                           |
| ----------------- | ------- | ------------------------------------ |
| `is_bookmarked`   | boolean | Status simpan user saat ini          |
| `bookmarks_count` | integer | Total simpanan terbaru pada tips ini |

### Response Error

```json
{
  "success": false,
  "message": "Tips tidak ditemukan"
}
```

- `404` — tips tidak ditemukan
- `401` — tidak terautentikasi

### Catatan Backend

- Simpan ke tabel `user_bookmarks` (atau sejenisnya) dengan kolom `user_id` + `tip_id`
- Idempotent — tidak error jika bookmark dikirim dua kali

---

## 3. Rating Tips ⭐

> **Rating belum ada endpoint-nya.** Ini endpoint BARU yang perlu dibuat.

**Endpoint:** `POST /tips/:id/rate`

### Request Body

```json
{
  "rating": 4
}
```

| Field    | Type    | Nilai | Keterangan                       |
| -------- | ------- | ----- | -------------------------------- |
| `rating` | integer | 1 – 5 | Nilai rating yang diberikan user |

### Response 200 OK

```json
{
  "success": true,
  "message": "Rating berhasil disimpan",
  "data": {
    "user_rating": 4,
    "average_rating": 4.2,
    "ratings_count": 28
  }
}
```

| Field            | Type    | Keterangan                              |
| ---------------- | ------- | --------------------------------------- |
| `user_rating`    | integer | Rating yang baru saja dikirim user      |
| `average_rating` | float   | Rata-rata rating semua user (2 desimal) |
| `ratings_count`  | integer | Total pemberi rating pada tips ini      |

### Response Error

```json
{
  "success": false,
  "message": "Rating harus antara 1 sampai 5"
}
```

- `422` — rating di luar range 1–5
- `404` — tips tidak ditemukan
- `401` — tidak terautentikasi (rating wajib login)

### Catatan Backend

- Buat tabel `tip_ratings` dengan kolom: `id`, `user_id`, `tip_id`, `rating`, `created_at`, `updated_at`
- Jika user sudah pernah rating tips yang sama → **UPDATE**, bukan insert baru
- Hitung `average_rating` di tips dengan `AVG(rating)` dari tabel `tip_ratings`
- Rating hanya untuk user yang **sudah login** (tidak perlu guest mode)
- `average_rating` di tabel tips perlu di-sync (bisa pakai DB trigger atau update otomatis)

---

## 4. Share Tips

**Endpoint:** `POST /tips/:id/share`

### Request Body

```json
{
  "platform": "whatsapp"
}
```

| Field      | Type   | Nilai yang valid                                         | Keterangan            |
| ---------- | ------ | -------------------------------------------------------- | --------------------- |
| `platform` | string | `whatsapp`, `instagram`, `twitter`, `copy_link`, `other` | Platform yang dipakai |

### Response 200 OK

```json
{
  "success": true,
  "message": "Share tercatat",
  "data": {
    "shares_count": 7
  }
}
```

| Field          | Type    | Keterangan                        |
| -------------- | ------- | --------------------------------- |
| `shares_count` | integer | Total share terbaru pada tips ini |

### Response Error

```json
{
  "success": false,
  "message": "Tips tidak ditemukan"
}
```

- `404` — tips tidak ditemukan

### Catatan Backend

- Share hanya untuk **tracking analytics** — tidak ada state "sudah share / belum"
- Boleh dipanggil berulang kali (setiap user share, selalu increment)
- Data bisa disimpan di tabel `tip_shares` untuk analytic detail per platform

---

## Ringkasan Semua Endpoint

| Fitur        | Method | Endpoint             | Auth        |
| ------------ | ------ | -------------------- | ----------- |
| Like/Unlike  | POST   | `/tips/:id/like`     | Token wajib |
| Simpan/Hapus | POST   | `/tips/:id/bookmark` | Token wajib |
| Rating       | POST   | `/tips/:id/rate`     | Token wajib |
| Share        | POST   | `/tips/:id/share`    | Token wajib |

---

## Field yang Diharapkan di Response `GET /tips/:id`

Setelah semua endpoint di atas diimplementasi, pastikan response **detail tips** menyertakan:

```json
{
  "data": {
    "id": 7,
    "...field lainnya...",
    "is_liked": false,
    "is_bookmarked": true,
    "stats": {
      "likes_count": 42,
      "bookmarks_count": 15,
      "views_count": 120,
      "rating": 4.2,
      "ratings_count": 28
    }
  }
}
```

Field `is_liked` dan `is_bookmarked` harus dihitung berdasarkan **user yang sedang login** pada request tersebut.
