import 'package:flutter/material.dart';

class TambahTipsPage extends StatefulWidget {
  const TambahTipsPage({super.key});

  @override
  State<TambahTipsPage> createState() => _TambahTipsPageState();
}

class _TambahTipsPageState extends State<TambahTipsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  // --- STYLE HELPER ---
  // Fungsi ini memastikan border pas di pinggir field dan berubah warna saat fokus
  InputDecoration _inputStyle(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6A7282), fontSize: 16),
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF6A7282), size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E2939), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B7C4F), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildSectionInfoDasar(),
                    const SizedBox(height: 16),
                    _buildSectionDetailPerawatan(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
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
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E2939)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Template',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Bagikan pengalaman Anda ke komunitas',
                style: TextStyle(color: Color(0xFF99A1AF), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionInfoDasar() {
    return _buildCardWrapper(
      title: 'Informasi Dasar',
      children: [
        _buildLabel('Judul Tips *'),
        TextFormField(
          controller: _judulController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('Contoh: Cara Efisien Ganti Oli'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Merek *'),
                  DropdownButtonFormField<String>(
                    value: _selectedMerek,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Pilih'),
                    items: _merekList
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMerek = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Tipe / Model *'),
                  TextFormField(
                    controller: _tipeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Ninja 250'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel('Gaya Berkendara *'),
        DropdownButtonFormField<String>(
          value: _selectedGayaBerkendara,
          dropdownColor: const Color(0xFF1A1A1A),
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('Pilih gaya berkendara'),
          items: _gayaBerkendaraList
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGayaBerkendara = v),
        ),
        const SizedBox(height: 16),
        _buildCopyToggle(),
      ],
    );
  }

  Widget _buildSectionDetailPerawatan() {
    return _buildCardWrapper(
      title: 'Detail Perawatan',
      children: [
        _buildLabel('Deskripsi *'),
        TextFormField(
          controller: _deskripsiController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('Jelaskan manfaat tips ini...'),
        ),
        const SizedBox(height: 16),
        _buildDynamicList(
          label: 'Langkah-langkah *',
          list: _langkahList,
          hint: 'Langkah',
        ),
        const SizedBox(height: 16),
        _buildIntervalFields(),
        const SizedBox(height: 16),
        _buildLabel('Catatan Tambahan'),
        TextFormField(
          controller: _catatanController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: _inputStyle('Tips khusus atau peringatan...'),
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildCardWrapper({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFD1D5DC), fontSize: 14),
      ),
    );
  }

  Widget _buildDynamicList({
    required String label,
    required List<String> list,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        ...list.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('$hint ${entry.key + 1}'),
                    onChanged: (v) => list[entry.key] = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => setState(
                    () => list.length > 1 ? list.removeAt(entry.key) : null,
                  ),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => list.add('')),
          icon: const Icon(
            Icons.add_circle_outline,
            size: 18,
            color: Color(0xFF6B7C4F),
          ),
          label: Text(
            'Tambah $hint',
            style: const TextStyle(color: Color(0xFF6B7C4F)),
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
              _buildLabel('Jarak (km)'),
              TextFormField(
                controller: _intervalJarakController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle('2000', prefixIcon: Icons.route),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Waktu (Bln)'),
              TextFormField(
                controller: _intervalWaktuController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle('3', prefixIcon: Icons.calendar_month),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCopyToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2939)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Boleh Disalin komunitas',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Switch(
            value: _isCopyable,
            activeColor: const Color(0xFF6B7C4F),
            onChanged: (v) => setState(() => _isCopyable = v),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF1E2939)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Pratinjau',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send, size: 18, color: Colors.white),
            label: const Text('Bagikan', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF6B7C4F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
