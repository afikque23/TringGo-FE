const fs = require('fs');
const content = `# DOKUMENTASI SISTEM & IMPLEMENTASI: APLIKASI MOTORCYCLE MANAGEMENT

_Dokumentasi komprehensif ini disusun sebagai panduan utama (Master Guide) untuk penulisan Bab 3 (Perancangan Sistem), Bab 4 (Implementasi), serta Bab 5 (Pengujian) pada buku laporan Skripsi/Tugas Akhir._

---

## 1. DESKRIPSI UMUM SISTEM (SYSTEM OVERVIEW)

Aplikasi *Motorcycle Management* adalah platform berbasis mobile cerdas yang dibangun menggunakan framework **Flutter** untuk sisi terminal klien (Front-end), serta **Laravel (PHP)** sebagai infrastruktur *Backend* / REST API server. Sistem ini diciptakan khusus untuk membantu pemilik hingga pengelola kendaraan roda dua dalam memonitor kondisi kendaraan, merekam riwayat perbaikan, hingga merencakan jadwal servis atau peremajaan suku cadang (sparepart) secara tepat dan presisi.

### 1.1 Latar Belakang & Urgensi Aplikasi
Perawatan sepeda motor yang tidak teratur berisiko meningkatkan kecelakaan serta mempersingkat umur mesin kendaraan. Banyak pengguna roda dua kesulitan merawat secara berkala karena lupa batas kilometer yang ditempuh. Hadirnya aplikasi ini memberikan otomatisasi rekaman riwayat (_digital logbook_) sekaligus prediksi servis (Predictive Maintenance) berbasis Data Odometer Aktual.

Nilai tambah atau fitur unggulan yang menjadi daya tarik aplikasi ini:
1. **Pencatatan Servis Digital & Prediksi:** Menampilkan riwayat ganti suku cadang dan memprediksi/merekomendasikan servis berikutnya berdasarkan akumulasi kilometer tempuh aktual atau masa waktu bulanan.
2. **Background Location & Trip Tracking:** Melacak rute perjalanan (_Real-time Route Mapping_), menghitung jarak otomatis (Odometer sinkron), yang mana layanan ini mampu beroperasi secara independen di _Background_ meskipun layar dikunci (mengandalkan layanan GPS _Foreground Service_ dari Native Android Layer). 
3. **Edukasi Literasi Kendaraan:** Fitur _Tips Perawatan_ cerdas yang terintegrasi dengan filter pencarian instan (hashtag-based search).
4. **Notifikasi Pintar (Cloud Messaging):** Sistem pemanggil push notification terotomatisasi yang mengingatkan tentang perawatan kritis.

Aplikasi ini menargetkan kepraktisan operasi di mana pengguna memiliki akses terpadu (_All-in-One_) cukup melalui perangkat genggam (Smartphone).

---

## 2. ARSITEKTUR PERANGKAT LUNAK (SOFTWARE ARCHITECTURE LAYERING)

Sistem dirancang sedemikian rupa menggunakan pola arsitektur **Feature-First Architecture** dikombinasikan dengan prinsip **Clean Code (Separation of Concerns)**. Pengelompokan berkas (*codebase*) tidak didasarkan pada tipe file (semua view kumpul di direktori view, semua model kumpul di model), melainkan didasarkan pada domain fitur bisnisnya.

### 2.1 Struktur Modul Utama (Direktori \`lib/\`)
Pondasi utama aplikasi dibagi ke dalam dua penyangga: direktori \`core\` dan \`features\`.

#### A. Direktori \`lib/core/\` (Logika Inti & Fondasi Komunikasi)
Folder ini menampung seluruh infrastruktur dasar, kontrak integrasi, logika kontrol murni, model objek (Entity), dan modul API. Komponen UI (_User Interface_) dilarang keras diletakkan di sini.

1. **\`core/network/\`:** Bertindak sebagai jembatan pembentuk HTTP Client. 
   - Mengelola _Base URL_ secara global.
   - Penyelipan Header Otomatis (Injeksi Token Otorisasi _Bearer Headers_ pada semua *request* ke server).
   - *Error Handling Interceptor* untuk menangani terjemahan kegagalan koneksi (*Timeout, 401 Unauthorized, 500 Server Error*).
2. **\`core/services/\`:** Layer krusial pembentuk *Business Logic Component* (BLC). Ia memisahkan view dengan sumber data. 
   - *Backend Interactors:* \`auth_service.dart\`, \`vehicle_service.dart\`, \`trip_service.dart\`, \`service_history_service.dart\`. Mengatur rute URL spesifik serta konversi Payload/Response.
   - *Hardware/Native Interactors:* \`location_service.dart\` (mengelola _Request Permission_ GPS), \`notification_service.dart\` (Integrasi Firebase & Local notification), \`background_tracking_handler.dart\` (Tugas pelacakan titik di latar belakang).
3. **\`core/model/\`:** Skema representasi Data Transfer Object (DTO). 
   - Menerima struktur \`JSON\` mentah (Raw JSON) dari API.
   - Di-Serialize menjadi objek _Dart_ bertipe kuat (_Strongly Typed_) melalui sistem _code-generation_ dari pustaka \`json_serializable\` / \`json_annotation\`. File akan memiliki akhiran \`.g.dart\`.
4. **\`core/utils/\`:** Fungsionalitas serbaguna penyederhana logika presentasi. 
   - \`currency_formatter.dart\` (mengubah *Integer* menjadi konvensi Rupaiah, misal "Rp. 50.000").
   - Aturan warna/Tema universal (\`ThemeManager\`).
   - Translasi dwibahasa (\`LanguageManager\`).

#### B. Direktori \`lib/features/\` (Antarmuka dan Presentasi Per-Fitur)
Berisi seluruh antarmuka grafis (View Layer / Presentation Layer). Dipecah secara independen:
- \`auth/\`: Ekosistem Autentikasi (Halaman Login, Registrasi, Lupa Kata Sandi, Kode OTP).
- \`dashboard/\`: Dasbor Beranda (Rekap, panel speedometer motor).
- \`vehicle/\`: Modul manajemen armada (Tambah Motor, Edit, Hapus).
- \`tracking/\`: Layar _Maps_, navigasi, stopwatch pencatatan waktu/jarak perjalanan.
- \`servis/\` & \`recommendation/\`: Buku besar riwayat bengkel dan algoritma cerdas rekomendasi suku cadang.
- \`tips_perawatan/\`: Buku manual/Katalog artikel merawat kendaraan roda dua.
- \`profil/\` & \`settings/\`: Pusat kontrol pengguna pribadi dan modifikasi tema global.
- \`notification/\`: Inbox (Kotak Masuk) notifikasi masuk untuk dibaca kembali nantinya.
- \`onboarding/\` & \`splashscreen/\`: Gerbang awal perkenalan aplikasi pada pengguna awam (New User Introduction).

### 2.2 Pola Aliran Data & State Management
Siklus pergerakan data merujuk pada arus bolak-balik Request-Response:
1. **View (UI):** Komponen tombol UI (Tapped) $\\rightarrow$ memicu *Controller/Service Function*.
2. **Service (BLC):** Mengirimkan beban paket data ke kelas _Networking_ (HttpClient).
3. **Network (HTTP Client):** Melintasi internet menghubungkan Server.
4. **Server (Laravel):** Menanggapi permintaan lalu melontarkan JSON mentah.
5. **Model (Data Layer):** JSON dikonversi ke Class Entity.
6. **Re-Rendering:** Layar (UI) menangkap objek tersebut dan menggambar ulang layar memakai \`setState()\` atau \`FutureBuilder()_\`.

Aplikasi ini secara murni memaksimalkan **Native Flutter State (\`StatefulWidget\`, \`FutureBuilder\`)** dipadukan dengan metode *Dependency Injection* primitif via Konstruktor. Untuk _global state_ seperti pergantian opsi Gelap/Terang (Dark Mode) atau pergantian bahasa, menggunakan \`InheritedWidget\` bawaan Flutter.

---

## 3. PENJABARAN FUNGSI & MODUL LENGKAP PADA APLIKASI

Penjabaran rinci fungsi subsistem yang ditujukan pada Bab 4 (Implementasi Subsistem), meliputi:

### 3.1. Autentikasi dan Manajer Identitas (Auth & Profile Ecosystem)
Subsistem pertama yang menjadi palang pintu validasi. Tanpa melewati ini, pengguna dihalau *Role-Based Access Control*.
- **Login Ekosistem:** Proses validasi kredensial (Email & Password). Jika sukses, server mengembalikan **JWT (JSON Web Token)**. Token ini akan dikunci dan dienkripsi di perangkat penggguna berkat bantuan paket \`flutter_secure_storage\`.
- **Register Account:** Pendaftaran akun baru. Menggunakan validasi antarmuka _(FormBuilder)_ yang mengetes standar keamanan password (huruf kapital, angka) dan pola email valid (_Regex Validation_).
- **Lupa & Reset Kata Sandi:** Fitur pemulihan (*Forgot Password*) dengan sistem autentikasi OTP *(One-Time Password)*. OTP dikirim melintasi email backend (SMTP), lalu dimasukkan ke dalam aplikasi klien untuk membuka blok layar _Change Password_.
- **Manajemen Profil:** Membuka informasi personal, memperbarui detail nama layar, nomor HP lokal, atau avatar pas foto. 
- **Auto-Logout Mechanism:** Sistem juga mengelola sinkronisasi sesi via Interceptor. Jika server menjawab dengan \`401 Unauthorized\` (Token Daluswarsa/Banned), maka interseptor akan otomatis mendepak navigasi layar kembali ke *Login Page* secara darurat.

### 3.2. Dasbor Analitik (Breeze Information Center Dashboard)
Halaman persinggahan sentral, didesain merangkum entitas penting secara makro (Keseluruhan). Layout meliputi:
- **Motorcycle Highlighter:** Manampilkan motor utama (Primary Vehicle) lengkap dengan blok plat nomor (License Plate), merk dagang, dan akumulasi total odometer saat ini (angka kilometer terus bertambah progresif).
- **Red-Alert Service Badges:** Menampilkan notifikasi peringatan gawat (Badge merah) jika ada part/item servis (misalnya, Kampas Rem) yang tenggatnya nyaris habis.
- **Top Metrics Statistic:** Panel yang meringkas informasi seberapa banyak perjalanan yang ditempuh minggu-minggu ini sebagai refleksi aktivitas pengguna.
- **Quick Actions Menu:** Tombol melingkar (_Floating shortcuts_) cepat untuk Start Tracking atau Lihat Daftar Bengkel.

### 3.3. Manajemen Inventaris Kendaraan (Vehicle CRUD System)
Modul untuk mencatat dan membongkar kepemilikan struktur kendaraan agar satu akun bisa mengakomodir banyak motor tanpa tumpang tindih.
- **Registrasi Motor (Create):** Menginput kategori mesin (Bebek / Matic / Manual Listrik / Sport), Merk Pabrikan, Tipe Varian, Tahun Produksi, Plat Nomor Motor, nomor rangka, hingga Odometer fisik awal pada spedometer motor sebenarnya.
- **Opsi Konfigurasi "Motor Utama":** Karena profil mengakomodasi $>$ 1 motor, aplikasi membutuhkan penanda bendera (Flag). Sistem "Set as Default" mengunci salah satu motor ke Dashboard. Semua perjalanan via GPS Tracking nanti, jarak tempuhnya akan dicatat masuk ke Odometer motor utama (yang menyala per-sesi).
- **Modifikasi & Penghapusan:** Pengeditan spesifikasi jika pengguna menjual atau memasang part khusus (Update/Delete).
- **Sinkronisasi Offline (Caching):** Daftar profil motor akan disinkronisasikan perlahan pada _Local Storage_ gawai. Tujuan utamanya agar beranda Dashboard tidak macet/kosong seketika koneksi sinyal memburuk (Lost Connection) di jalanan minim sinyal.

### 3.4. Pelacakan Trajektori Perjalanan (_Tracking / Foreground GPS Trip_)
Aspek paling kompleks di dalam skripsi yang mewajibkan keahlian perangkat keras (Hardware I/O). Algoritma harus tahan banting meski aplikasi di-_minimize_.
- **Sistem Perlindungan Memori Android (_Foreground Service_ Android):** 
  Manajemen OS kekinian (Android 10+) lazim membunuh aplikasi (Kill Process) di latar belakang demi menghemat baterai (_Battery Optimization / Doze_). Modul ini diatasi dengan \`BackgroundTrackingHandler\` dan \`flutter_foreground_task\` yang mengorbitkan _Persistent Notification Bar_ (Kotak notifikasi tak bisa di-_swipe_ gampang pada Notification Tray) sehingga Linux Kernel tidak akan men-_terminate_ thread GPS aplikasi selagi berjalan.
- **Catcher & Polling GPS (Real-time Interval):**
  Sensor geolokasi akan secara periodik "di-ping". Apabila akurasi radius $<$ 20 meter, titik X (Latitude) dan titik Y (Longitude) disimpan dalam *Cache Array*. Titik demi titik tersebut menyatu jadi kumpulan lintasan (_Polyline_).
- **Komputasi & Translasi:** Rumus Haversine Distance (Atau Native location bearing) dipakai mengukur jarak dari titik A pada t=0 detik ke titik B (m) pada t=n detik, diakumulasi sejalan dan ditambahkan variabel kecepatan (*Velocity/Pace*).
- **End-Of-Trip Submission:** Saat user menekan tombol **SELESAI (STOP)**, proses pembacaan sensor dimatikan (Stop Stream Listener). Payload lintasan utuh, waktu tempuh akhir, kecepatan rata-rata direkonstruksi jadi JSON Payload POST untuk dilemparkan ke Backend. Berakibat: Angka Odometer bertambah sukses.

### 3.5. Buku Besar Riwayat Servis & Algoritma Rekomendasi 
Sub-komponen ini berfungsi mencegah kecerobohan pengguna terhadap *Lifetime* sebuah suku cadang (Sparepart).
- **Form Perekaman Log Servis (Maintenance Activity):** 
  Borang digital tempat menginput histori ganti OLI GARDAN, Busi, V-Belt, Rantai, Ban, Kampas Rem. Terdapat pengunggahan nominal (Rupiah dikeluarkan) serta gambar bukti nota (Bill/Receipt Picture). Odometer pada hari H dilampirkan menempel pada rekam jejak.
- **Rekomendasi Cerdas Prediktif (Rule-Based Expert System):**
  Merupakan sistem pintar kalkulatif. Misal: Kebijakan ganti Oli Mesin direkomendasikan pabrikan per-2000 KM. Aplikasi merekam bahwa pergantian terakhir terjadi di ODO *16.000 KM*. Maka *Lifetime Threshold* adalah *18.000 KM*. Saat fitur *Tracking/Perjalanan* menambah ODO motor mencapai *17.850 KM* (Sisa < 150 KM lagi). Modul *Recommendation Service* akan menyambar _Trigger_ lalu berubah dari status "AMAM/BAIK" ke status *WARNING (KUNING / MERAH)*. Memberitahu: **"Sebentar lagi waktunya Ganti Oli"**.
- **Ambang Batas Bulanan (Time Limit Threshold):** Sistem tidak hanya mengandalkan perhitungan jarak jalan. Boleh jadi ODO tidak bertambah drastis karena motor *nganggur/parkir lama*, tetapi struktur kimia pelumas memburuk jika jarang diganti $>3$ Bulan. *Chron Job Backend* maupun komparator Timestamp di aplikasi mampu mengevaluasi kalkulasi waktu ini serentak dan menggulirkan _Warning_ peringatan bergegas servis.

### 3.6. Enseklopedia Literasi Otomotif (Tips Perawatan)
- Pusat literatur pengetahuan mandiri dalam mendalami teknik memelihara mesin. Semua modul _Blog/Artikel_ ditarik dari Backend CMS yang berisikan informasi ringan, misalnya: *"Kenapa Motor Matic Suka Brebet Pagi Hari"*.
- **Smart Tagging / Hashtag Filtration Engine**. Algoritma pencarian super-efisien. Ketika layar merender puluhan tips, dan pengguna mengetukkan jempol atau mengeklik badge \`#V-Belt\`, seketika aplikasi memanggil algoritma filter (_Array filter_) atau permintaan Query (\`?tag=V-belt\`) untuk menciutkan dan mensortir artikel paling relevan saja. 

### 3.7. Manajer Push Notification Pintar (Firebase Core Integration)
Fasilitas peringatan mutlak agar aplikasi menembus notifikasi secara instan (Real-time Live Alert) tanpa harus nge-_refresh_ aplikasi (Pull to refresh).
- Pada saat fase **Inisialisasi (Splash Screen Success)**, \`Firebase_messaging\` mengeksekusi \`getToken()\`. 
- Gawai (Handphone Android) merespons dengan ID Kripto (Registration Device Token) super panjang. Kode Device tersebut dilempar simpan ke Database User Backend.
- Lewat sebuah penjadwal cron di sisi server, misal ditemuka bahwa Odometer User X sudah meledak, Backend menembakkan peringatan ke API Node Google Firebase.
- Firebase melanjutkan pesan Payload menembus langit menuju Handphone. Handphone akan bergetar dan membunyikan _Ring Tone_ notifikasi peringatan. (Misal Box berbunyi: *"Awas! Odo Motor Supra-X-mu tembus limit ganti Oli Gardan!"*).
- Logic \`OnBackgroundMessage\` ter-implementasi, di mana pengguna tetap bisa disuguhkan pemberitahuan walaupun aplikasi sama sekali sedang tak dibuka.

### 3.8. Personalisasi UI dan Lokalisasi Ekstra (Settings & Utilities)
Meningkatkan skala kelayakan User Experience aplikasi melalui sentuhan kosmetik komplit.
- **Tema Gelap & Terang (_Light / Dark Mode_):** Aplikasi diprogram mewarisi opsi `ThemeData().dark()` & \`ThemeData().light()\`. Fitur pendeteksi mampu mengadaptasi langsung secara sistem (System Default OS Toggle) tanpa pengguna repot beralih manual. Berguna untuk efisiensi proteksi layar OLED di malam hari.
- **Multi-Bilingual (_l10n / i18n_):** Perombakan teks antarmuka (*String Translations*). Merujuk integrasi fail \`l10n.yaml\` serta \`untranslated_messages.json\`. Menyediakan fitur saklar ganti Bahasa *Indonesia ID* ke *English EN* sesaat yang terkonfigurasi dinamis untuk jangkauan target publik/pasar Go-International.
- **Akun & Penghapusan Data Tunggal:** Menggenapkan pakem privasi GDPR (General Data Protection Regulation), di mana user diberkahi ruang bebas permohonan "Hapus Rekap Ekstrem (Delate My Account)" apabila enggan berlanjut menggunakan platform.

---

## 4. ALIRAN SKENARIO PENGGUNA (USER CASE / APP ACTIVITY FLOW)

Pada perancangan _UML Diagram_ (Bab Perancangan Sistem), aliran sistem diterjemahkan sebagai berikut:

### 4.1. Skenario *Booting* Otomatis (Initialization Flow)
1. User menyentuh logo aplikasi pada Launcher Android. Halaman *SplashScreen* statis diangkat pertama kali.
2. Sesuai arsitektur, \`AuthStorage\` disuluh pada detik pertama melakukan pengecekan ruang di _Secure Storage_ gawai. "Adakah Token tersimpan?".
3. Jika NULL atau `JWT Format Invalid` $\\rightarrow$ Mengalihkan ke Halaman Presentasi (Onboarding / Halaman Login).
4. Jika \`UserEmail\`,  \`Password\` berhasil diverifikasi pada Login melalui REST POST \`/api/v1/auth/login\`. Token ditahan aman, status App State masuk ke Authenticated.
5. Inisiator Firebase mengaktifkan modul notifikasi di _Background_. 
6. Halaman beranda *Dashboard* merilis sinyal \`initState()\` pertamanya.
7. Modul GET API di-Panggil (Menarik ringkasan Profil dan Profil Kendaraan Peringatan Servis Utama) secara serentak (Parallel API Calls).

### 4.2. Skenario Inisiasi Kendaraan Pilihan (Vehicle Setup Flow)
1. Modifikasi mitigasi sistem: Terkunci (Disabled button). Menu utama navigasi (Trip Mapped Tracker) dibekukan seandainya pengguna terdeteksi tidak punya motor sama sekali di dalam log garasinya.
2. Dari Menu _Grup Kendaraan_ / _Dashboard_, tekan CTA Tombol "Tambah Sepeda Motor".
3. Form pendaftaran terbuka. Form memaksa input absolut: Merk Kendaraan $\\rightarrow$ Motor Tipe Kendaraan $\\rightarrow$ Tahun Perolehan $\\rightarrow$ Plat Depan / Belakang $\\rightarrow$ KM Awal Motor per hari itu (Base Ground Zero Odo).
4. Tombol *Save/Register* menekan metode \`VehicleService.createVehicle()\`. Payload diwujudkan menjadi balikan kompresi Format JSON.
5. Pendaftaran lulus respons Kode API 201 (Created). Kendaraan nampang di list.
6. User Men-Tapping salah satu plat kendaraan lalu menggeser opsional: Menekan Menu konteks (Tiga Titik) lalu memilih **"Jadikan Kendaraan Utama"**. (Global Odometer Switch Activated).

### 4.3. Skenario Operasional Pelacakan Perjalanan GPS (Tracking Journey Flow)
1. Sang Pengemudi (Rider/User) menaiki motor aslinya. Mempersiapkan _Mounting Handphone_. App dibuka menuju laman `Tracking / Catat Perjalanan`.
2. Menu mendeteksi Motor yang ter-*bind* pada sesi hari ini. Menekan tombol raksasa **MULAI PERJALANAN (START)**.
3. Box Dialog Validasi OS bawaan melayang: _"Allow access this device location? (While Using/All The Time / Only This Time)"_. Jika perizinan (Permissions) mangkir $\\rightarrow$ Fitur langsung di-Suspend (Error Not Granted).
4. Jika disetujui (Granted Permission), aplikasi memberi aba-aba koneksi \`ForegroundService\` kepada sistem operasi.
5. Ikon khusus GPS tampil berkelip di Notification Bar (Tray HP Teratas) disertai notifikasi gigih berbunyi "Mencatat Rute Perjalanan...".
6. Di Layar Aplikasi: Odometer digital, Stopwatch Hitung Waktu (_Timer Gauge_), dan Indikator Kecepatan melompat merender posisi titik nol dan berjalan konstan (Listen Coordinates via Stream).
7. Handphone di-_minimize_, diburamkan Layar _Sleep_-nya dan masuk saku sang Pengemudi. Operasional mesin tidak terpengaruh, GPS mendulang angka Latitude dan Longitude secara senyap.
8. Setiba di destinasi akhir: User membentangkan HP lalu menakan tombol **SELESAI KETIK KE-TRIPP (STOP)**.
9. _Data Aggregator_ membungkus utuh semua titip kordinat lintasan yang terkumpul dan angka komputasi jarak akhir (misal Total = 18.5 Kilometer, waktu lewat 24 Menit).
10. Payload raksasa dilesatkan (\`POST Method\`) melayang memanggil \`TripService.submitTrip()\`. Response server 200/201 (Success) membikin Odometer Dashboard seketika memanjat + 18.5 KM tambahan.

### 4.4. Skenario Kepatuhan Servis Komponen (Service Cycle & Warning Detection)
Menciptakan siklus (Loop) algoritma terpadu kecerdasan buatan penentuan perbaikan.
1. H+2 Sebulan Penggunaan: Angka Total Odometer di Database server untuk Motor Plat A telah menyorong menyentuh 17.500 KM bertukar +800 KM.
2. Pada setiap _Request Get Dashboard_, sistem algoritma Rule-Engine Backend ataupun Frontend \`RecommendationService\` menyebrangi limit jarak komponen Busi (Busi masa berlaku pabrikan adalah 8.000 KM terakhir). Sejarah (Log) sebelumnya membuktikan terakhir penggantian sewaktu angkanya masih  (09.200 KM  + Masa = 17.200 KM Batas Jisim). Angka sekarang 17.500 KM $>$ 17.200 KM. LIMIT JEBOL!
3. Firebase memicu sebuah Letusan (Fire-Trigger). Alert Broadcast: *Notification App* (Ping!) berbunyi di gawai: **"Urgent! Limit Busi Motormu Terlampaui (OVERDUE: 300 KM) Ayo Ganti!"**.
4. Label _Widget List_ Beranda di Aplikasi (Dashboard) menyala MERAH total.
5. User, akibat takut mesin bermasalah, menyempatkan kunjungan teknis di Bengkel resmi merubah Part tersebut.
6. Berbalik di rumah, pengguna menekan panel *Pencatatan Sejarah (Service Book) $\\rightarrow$ Buat Entri Baru $\\rightarrow$ Tanggal Terkini $\\rightarrow$ Harga IDR: 25.000 $\\rightarrow$ Filter Komponen terpilih ke Busi $\\rightarrow$ Potret (Upload Struk Camera) $\\rightarrow$ Simpan (Submit).*
7. Setelah Log ter-submit rapih ke server (\`ServiceHistoryService\`). Hitungan masa kadaluwarsa titik jenuh khusus entitas Busi di-_reset_. Busi di-stempel bersih, dan angka threshold dipindah pergerakannya menantikan di target 25.500 KM (Ambang Masa Depan). Notifikasi merah di dashboard bersih dan lenyap menghilang.

---

## 5. STRUKTUR BASIS DATA DI KLIEN (DATA MODEL & ENTITIES OBJECT DART)

Guna mengeleborasikan integrasi dari basis data relasional server ke perangkat Client Flutter, representasi JSON tersebut dikaruniai penampang pola desain DTO (_Data-Transfer Object_) sebagai berikut (Dikerangkai dalam direktori Model):

- **UserModel (\`user_profile_model.dart\`):** Profil dasar sang pengendara. Menyimpan _UID/UUID_ unik identifikasi, \`email_adress\` pribadi, \`display_name\` (Nama Publik sapaan), Tautan URL resolusi foto (\`avatar_picture_url\`), hak akses status (\`user_role_authorization\`), tanggal bergabung terdaftar sistem (\`joined_at\`), dan saklar opsi pemberitahuan.
- **VehicleModel (\`vehicle_model.dart\`):** Unit instrumen armada tempur roda dua. Atribut kuncinya mencakup pengenal unik tabel \`id_vehicle\`, merujuk Foreign Key si pemilik \`user_id_fk\`, Teks Deskripsi (Brand Vario, Supra, PCX), Spesifikasi volume CC (\`engine_capacity\`), dan yang paling maha penting: \`current_dynamic_odometer\` (Posisi KM Final Saat Ini - Float Double yang berubah terus-menerus tiada henti).
- **TripModel (\`trip_model.dart\`):** Cetak gol dari log pelacakan jelajah. Skema ini berisikan meta:  \`session_start_time\` (ISO8601 Timestamp Jam Berangkat), \`session_end_time\` (Jam Sandar Akhir), Metrik Float Akhir (\`total_cumulative_distance_km\`), Cap Kecepatan Klimaks Maksimum \`top_speed_parameter\`, serta Entri Array JSON Objek berjenjang dari \`LocationPoint\` (Sisa tapak jejak garis kordinat vertikal (Lat) menembus paralel (Lng) setiap ketukan langkahnya).
- **ServiceHistoryModel / RiwayatServis (\`service_history_model.dart\`):** Bongkahan arsip transaksi riwayat di bengkel terpusat. Melampirkan \`service_invoice_id\`, biaya modal tagihan terkapitalisasi (_Nominal Rupiah Price_), kategori tipe spesifik suku bagian (_V-Belt, Coolant Radiator, Oli Mesin SAE_ dll), letak geolokasi map bengkel saat itu, bukti digital upload Struk Kamera Lampiran File JPEG, dan tak lupa rekaman angka stempel KM odometer _Saat Entri Tercatat_.
- **ServiceScheduleModel / JadwalServis (\`service_schedule_model.dart\`):** Representasi kalkulator prediksi mesin kecerdasan semu sederhana. Output yang didapatkan berparameter: Estimasi limit perkiraan bulanan penanggalan (\`next_service_month_date\`) dan kalkukasi agregasi poin rentang KM (\`next_point_kilometer\`), dengan menyoroti varian khusus suku cadang itu saja (Tenggat/Tolerance Threshold Marker).
- **TipModel (\`tip_model.dart\`):** Lembar digital artikel koran edukasi teknis. Berinti \`author_tip_title\` (Cetak Judul), \`short_desc_preview\` (Sekilas Pembukaan), Lembar Panjang Hypertext \`content_html_body\` yang diterjemahkan \`flutter_html\`, URL _Banner Cover_, serta Himpunan List (Senarai) kata kunci pintar \`hash_tags\` pencarian kilat (Misal: \`["Mesin", "Basah", "MusimHujan"]\`).
- **NotifikasiModel (\`notifikasi_model.dart\`):** Skema data yang mengekor arsip lonjakan ping dari _Firebase Message Cloud Logger_. Skema: Judul Pokok Alarm, Pesan Paragraf, Penanda Bool (\`is_read\` True/False sebagai Red Dot unread indicator), serta _Payload Category_ jenis kasta (_Priority Level: General 1, Caution 2, Dan Warning Distance 3_). 

*(Catatan Fundamental: Karena sistem dipenuhi atribut tipe panjang (Long Int) dan variabel spesifik (Snake-case di Backend vs Camel-case di Dart), mayoritas model dikukuhkan sepasang dengan ekstensi `.g.dart` melalui pabrik pustaka \`json_annotation\`, mencoret jauh celah galat (Null Safety Exception / NPE Error) saat dekoding manual pemetaan key JSON).*

---

## 6. INTEGRASI EKSTRINSIK & STANDAR PEMINJAMAN PUSTAKA DOKUMENTASI LENGKAP (LIBRARY & NATIVE)

Dalam lingkup akademis dan pengayaan persembahan skripsi ini memfokuskan pengerjaan Bab 4 ke implementasi teknis tingkat menengah lanjut. Di bawah ini adalah pustaka komponen pembangun pokok yang paling fundamental (Menarik pada `pubspec.yaml`), menunjang kapabilitas hulu (Platform Integrations) menuju arus hilir kerja (User Layer) sistem aplikasi (Sematkan ini pada tabel keterkaitan Bab Bab Anda):

### A. Ekosistem Lingkungan Mesin Pokok (Core Runtime Engine)
- **Komponen Linguistik (Language & Compiler):** Mengadopsi Bahasa *Dart Versi Mutlak (3.x ke atas)* | Dipuja atas fitur kompilasi ganda (_AOT/Ahead-Of-Time_ ke ranah final rilis dan _JIT/Just-In-Time_ penunjang debug cepat _Hot Reload_). Ditambah pemerkayaan sintaks _Null Safety_ paripurna (Ketegasan pencegahan memori hancur gara-gara Null References Variable).
- **Kerangka SDK Induk Terapan Utama:** *Google Flutter SDK Versi (Setidaknya Generasi 3.19.0 ke atas)* | Konstruktor _Cross-platform engine widget_ yang di-_compile/Render_ menembakkan target instruksi kode grafis Skia/Impeller Canvas memproduksi berkas biner spesifik Arsitektur _Android ARM/AAB/APK_ dan Eksekusi mesin _iOS XCode IPA Bundle_.

### B. Daftar Paket Dependensi Strategis Terhadap OS (Utilities & Plugins External)
Penjabaran berikut merujuk pada alat ukur penunjang fungsional wajib:
1. **Penggerak Jaringan (HTTP Client - \`http\` & \`dio\` dll):** Gerbang transmisi antarmuka komutasi (Internet API). Menjamin asimilasi Headers yang patuh, *Handling HTTP REST Status Code Standard Protocol* dan mengemas String Response berwujud format _jsonEncode/jsonDecode_.
2. **Foreground Location Engine Core (\`flutter_foreground_task\` dikawin-silangkan dengan \`geolocator_android\`):** Kepingan blok fungsional pamungkas mutlak yang jadi jantung paling unik dari pengujian Sistem Inovasi Proyek Aplikasi Ini.
   - Tanpa ini: Saat layar diredupkan (_OS Battery Optimization/Doze Mode Sleep_), kernel OS Android akan serta alamiah langsung membantai habis proses _Thread Socket GPS_ dari RAM (Force Killed System App). Perjalanan Anda berhenti total meski baru dua kilometer lewat.
   - Dengan ini: Ia memaksa mencabut otorisasi Sleep OS, menjalankan mode sub-worker sistem berstatus "Ber-Tahta di Atas Segalanya". Melemparkan notifikasi tetap ber-_badge_ (_Persistent bar_) sebagai tumbal bahwa "Tolong Ya OS, Kasih saya nafas, Sensor Lokasi lagi butuh berjalan!". Maka hitungan Odometer selamat tiada rintangan!
3. **Database Kripto Rahasia Lokal (\`flutter_secure_storage\`):** Mengandalkan metode penyimpanan String lokal memori ponsel gawai namun dipersenjatai metode hash-key asinkron dekripsi berlapis ke platform lapisan keamanan tingkat tinggi di OS terbawah, yakni menempatkan Kredensial *User Session Token Web* langsung melesak membaur terintegrasi _KeyStore API System_ rahasia berbiometrik (Untuk Android OS) juga terpatri ke sandi _Keychain Ecosystem_ gembok baja (Untuk varian rilis iOS MacOs). Sandi Token anda sangat aman walau memori di hack via kabel Laptop MTP.
4. **Firebase Cloud Messaging System Notifier (\`firebase_messaging\` & \`firebase_core_plugin\`):** Portal perpanjangan jembatan sebaran notifikasi pemberitahuan berbasis (_Cloud Push Broadcast Topic Distribution_). Tidak usah ribet melipir nunggu aplikasi dibuka terlebih dahulu; Server Backend hanya butuh tembak payload JSON pada mesin Node Firebase jarak jauh, Firebase menyengat masuk menginformasi alarm ke ponsel meski si User sedang seru bermain aplikasi TIK-TOK! Modul krusial Peringatan Servis Rem Rantai Motor seketika terwujud elegan.
5. **Localization Translating Format APIs (\`flutter_localizations\` & \`intl\` ekspor):** Alat serbaguna pengonversi penyesuaian konvensi zona teritori. Mulai pemaksaan format Standar Rupiah Koma (\`Rp 150.000,00\` dari teks mentah IDR \`150000\`), Kalender format huruf ejaan benua (\`Rabu, 24 Desember 2026, Pukul 14:00 WITA\`), hingga kemampuan pergantian otomatis bahasa text antarmuka UI teks (Contoh: Menekan Setting lalu berganti `Dashboard -> Beranda`, \`Add Trip -> Catat Ekspedisi\`, dll).
6. **Code Boilerplate Generator Mechanism (\`build_runner\`, \`json_serializable\` compiler):** Pekerja kasar tak kasat mata bagi penguji. Cukup deklarasikan variabel kosong yang diikat anotator (`@JsonKey(name:...)`) via skema struktur \`.dart\`, lalu eksekusi di latar cmd. Jutaan baris skema rumit akan tercetak ajaib memendekkan fabrikasi rilis (Konversi baris raw JSON menuju Entitas Obejct Oriented (OOP) siap dikunyah _frontend Developer_).

### C. Protokol Pelindung serta Standar Keamanan Data Sensitif (Security Standards Compliance Policy)
Guna mengatasi kecematan _Security Review_, terapkan prinsip pada Skripsi Analisa:
1. **Komunikasi Jalur Sutra Terenkripsi:** Mewajibkan semua gerbang panggilan End-Point (API URI) wajib diliputi gembok jalur TLS/SSL (Lapisan Letak di `https://api.vps-server...`). Segala interupsi jaringan Wi-Fi umum via *Packet Sniffing / Man In the Middle Attack* terhadap password akan mendapati String sandi teracak silang yang mustahil dikurai seketika di perbatasan Gateway.
2. **Token Refreshing Sinkron System:** Sistem logika server menabur ranjau batas Expired hidup dari sesi JWT. Maksimal token berlaku pendek rentang X jam sehari, jika batas kedaluwarsa dilewatinya. Endpoint App Client akan meneteskan air mata \`Response 401 UNAUTHORIZED\`. Dan _Interceptor Dart Networking_ mendeteksi ini, menenggak pil pahit memaksa halaman *Route.off All!* di depak keluar untuk log-in manual mencabut celah otorisasi permanen hantu HP tercuri.
3. **Validasi Permukaan Input UI Frontend Cegah DDOS:** Form textfield tidak memperbolehkan inject teks kotor (\_Regex Protection Block\`). Hanya bisa huruf, larang titik tanda petik khusus (Meredam XSS / Injection SQL dari Frontend). Dan fitur pendaftaran mengaborsi submit request dobel jika sedang Loading (_Disabled Status State Button API_) menghindari server terbombardir oleh Spam klik anak kecil jutaan hits mili-detik.

---

## 7. SARAN TATA CARA MERAMU / PANDUAN TEKNIS TAMBAHAN PENULISAN DAFTAR PUSTAKA SKRIPSI ANDA (BAB PEMBAHASAN)

Manfaatkan dokumentasi substansial Master yang tebal panjang nan sangat memikat ini, dalam merajut dan menjabarkan rincian kerangka alur di Bab III Perancangan, dan Bab IV Pelaksanaan (Implementasi), dan Bab V (Pengujian App Tesis) pelaporan buku tebal milik Saudara.
**Saran Poin-Topik serta Rekomendasi Khusus Ekstra Perancangan Kerangka Pola Pikir (Insight Ideasi Konsep Gambar / Sub Bab):**

1. **Dinamika Diagram Alur *Use Case / Activity Flow* Sang User Aktor Mutlak**:
   Siapkan bagan interaksi _Actor-System Boundaries_. Gambarlah secara mendalam titik kontak berikut di kertas/Canvas _Draw_IO/StarUML_ dengan pola percabangan alur logika sistem dari penjabaran Dokumen Ini:
   - Pengguna $=>$ Terjangkau Panel Validasi Login/Registrasi dan Forgot Token Sandi.
   - Pengguna $=>$ Proses Create (Pendaftaran Spesifikasi Rinci), Edit (Pembaruan KM Manual), dan Delete Unit (Mobil/Motor).
   - Pengguna (Dengan status HP tergenggam Mount Holder) $=>$ Menu Tracking Perjalanan, Validasi Intervensi Izin Permission Android $=>$ (Bypass Sistem Layar Terkunci Background Mode) $=>$ Polling GPS Detik $=>$ Menyetop Trip $=>$ Validasi Angka Kenaikan Jarak.
   - Pengguna $=>$ Menambal Arsip Struk Pembayaran Entri Catatan Eksternal Servis Bengkel Offline.
   - Sistem Tiba-tiba Melontarkan *Asynchronous System Push Notifikasi Alert Rule Engine Jarak/Waktu Mesin* $=>$ Loncatan Balik Halaman dari Notif $=>$ Pengguna merespons dan membaca log Notifikasi itu.

2. **Gagasan Dasar Rancangan Antarmuka Grafis (Mockup GUI System Concept):** 
   Tuliskan saja narasi kuat mengapa desain Aplikasi Saudara menerapkan tata kelola susunan layout navigasi seperti panel menu melengkung bawah (_Bottom Navigation Bar UI_) dan posisi tombol besar mencolok warna tebal aksi bundar Floating (_Big Floating Action Button CTA_). Argumen Logis yang dipaparkan adalah "Aplikasi disasarkan spesifik khusus mayoritas demografi audiens pengendara Kendaraan Roda Dua, yang ketika tengah di perjalanan, memegang Handphone terparkir di setir _Holder Phone Grip_, mewajibkan ketebalan sentuhan tombol interaksi yang luas, lega agar ibu jari sarung tangan pengemudi sanggup menge-klik tanpa selip salah sentuh/Tepo meminimalisir kekacauan bahaya pandangan di aspal yang tak rata". Hal ini murni memenuhi prinsip standar **User Experience Design Ergonomics (Human Computer Interface)** yang baik.

3. **Urgensi Pengujian Kinerja (Performa Skala Besar Blackbox Testing & Stress Real Testing):**
   Dedikasikan satu sub-bab utuh nan megah di skripsi pada segmen Pengujian "Impact Analisis Baterai HP versus Ketahanan Pelacakan GPS Foreground Service Background OS". Anda dapat memotret demo grafis tangkapan layar HP (_SS Settings Battery Usage Android_) bahwa sensor modul GPS yang menahan HP agar terus menyorot sinkron koneksi titik rasi Bintang Satelit Bumi secara agresif setiap lima menitan, akan diproyeksikan menguras prosentase arus Ampere Baterai (misal HP kehilangan 10% Kapasitas sesudah Dua Jam perjalan Touring Keluar Kota 50 KM Mode Menyala Tertutup Layar). Demonstrasi ini membuktikan secara rasional realibilitas logika ketangguhan Aplikasi yang bertahan hidup tiada tertindas oleh kejamnya _Deep Sleep Mode System Linux Android_, sebuah prestasi penemuan skripsi terapan berbasis Native Hardware Hardware GPS Sensor yang layak diganjar Nilai Mutlak yang amat Sempurna, sebuah karya rekayasa mutakhir!

4. **Klarifikasi Keselarasan Analogi Blokade Layering Konseptual (Database Paradigma Sistem MVC vs MVP vs Layer-Feature):** 
   Sebagai mahasiswa berbobot logis tajam, berikan pembelaan teori penulisan skripsi anda saat uji tanya sidang majelis penguji bahwa subsistem _Front-end Smartphone Flutter_ bagian dari wilayah pengembangan Anda (seperti semua kodingan dan kerangka isi _Repository Github_ Mobile di dokumen tebal ini) sepenuhnya tunduk pada hirarki arsitektural spesifik, yakni bertindak ekslusif sebagai porsen _Layer Presentation View_ layar semata ditambah separuh bumbu resep pemikir _Controllernya_. Di mana inti mutlak sistem basis data yang hakiki tempat bernaungnya roh aplikasi, tetap bersandar menggantung megah di infrastruktur tatanan Skema Tabel Relasional Skrip Server Backend Laravel PHP (RDBMS Eksternal Relational SQL Database Server Jarak Jauh). Demikian, klien Aplikasi Mobile _Android/iOS Flutter_ secara independen suci (murni) mendedikasikan fungsinya berlaku hanyalah sebagai medium corong perantara _User-View Interface Representational Client Stateless/Stateful Agent_ belaka, menyeleksi antarmuka (fetching display) atas wewenang pemanggilan endpoint JSON tanpa merancukan keruwetan di server hulu sana. Begitulah kerukunan harmonis API (RestFul Integrational Cross-boundary) yang sesungguhnya.

***(Akhir Dari Format Blueprint Super Ekstensif - Silakan Ambil Bagian Penjabaran Manapun Sebagai Copas Paragraf Substansial Penuh untuk Modul TA Anda. Selamat menyusun laporan naskah SKRIPSI dengan percaya diri sangat tinggi, jaminan hasil mutu materi konten aplikasi sistem terbaik yang sangat memukau mata tim dewan Dosen Penguji Fakultas Kalian!)***
`;
fs.writeFileSync('d:\\TA\\TA\\motorcycle-management-mobile\\docs\\DOKUMENTASI_SKRIPSI.md', content, 'utf8');
console.log('Done writing comprehensive markdown file.');