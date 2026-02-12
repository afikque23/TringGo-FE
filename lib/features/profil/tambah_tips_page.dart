import 'package:flutter/material.dart';

class TambahTipsPage extends StatefulWidget {
  const TambahTipsPage({super.key});

  @override
  State<TambahTipsPage> createState() => _TambahTipsPageState();
}

class _TambahTipsPageState extends State<TambahTipsPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _tipeController = TextEditingController();
  final _tahunController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _catatanController = TextEditingController();
  final _intervalJarakController = TextEditingController();
  final _intervalWaktuController = TextEditingController();

  String? _selectedMerek;
  String? _selectedGayaBerkendara;
  bool _isCopyable = false;
  final List<String> _langkahList = [''];
  final List<String> _alatList = [''];

  final List<String> _merekList = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'Vespa',
    'TVS',
    'Benelli',
    'Viar',
    'Lainnya',
  ];

  final List<String> _gayaBerkendaraList = [
    'Harian / Commuter',
    'Touring',
    'Sport / Track',
    'Off-road',
    'Urban / City',
    'Kombinasi',
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _tipeController.dispose();
    _tahunController.dispose();
    _deskripsiController.dispose();
    _catatanController.dispose();
    _intervalJarakController.dispose();
    _intervalWaktuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInformasiDasarSection(colorScheme),
                    const SizedBox(height: 16),
                    _buildDetailPerawatanSection(colorScheme),
                    const SizedBox(height: 16),
                    _buildActionButtons(colorScheme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Buat Template Perawatan',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Bagikan pengalaman Anda ke komunitas',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiDasarSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Dasar',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Judul Tips *',
            controller: _judulController,
            hint: 'Contoh: Cara Efisien Ganti Oli',
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Merek Motor *',
            value: _selectedMerek,
            items: _merekList,
            onChanged: (value) => setState(() => _selectedMerek = value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Tipe / Model *',
            controller: _tipeController,
            hint: 'Ninja 250',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Tahun *',
            controller: _tahunController,
            hint: '2022',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Gaya Berkendara *',
            value: _selectedGayaBerkendara,
            items: _gayaBerkendaraList,
            onChanged: (value) =>
                setState(() => _selectedGayaBerkendara = value),
          ),
          const SizedBox(height: 16),
          _buildCopyableToggle(),
        ],
      ),
    );
  }

  Widget _buildDetailPerawatanSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Perawatan',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextAreaField(
            label: 'Deskripsi Singkat *',
            controller: _deskripsiController,
            hint:
                'Jelaskan secara singkat tentang tips perawatan ini dan manfaatnya...',
            maxLength: 500,
          ),
          const SizedBox(height: 16),
          _buildLangkahSection(),
          const SizedBox(height: 16),
          _buildAlatSection(),
          const SizedBox(height: 16),
          _buildIntervalFields(),
          const SizedBox(height: 16),
          _buildTextAreaField(
            label: 'Catatan Tambahan',
            controller: _catatanController,
            hint:
                'Tips khusus, peringatan, atau informasi tambahan yang perlu diperhatikan...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        // PERBAIKAN: Border dipindahkan ke InputDecoration
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1E2939),
                width: 0.65,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6B7C4F),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF99A1AF)),
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            hintText: 'Pilih ${label.replaceAll(' *', '')}',
            hintStyle: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1E2939),
                width: 0.65,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6B7C4F),
                width: 1.5,
              ),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int? maxLength,
    int maxLines = 5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
            ),
            counterStyle: const TextStyle(color: Color(0xFF6A7282)),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1E2939),
                width: 0.65,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6B7C4F),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableToggle() {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Boleh Disalin Pengguna Lain',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Izinkan komunitas mengadaptasi template ini',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isCopyable = !_isCopyable),
            child: Container(
              width: 46,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _isCopyable
                    ? const Color(0xFF6B7C4F)
                    : const Color(0xFF364153),
                borderRadius: BorderRadius.circular(100),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _isCopyable
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangkahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langkah-langkah Perawatan *',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        ..._langkahList.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Nomor Urut Langkah
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0x336B7C4F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7C4F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Form Input Langkah
                Expanded(
                  child: TextField(
                    onChanged: (value) => _langkahList[index] = value,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFFFFFF),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      hintText: 'Langkah ${index + 1}',
                      hintStyle: const TextStyle(color: Color(0xFF6A7282)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E2939),
                          width: 0.65,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF6B7C4F),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Jarak antara Form dan Tombol Silang
                const SizedBox(width: 12),
                // Tombol Silang (Hapus)
                GestureDetector(
                  onTap: () {
                    if (_langkahList.length > 1) {
                      setState(() => _langkahList.removeAt(index));
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x33FF6467),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFFFF6467),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Tombol Tambah Langkah
        GestureDetector(
          onTap: () => setState(() => _langkahList.add('')),
          child: Container(
            height: 37,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF364153), width: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, size: 16, color: Color(0xFF99A1AF)),
                SizedBox(width: 8),
                Text(
                  'Tambah Langkah',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alat yang Dibutuhkan *',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        ..._alatList.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Icon Alat
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0x336B7C4F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.build,
                    size: 16,
                    color: Color(0xFF6B7C4F),
                  ),
                ),
                const SizedBox(width: 8),
                // Form Input Nama Alat
                Expanded(
                  child: TextField(
                    onChanged: (value) => _alatList[index] = value,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFFFFFF),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      hintText: 'Nama alat',
                      hintStyle: const TextStyle(color: Color(0xFF6A7282)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E2939),
                          width: 0.65,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF6B7C4F),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Jarak antara Form Alat dan Tombol Silang
                const SizedBox(width: 12),
                // Tombol Silang (Hapus)
                GestureDetector(
                  onTap: () {
                    if (_alatList.length > 1) {
                      setState(() => _alatList.removeAt(index));
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x33FF6467),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFFFF6467),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Tombol Tambah Alat
        GestureDetector(
          onTap: () => setState(() => _alatList.add('')),
          child: Container(
            height: 37,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF364153), width: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, size: 16, color: Color(0xFF99A1AF)),
                SizedBox(width: 8),
                Text(
                  'Tambah Alat',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interval Jarak (km) *',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _intervalJarakController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFFFFFF),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  prefixIcon: const Icon(
                    Icons.route,
                    size: 16,
                    color: Color(0xFF6A7282),
                  ),
                  hintText: '2000',
                  hintStyle: const TextStyle(color: Color(0xFF6A7282)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E2939),
                      width: 0.65,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B7C4F),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interval Waktu (bulan)',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _intervalWaktuController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFFFFFF),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  hintText: '2',
                  hintStyle: const TextStyle(color: Color(0xFF6A7282)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E2939),
                      width: 0.65,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B7C4F),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  border: Border.all(
                    color: const Color(0xFF1E2939),
                    width: 0.65,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.visibility_outlined,
                      size: 20,
                      color: Color(0xFFFFFFFF),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pratinjau',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2939),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.send_outlined,
                      size: 20,
                      color: Color(0xFF6A7282),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bagikan',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
