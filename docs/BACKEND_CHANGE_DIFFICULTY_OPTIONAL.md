# Backend Change Request - Difficulty Optional for Tips API

## Latar Belakang

Frontend form `Tambah Tips` tidak memiliki input tingkat kesulitan. Saat ini backend masih mewajibkan field `difficulty` pada endpoint create/update tip, sehingga request gagal dengan `422`.

Contoh error saat ini:

```json
{
  "message": "Judul minimal 10 karakter. (and 1 more error)",
  "errors": {
    "title": ["Judul minimal 10 karakter."],
    "difficulty": ["Tingkat kesulitan harus dipilih."]
  }
}
```

## Tujuan Perubahan

1. Menghapus kewajiban `difficulty` dari request create/update tip.
2. Menjaga kompatibilitas data lama yang sudah memiliki nilai difficulty.
3. Tetap mendukung filter `difficulty` di endpoint list jika nilai tersedia.

## Endpoint Terdampak

1. `POST /api/v1/motorcycle/tips`
2. `PUT /api/v1/motorcycle/tips/{id}`
3. `GET /api/v1/motorcycle/public/tips`
4. `GET /api/v1/motorcycle/tips`

## Perubahan Kontrak API

### Sebelum

- `difficulty`: **required** (enum `Mudah|Sedang|Sulit`)

### Sesudah

- `difficulty`: **optional** (nullable, enum `Mudah|Sedang|Sulit` bila dikirim)

## Perubahan Validasi Backend

### StoreTipRequest / UpdateTipRequest

Ubah rule:

```php
// sebelum
'difficulty' => ['required', Rule::in(['Mudah', 'Sedang', 'Sulit'])],

// sesudah
'difficulty' => ['nullable', Rule::in(['Mudah', 'Sedang', 'Sulit'])],
```

Catatan:

- Jangan memaksa fallback otomatis di backend jika memang ingin benar-benar tanpa difficulty.
- Jika tetap ingin fallback, gunakan default yang konsisten di service layer dan dokumentasikan nilainya.

## Perubahan Persistence

Pastikan kolom database `difficulty` menerima null:

1. Jika kolom sekarang `NOT NULL`, ubah migration/alter jadi nullable.
2. Untuk data lama tidak perlu migrasi nilai, cukup pertahankan nilai existing.

Contoh migration alter:

```php
Schema::table('tips', function (Blueprint $table) {
    $table->string('difficulty')->nullable()->change();
});
```

## Perubahan Resource/Response

Pada resource list/detail:

- Jika `difficulty` null, response bisa:
  1. mengirim `difficulty: null`, atau
  2. mengirim object default tampilan (opsional)

Rekomendasi konsisten:

```json
"difficulty": null
```

## Dampak Filter

Query parameter `difficulty` tetap dipertahankan:

- Jika parameter dikirim, filter hanya data dengan difficulty sesuai.
- Data tanpa difficulty tidak ikut hasil filter difficulty.
- Jika parameter tidak dikirim, tampilkan semua data termasuk yang null.

## Kompatibilitas Frontend

Status saat ini di frontend:

- FE sementara mengirim fallback `difficulty: "Mudah"` untuk kompatibilitas backend lama.
- Setelah backend selesai diupdate, fallback FE bisa dihapus.

File terkait frontend:

- `lib/features/profil/tambah_tips_page.dart`
- `lib/core/services/tips_service.dart`

## Test Case Backend (Wajib)

1. Create tip tanpa field `difficulty` => sukses `201`.
2. Update tip tanpa field `difficulty` => sukses `200`.
3. Create tip dengan `difficulty` valid => sukses.
4. Create tip dengan `difficulty` invalid => gagal `422`.
5. GET tips tanpa filter difficulty => data dengan `difficulty=null` tetap muncul.
6. GET tips dengan filter difficulty => hanya data difficulty match yang muncul.

## Acceptance Criteria

1. Error validasi `difficulty` tidak muncul lagi saat request tanpa difficulty.
2. Endpoint create/update tetap valid untuk payload lama yang mengirim difficulty.
3. Dokumentasi API menyatakan `difficulty` optional.
4. Tidak ada regresi di fitur filter list tips.
