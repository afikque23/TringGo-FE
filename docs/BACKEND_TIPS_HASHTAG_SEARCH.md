# Backend Contract: Tips Hashtag and Keyword Search

## Purpose

Dokumen ini mendefinisikan kontrak backend untuk fitur hashtag pada Tips Perawatan, termasuk create/update tips dan pencarian berbasis keyword/hashtag.

## Affected Endpoints

1. POST /tips
2. PUT /tips/{id}
3. GET /public/tips
4. GET /tips

## Request Contract (Create/Update)

### Field: hashtags

- Type: array of string
- Required: no
- Max items: 10
- Item length: 2-30 karakter setelah normalisasi
- Input dari frontend boleh dengan atau tanpa simbol #

### Example Request Body

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
  "tools": [{ "name": "Kunci Ring 17", "is_optional": false }],
  "steps": [
    { "title": "Persiapan", "description": "Siapkan alat" },
    { "title": "Ganti Oli", "description": "Lakukan penggantian" },
    { "title": "Cek Level", "description": "Pastikan level oli sesuai" }
  ],
  "hashtags": ["#Oli Mesin", "Perawatan Rutin", "Daily Rider"],
  "is_copyable": true
}
```

## Normalization Rules (Backend)

Jalankan normalisasi berikut sebelum disimpan:

1. Trim spasi awal/akhir.
2. Hapus prefix # berulang di awal (contoh: ###Oli -> Oli).
3. Ubah multiple spaces menjadi single space.
4. Buang item kosong.
5. Deduplikasi case-insensitive (contoh: "Oli Mesin" dan "oli mesin" dianggap sama).

Disarankan menyimpan dua bentuk nilai:

- display_value: untuk ditampilkan di UI
- normalized_value: untuk filter/search (lowercase)

## Search and Filter Contract

### Query Parameter: search

- Type: string
- Behavior: keyword harus mencari di title, description, dan hashtags
- Match type: partial match, case-insensitive

### Query Parameter: hashtags

- Type: string (comma-separated)
- Example: hashtags=oli mesin,daily rider
- Behavior: filter berdasarkan normalized hashtag
- Rekomendasi default: OR semantics (minimal salah satu hashtag cocok)

## Response Contract

Setiap tip pada list/detail harus mengembalikan field:

```json
{
  "hashtags": ["Oli Mesin", "Perawatan Rutin", "Daily Rider"]
}
```

Catatan:

- Tidak wajib menambahkan simbol # pada response.
- Konsisten antara endpoint list dan detail.

## Validation Error Examples

### Too Many Hashtags

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "hashtags": ["Hashtag maksimal 10 item"]
  },
  "error_code": "VALIDATION_ERROR"
}
```

### Invalid Item Length

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "hashtags.0": ["Panjang hashtag harus 2-30 karakter"]
  },
  "error_code": "VALIDATION_ERROR"
}
```

## Recommended Database Design

Opsional 1 (recommended): relational table

- tips_hashtags
- id (PK)
- tip_id (FK -> tips.id)
- display_value (varchar)
- normalized_value (varchar, indexed)
- created_at, updated_at

Opsional 2: JSON column di tabel tips

- hashtags_json (JSON)
- Tambahkan generated column untuk indexing jika diperlukan

## SQL Query Guidance

Contoh pseudo-query untuk search:

```sql
WHERE
  LOWER(t.title) LIKE :q
  OR LOWER(t.description) LIKE :q
  OR EXISTS (
    SELECT 1
    FROM tips_hashtags th
    WHERE th.tip_id = t.id
      AND th.normalized_value LIKE :q
  )
```

Contoh pseudo-query untuk hashtags filter:

```sql
WHERE EXISTS (
  SELECT 1
  FROM tips_hashtags th
  WHERE th.tip_id = t.id
    AND th.normalized_value IN (:normalizedHashtags)
)
```

## Acceptance Checklist

1. POST /tips menerima dan menyimpan hashtags dengan normalisasi.
2. PUT /tips/{id} bisa update hashtags (replace list lama).
3. GET /public/tips?search=oli menemukan tips dengan hashtag "Oli Mesin".
4. GET /public/tips?hashtags=oli mesin bisa filter data dengan benar.
5. Response list dan detail selalu menyertakan field hashtags.
6. Validasi error untuk data hashtags tidak valid sudah konsisten.

## Frontend Mapping

Implementasi frontend Flutter yang sudah terhubung ke kontrak ini:

1. Form create tips mengirim field `hashtags` ke request `POST /tips`.
2. Service `getAllTips` mendukung query parameter `hashtags` untuk endpoint list.
3. Search bar di halaman list tips mendukung input keyword + hashtag sekaligus.
4. Input hashtag dari search bar menggunakan format `#tag` dan otomatis dikonversi menjadi query comma-separated untuk parameter `hashtags`.
5. List tips menampilkan hashtag dari response backend jika tersedia.

Referensi file frontend:

- `lib/features/profil/tambah_tips_page.dart`
- `lib/core/services/tips_service.dart`
- `lib/features/tips_perawatan/tips_perawatan.dart`
