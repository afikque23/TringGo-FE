# DOKUMENTASI SISTEM & IMPLEMENTASI: APLIKASI MOTORCYCLE MANAGEMENT

_Dokumentasi komprehensif ini disusun sebagai panduan utama (Master Guide) untuk penulisan Bab 3 (Perubahan/Perancangan Sistem), Bab 4 (Implementasi), serta Bab 5 (Pengujian) pada buku laporan Skripsi/Tugas Akhir._

---

## 1. Deskripsi Umum Sistem (System Overview)

Aplikasi _Motorcycle Management_ adalah platform berbasis mobile cerdas yang dibangun menggunakan framework **Flutter** untuk sisi antarmuka klien (Front-end), serta PHP **Laravel** sebagai infrastruktur _Backend_ / REST API server. Sistem ini diciptakan khusus untuk membantu pemilik hingga pengelola bengkel/kendaraan roda dua dalam memonitor kondisi kendaraan, merekam riwayat perbaikan, hingga merencakan jadwal servis atau peremajaan suku cadang (sparepart) secara tepat dan presisi.

Nilai tambah atau fitur unggulan yang menjadi daya tarik aplikasi ini:

1. **Pencatatan Servis Digital & Prediksi:** Menampilkan riwayat ganti suku cadang dan memprediksi/merekomendasikan servis berikutnya berdasarkan akumulasi kilometer tempuh aktual atau masa waktu bulanan.
2. **Background Location & Trip Tracking:** Melacak rute perjalanan (_Real-time Route Mapping_), menghitung jarak otomatis (Odometer sinkron), yang mana layanan ini mampu beroperasi secara independen di _Background_ meskipun layar dikunci (mengandalkan sensor GPS dari Native Android Layer).
3. **Edukasi Literasi Kendaraan:** Fitur _Tips Perawatan_ cerdas yang terintegrasi dengan filter pencarian instan (hashtag-based search).
4. **Notifikasi Pintar (Cloud Messaging):** Sistem pemanggil push notification terotomatisasi yang mengingatkan tentang perawatan kritis.

Aplikasi ini menargetkan kepraktisan operasi di mana pengguna memiliki akses terpadu (_All-in-One_) cukup melalui perangkat genggam (Smartphone).

---

## 2. Arsitektur Perangkat Lunak (Software Architecture Layering)

Sistem dirancang sedemikian rupa menggunakan pola arsitektur **Feature-First Architecture** dikombinasikan dengan prinsip **Clean Code (Separation of Concerns)**. Pengelompokan berkas (_codebase_) tidak didasarkan pada tipe file (semua view kumpul di view, semua model di model), melainkan didasarkan pada fungsinya.

### 2.1. Struktur Modul Utama (Direktori `lib/`)

Pondasi utama aplikasi dibagi ke dalam dua penyangga:

#### A. Direktori `lib/core/` (Logika Inti & Fondasi Komunikasi)

Folder ini menampung seluruh infrastruktur dasar dan logika tanpa antarmuka yang membungkus pemrosesan data, entitas model, serta konfigurasi eksternal.

1. **`core/network/`:** Bertindak sebagai jembatan HTTP. Mengelola _Base URL_ secara global, pembentukan API Client, Injeksi Token Otorisasi (_Bearer Headers_) pada setiap _request_, dan menangani terjemahan kegagalan koneksi (_Error Handling Interceptor_).
2. **`core/services/`:** Layer paling krusial. Bertindak sebagai _Business Logic Component_ (BLC) atau fasilitator (_wrapper_) bagi API dan _Device Hardware_.
   - _Contoh Controller Backend:_ `auth_service.dart`, `vehicle_service.dart`, `trip_service.dart`, `service_history_service.dart`.
   - _Contoh Controller Hardware/Native:_ `location_service.dart` (minta izin GPS), `notification_service.dart` (Push Notifications), `background_tracking_handler.dart` (Service Android OS).
3. **`core/model/`:** Skema representasi objek (Enterprise Business Rules/Entities). Menerima struktur `JSON` dari REST API dan di-Serialize menjadi _Dart Object_ melalui sistem _code-generation_ dari `json_serializable`.
4. **`core/utils/`:** Pengaturan universal, validasi input, fungsionalitas format uang (Rupiah), format tanggal/waktu spesifik zona, serta lokalisasi bahasa (Indonesia / Inggris).

#### B. Direktori `lib/features/` (Antarmuka dan Presentasi Per-Fitur)

Berisi seluruh antarmuka grafis yang dilihat langsung oleh user (View Layer / Presentation Layer). Dipisahkan berdasar konteks sehingga merombak UI menu A tidak berimbas ke menu B.

- `auth/`: Halaman masuk dan daftar.
- `dashboard/`: Rekap utama.
- `vehicle/`: Sistem pengelolaan motor.
- `tracking/`: Menu navigasi dan pemantauan jarak.
- `servis/` & `recommendation/`: Modul pemeliharaan dan AI-Rule basenya.
- `tips_perawatan/`: Modul bacaan edukasi.
- `profil/` & `settings/`: Personalisasi akun pengguna.

### 2.2. Pola Aliran Data & State Management

Siklus data di aplikasi ini berjalan secara linier:

- **Tampilan (View) -> Layanan (Service) -> API Server / Database Lokal -> Mengembalikan JSON -> Dikonversi ke Model (Entity) -> Tampilan (View) Me-render Ulang (setState / FutureBuilder).**
- Aplikasi ini secara murni memaksimalkan **Native Flutter State (`StatefulWidget`, `FutureBuilder`)** dipadukan dengan metode _Dependency Injection_ atau singleton via konstruktor.
- Untuk global state seperti pergantian opsi Gelap/Terang (Dark Mode) atau pergantian bahasa, menggunakan `InheritedWidget` bawaan Flutter.

---

## 3. Penjabaran Modul & Fungsionalitas Lengkap (Fitur Sistem)

Secara spesifik, aplikasi dibangun dari belasan subsistem yang saling terkorelasi.

### 3.1. Autentikasi dan Identitas Pengguna (Auth & Profile)

- **Login Ekosistem:** Proses validasi kredensial (Email & Password). Jika sukses, server mengembalikan JWT (JSON Web Token). Token ini disimpan dengan algoritma kriptografi di perangkat penggguna berkat bantuan `flutter_secure_storage`.
- **Register Account:** Pendaftaran akun baru, yang akan melalui fase validasi panjang kata sandi dan pola email (_Regex_).
- **Lupa & Reset Kata Sandi:** Fitur _Forgot Password_ dengan sistem autentikasi OTP _(One-Time Password)_. OTP dikirim ke email, lalu diverifikasi di aplikasi untuk membuka layar _Change Password_.
- **Manajemen Profil:** Menampilkan informasi personal, mengubah detail nama atau foto. Sistem juga mengelola sinkronisasi sesi, sehingga jika OTP/Token daluwarsa, otomatis _Force Logout_.

### 3.2. Dashboard Utama (Breeze Information Center)

Halaman sentral saat pengguna berhasil login. Terdiri dari beberapa panel widget (_Cards_):

- **Motorcycle Highlighter:** Manampilkan motor utama (Primary Vehicle) lengkap dengan plat nomor, merk, dan akumulasi jarak tempuh saat ini (Odometer Digital).
- **Service Alert Badges:** Memberikan notifikasi darurat berwarna peringatan jika ada servis tertentu yang tenggatnya sudah lewat (misal, Penggantian Oli Mesin segera tiba dalam 50 Km lagi).
- **Statistik Cepat:** Kumpulan rekaman singkat status servis bulan berjalan dan jarak rata-rata perjalanan minggu itu.

### 3.3. Manajemen Kendaraan (Vehicle CRUD Layer)

Modul untuk mengoperasikan struktur kendaraan agar satu akun bisa menguasai banyak motor.

- **Tambah Kendaraan Baru:** Memasukkan Merk (Brand), Tipe Motor (Series), Tahun Produksi, Plat Motor (License Plate), serta Kapasitas Mesin (CC). Pengguna juga mengatur kilometer awal saat mendaftarkan motor ke aplikasi.
- **Opsi Multi-Kendaraan:** Jika punya lebih dari 1 motor, pengguna harus bisa mengatur bendera (Flag) "Jadikan Motor Utama" (Set as Default). Semua data perjalanan yang tercatat nanti akan masuk ke odometer motor utama ini.
- **Sinkronisasi Offline:** Data motor disalin oleh Local Storage (SQL/SharedPreferences) sehingga aplikasi tidak akan mogok saat _lost connection_ secara instan.

### 3.4. Pelacakan Perjalanan (_Tracking / Foreground GPS Trip_)

Inilah jantung utama inovasi dari sistem ini.

- **Sistem Penguncian Latar Belakang (_Foreground Service_ Android):** Memanfaatkan _Service Android_ yang menampilkan Bar Notifikasi _Persistent_ di memori HP. Hal ini menyuruh OS HP (Killed by RAM / Battery Saver Mode) agar tidak mematikan aplikasi secara paksa. Modul ini terletak di `BackgroundTrackingHandler`.
- **Geolokasi Berkala (Real-time GPS):** Interval pengiriman sinyal disetel per-detik atau per-meter (via `geolocator_android`). Titik kordinat X, Y disimpan sementara (cache).
- **Komputasi Jaringan-Trip:** Mengukur Haversine distance antara dua titik secara iteratif, yang otomatis ditambahkan (Accumulated Distance) dan dikonversikan jadi Kilometer.
- **Selesai Perjalanan:** Aplikasi memaketkan seluru lintasan (Polylines), waktu tempuh, jarak kotor, dan kecepatan (Top Speed/Average), untuk diremote di REST API Trip Endpoint (via POST Method). Odometer pada _Vehicle_ terkait bertambah.

### 3.5. Riwayat Servis dan AI Rekomendasi (Service & Recommendation)

- **Form Perekaman Servis:** Menginput _Log_ apa saja yang diganti di bengkel (Oli, Rem, Busi, Kanz, dll) disertai nota pengeluaran dan tanggal.
- **Rekomendasi Cerdas Prediktif:** Merupakan sistem berbasis _Rule_ (Threshold). Misal: Oli disarankan ganti setiap 2.000 Km. Jika Odometer motor bertambah mencapai ambang batas 1.950 km, _Recommendation Service_ akan merubah status indikator menjadi Kuning (Mendekati peringatan) / Merah (Perlu Segera Diganti).
- **Hitungan Waktu (Bulan):** Jika motor lama tidak dipakai (jarak tidak bertambah), parameter waktu juga diuji (Misal: 3 Bulan tak ganti Oli, otomatis rekomendasikan Servis).

### 3.6. Literasi Otomotif (Tips Perawatan)

- Berisi _Repository_ atau perpustakaan digital tips dan trik merawat motor. (Menjaga keawetan Rantai, Mencegah Tangki Karatan, dll).
- Dilengkapi **Smart Tag / Hashtag Filtration Engine**. Memungkinkan pengguna cukup klik hashtag `#Busi` atau `#Suspensi`, maka semua artikel terkait akan tersortir dari backend.

### 3.7. Push Notifications Manager (Firebase Integration)

- Diinisiasi pada **Awal Aplikasi Berjalan** melalui fungsi `generateDeviceToken`.
- Aplikasi mengirim Token Unik (FCM Token) milik HP tersebut ke Server Laravel.
- Backend lewat _Trigger/Cron Job_ akan menembakkan sinyal ke Firebase Cloud Messaging (FCM). HP pengguna akan bergetar dan menampilkan _Pop Up Modal_ peringatan servis secara langsung (_Real Time_).
- Konfigurasi terbagi antara `OnMessage` (saat aplikasi dibuka terang) dan `OnBackgroundMessage` (saat aplikasi ditutup paksa / layar mati).

### 3.8. Personalisasi dan Lokalisasi Ekstra (Settings & Utilities)

- **Tema Terang & Gelap (_Light / Dark Mode_):** Sistem mampu beradaptasi dengan preferensi OS pengguna (System Default).
- **Multi-bahasa (_l10n / i18n_):** Implementasi modul `l10n.yaml` yang mensupport konversi teks langsung antara Bahasa Indonesia (ID) dan English (EN). Berguna bagi demografi pengguna yang luas.
- **Keamanan Data Pribadi:** Pengguna punya kapabilitas menghapus akun dan menghapus token secara permanen sesuai standar hak pengguna.

---

## 4. Aliran Skenario Pengguna (User Case / App Flow)

Saat menyusun diagram UML (Use Case, Activity Diagram, maupun Sequence Diagram), berikut skenario yang terjadi di sistem:

### 4.1. Skenario Booting dan Pengesahan (Initialization Flow)

1. User menekan icon Desktop HP. Menampilkan _SplashScreen_ dengan memuat `AuthStorage` di _background_.
2. Memeriksa keberadaan Token. Jika Token NULL atau rusak $\rightarrow$ Route ke Onboarding / Login.
3. User menginput Email & Password. `AuthService.login()` dieksekusi memanggil API `/api/v1/auth/login`.
4. Jika server merespon format 200 (OK), Token diselamatakan via `SecureStorage`.
5. Pendaftaran Device Token (Firebase) untuk Push Notifications disinkronisasikan ke Server.
6. Arahkan pengguna meluncur ke `Dashboard`.

### 4.2. Skenario Penciptaan Kendaraan (Vehicle Setup Flow)

1. Terdapat protektor: Jika motor pengguna masih `Kosong` (0 unit), beberapa menu otomatis ter-_Disabled_ (seperti modul _Tracking_ / _Trip_).
2. Dari Dashboard, pilih "Tambah Motor Utama". View form terbuka.
3. User mengisikan spesifikasi kendaraan (Bebek / Matic / Sport, Merek, Tahun).
4. `VehicleService.createVehicle()` memformulasikan Body JSON. Mendorong ke Database.
5. Motor sukses ditambahkan. Odometer awal didaftarkan di lokal dan di _Cache_. Semua layar (Dashboard, Navigasi) mendeteksi kehadiran motor ini (melalui Trigger _Future Builder_ Refresh).

### 4.3. Skenario Perjalanan Dinamis (Tracking Journey Flow)

1. Pengguna memutar kunci kontak motor dan membuka halaman _Tracking_ di App.
2. Memilih motor target (jika lebih dari satu). Menekan tombol **MULAI PERJALANAN (START)**.
3. Dialog Box OS muncul secara native meminta _"Allow access this device location? (While Using/All The Time)"_. Jika user menolak $\rightarrow$ _Abort_.
4. Jika diizinkan, API `Geolocator` dikaitkan (Bind) ke `ForegroundService`.
5. Indikator HP memunculkan ikon GPS menyala di jidat notifikasi. Stopwatch/Chronometer dan Speedometer Digital bergerak hidup.
6. Pengguna me-minimize aplikasi, layar dimatikan (Standby) dan menaruh HP dalam saku, melaju bersama motor. Modul akan konstan membisiki (`sink.add(coordinates)`) Stream ke Memori _Heap_.
7. Tiba di pabrik/kampus/tujuan, pengguna menekan **BENTIKAN (STOP)** di UI aplikasi.
8. Data lintasan (Polyline Long-Lat GPS) dan kalkulasi trigonometri otomatis dipaketin dan dikirim menembus `TripService.submitTrip()` ke server backend. _Response_ OK menutup perjalanan tersebut.

### 4.4. Skenario Pencatatan dan Peringatan Servis (Service & AI Detection)

1. Sehari seusai Perjalanan, Odometer di Server motor telah bergeser sebesar +250 KM.
2. Ketika User login kembali / Re-Open The App, Server Backend memproses _Rule Checks_ di latar belakang dan merespon status "Warning".
3. Firebase memicu sebuah Event: _Notification Alert_ (Ping!) berbunyi pada perengkat: "Busi Motormu Mendekati Usia Batas (250 KM tersisa)".
4. User membuka aplikasi. Beranda Dashboard menampilkan badge _Danger / Warning_ tentang Busi.
5. User pergi ke bengkel dan melaksanakan Servis.
6. Saat bayar nota servis bengkel, user mencatar Rekam Jejak (Create Maintenance Log) pada aplikasi dan mencentang opsi suku cadang "Ganti Busi".
7. Setelah Log ter-submit, Backend me-_reset_ ulang perhitungan ambang batas (Threshold) Busi motor ini berawal dari titik Odometer hari tersebut. Status "Warning" bersih.

---

## 5. Struktur Basis Data (Entitas Models di Aplikasi Klien)

Pengambilan data JSON ditangkap oleh serpihan direktori model yang sangat presisi dengan database Server. Adapun arsitektur Entitas dart-nya adalah:

- **`UserModel` (`user_profile_model.dart`):** Menyimpan UID unik, Email terenkripsi, nama layar, link potret, tingkat hak akses, stempel waktu, dan preferensi profil pengguna lainnya.
- **`VehicleModel` (`vehicle_model.dart`):** Berisi `id_vehicle`, referensi `user_id`, rincian spek pabrik motor, plat polis (No Pol), serta `current_odometer` (Akumulasi KM Total).
- **`TripModel` (`trip_model.dart`):** Model log catatan pelacakan. Parameter krusial adalah `start_time`, `end_time`, `total_distance` (float jarak tempuh), `max_speed`, serta array/list dari `LocationPoint` (Tiap array merekam korelasi koordinat GPS Latitude dan Longtidue dan _timestamp_).
- **`ServiceHistoryModel` / `RiwayatServis`:** Catatan bengkel, biaya pengeluaran Rupiah, jenis/kategori servis (Ban, Oli, Accu, Radiator, Busi, dsb), letak kordinat bengkel (opsional), hingga nota struk/foto kelengkapan, dan poin odometer pada saat servis tersebut dilakukan.
- **`ServiceScheduleModel` / `JadwalServis`:** Tabel virtual rekomendasi masa datang. Memberikan limit estimasi bulan kapan dan limit kalkulasi KM berikutnya harus melaksanakan sebuah perbaikan/ganti komoditas suku cadang.
- **`TipModel` (`tip_model.dart`):** Entity artikel untuk edukasi yang berisi _Title_, _Short Description_, Blok HTML _Body_, URL gambar sampul tip, serta _List of Strings_ HashTags pencariannya (Misal: `["Mesin", "Basah", "MusimHujan"]`).
- **`NotifikasiModel`:** Skema pesan riwayat masuk Firebase; Judul, Body, Status Baca (_Is Read_ True/False), _Payload_ jenis (Tipe 1: Umum, Tipe 2: Peringatan Jarak).

_(Catatan: Sebagian besar model memanfaatkan pustaka `json_annotation` dan kode bayangan `.g.dart` generatif, menghindari human-error dalam penterjemahan kamus key/pair JSON)._

---

## 6. Integrasi Teknologi, Pustaka Modul, dan Standarisasi Perangkat Eksternal Dasar

Sebagai rujukan untuk metodologi skripsi maupun riset penelitian, kerangka kerja perancangan implementasi sistem ini disusun dengan spesialisasi:

### A. Ekosistem Pokok (Core Engine)

- **Bahasa & Compiler:** _Dart versi 3.x+_ | Dikenal sebagai bahasa turunan C yang dikompilasi (AOT dan JIT) sehingga handal menjaga memori.
- **SDK Induk:** _Flutter SDK 3.19+_ | Ekosistem Cross-platform yang di-_compile_ memproduksi target Android ARM (AAB/APK) dan iOS XCode Bundle.

### B. Paket Ekstensi Utilitas (Dependencies Overview Package `pubspec.yaml`)

1. **HTTP Client (_http_ atau _dio_):** Gerbang antar-jaringan. Memastikan Headers Rest terpaket aman (CORS / HTTP Security).
2. **Foreground Location Core (`flutter_foreground_task`, `geolocator_android`):** Ini paket mutlak paling esensial dalam pengujian. Saat layar terkunci pada _OS Battery Optimization_ (Doze Mode), sistem Android secara natural bakal _Terminate_ thread RAM sistem GPS. Paket ini memaksa sebuah sub-worker sistem berstatus absolut (_Foreground_ Notification bar) sehingga kalkulasi sensor Lokasi terus-menerus bernafas.
3. **Database Kripto Lokal (`flutter_secure_storage`):** Menanam key Token AES 256 pada pilar keamanan OS yakni _KeyStore_ Android dan _Keychain_ iOS.
4. **Firebase Cloud Messaging (`firebase_messaging`, `firebase_core`):** Ekosistem jembatan penyebaran _Push Broadcast_ tersentralisasi. Digunakan sebagai penyulut _Alert_ yang berjalan walaupun Apps hancur.
5. **Localization API (`flutter_localizations` & `intl`):** Menjamin standarisasi Rupiah (`Rp 1.000.000,00`), Kalender waktu (`24 Desember 2026 14:00 WITA`), hingga perubahan translasi GUI Text (Localization).
6. **Code Generation (`build_runner`, `json_serializable`):** Mempersingkat fabrikasi (Boilerplate) konversi JSON menuju Entity Obejct Oriented (OOP).

### C. Proteksi dan Standar Keamanan Data (Security Compliance)

1. **Komunikasi Terenkripsi:** Mengandalkan jalur TLS/SSL pada akses HTTP backend (Misal harus `https://vps-server...`).
2. **Cegah Injeksi Penyimpanan:** Kredensial tidak pernah disimpan di _Shared Preferences_ konvensional yang mudah dicolong Root-Browser (Melainkan pakai KeyStore khusus yang butuh biometrik mesin virtual).
3. **Token Sesi Refresher:** Logika internal men-setting usia hidup JWT di Backend; klien wajib relogin / _RefreshToken_ kalau masa validasi berakhir.

---

## 7. Saran & Panduan Teknis Tambahan Untuk Skripsi Anda

Manfaatkan dokumentasi substansial ini dalam menjabarkan Bab III dan Bab IV pelaporan.
**Topik dan Rekomendasi Khusus Tambahan Pembuatan Gambar:**

1. **Diagram Alur Use Case Utama App (Aktor = Pengguna)**:
   - Pengguna $\rightarrow$ Validasi Login.
   - Pengguna $\rightarrow$ Membuat & Edit Data Motor.
   - Pengguna $\rightarrow$ Memulai Tracking \& Berjalan.
   - Pengguna $\rightarrow$ Selesai Tracking.
   - Pengguna $\rightarrow$ Menambah Log Servis.
   - Sistem Tiba-tiba Memberikan Notifikasi AI Peringatan $\rightarrow$ Pengguna merespons.
2. **Rancangan Antarmuka (Mockup Interface):** Jelaskan mengapa desain Anda menerapkan pendekatan Bottom Navigation dan Floating Action Button besar, karena mayoritas target audiens sedang menggunakan Motor dan butuh jempol besar yang intuitif.
3. **Pengujian Kinerja (Blackbox & Stress Testing):** Jelaskan secara khusus pengujian "Baterai vs GPS Foreground Service". Anda dapat mendemonstrasikan bahwa GPS yang menahan HP agar terus menyorot Satelit akan menguras persen Baterai.
4. **Analogi Layering Database MVC vs MVP vs Layer-Feature:** Sebutkan sistem _Flutter_ bagian Anda (di dokumen ini) bertindak sebagai Layer View dan sebagian Controllernya, di mana basis data sejati tetap bergantung pada Skema Relasional Laravel (RDBMS MySQL). Klien Flutter murni sebagai media representasi (Stateless/Stateful Presentation) belaka.
