import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/vehicle_service.dart';
import '../../../../core/model/vehicle_model.dart';

class TambahMotorPage extends StatefulWidget {
  const TambahMotorPage({super.key});

  @override
  State<TambahMotorPage> createState() => _TambahMotorPageState();
}

class _TambahMotorPageState extends State<TambahMotorPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleService = VehicleService();

  // Controllers
  final _namaKendaraanController = TextEditingController();
  final _merekController = TextEditingController();
  final _modelController = TextEditingController();
  final _tahunController = TextEditingController(text: '2026');
  final _odometerController = TextEditingController(text: '0');
  final _platNomorController = TextEditingController();
  final _warnaController = TextEditingController();

  String? _selectedMotorcycleType;
  String? _selectedKapasitasCc;
  bool _isMainVehicle = false;
  bool _isLoading = false;

  // Parameter default penggunaan (untuk kalkulasi jadwal service)
  String _defaultBeban = 'ringan';
  bool _defaultPenumpang = false;
  String _defaultGayaBerkendara = 'normal';
  String _defaultKondisiJalan = 'sedang';
  String _defaultMedan = 'datar';

  // State untuk preset kondisi jalan (disimpan lokal)
  // Format tiap item: { 'name': 'Kampus', 'value': 'macet' }
  List<Map<String, String>> _kondisiPresets = [];
  String? _selectedPresetName; // null = buat baru
  final _namaKondisiController = TextEditingController();

  static const _presetsKey = 'kondisi_jalan_presets';

  @override
  void initState() {
    super.initState();
    _loadKondisiPresets();
  }

  Future<void> _loadKondisiPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_presetsKey) ?? [];
      if (mounted) {
        setState(() {
          _kondisiPresets = raw.map((e) {
            final parts = e.split('|');
            return {
              'name': parts[0],
              'value': parts.length > 1 ? parts[1] : 'sedang',
            };
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveKondisiPreset(String name, String value) async {
    if (name.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_presetsKey) ?? [];
      final key = '${name.trim()}|$value';
      if (!raw.any(
        (e) => e.split('|')[0].toLowerCase() == name.trim().toLowerCase(),
      )) {
        raw.add(key);
        await prefs.setStringList(_presetsKey, raw);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _namaKendaraanController.dispose();
    _merekController.dispose();
    _modelController.dispose();
    _tahunController.dispose();
    _odometerController.dispose();
    _platNomorController.dispose();
    _warnaController.dispose();
    _namaKondisiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
            decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: colorScheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.addVehicle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: l10n.vehicleName,
                      controller: _namaKendaraanController,
                      placeholder: l10n.vehicleNamePlaceholder,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: l10n.motorcycleBrand,
                      controller: _merekController,
                      placeholder: l10n.brandPlaceholder,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: l10n.motorcycleModel,
                      controller: _modelController,
                      placeholder: l10n.modelPlaceholder,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: l10n.motorcycleYear,
                      controller: _tahunController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildMotorcycleTypeDropdown(),
                    const SizedBox(height: 20),
                    _buildChipSelector(
                      label: 'Kapasitas Mesin',
                      options: const ['<125cc', '125-250cc', '>250cc'],
                      values: const ['<125', '125-250', '>250'],
                      selected: _selectedKapasitasCc,
                      onSelected: (v) =>
                          setState(() => _selectedKapasitasCc = v),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: l10n.currentOdometerKm,
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: l10n.licensePlate,
                      controller: _platNomorController,
                      placeholder: l10n.licensePlatePlaceholder,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: l10n.motorcycleColor,
                      controller: _warnaController,
                      placeholder: l10n.colorPlaceholder,
                    ),
                    const SizedBox(height: 20),

                    // Checkbox Card
                    _buildMainVehicleCheckbox(),

                    const SizedBox(height: 28),

                    // Section: Parameter Default Penggunaan
                    _buildSectionHeader(
                      'Parameter Default Penggunaan',
                      'Digunakan sebagai baseline kalkulasi jadwal service. Bisa diubah kapanpun.',
                    ),
                    const SizedBox(height: 16),
                    _buildKondisiJalanSelector(),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Medan Jalan Dominan',
                      options: const [
                        '🏙️ Datar',
                        '🌄 Campuran',
                        '🏔️ Berbukit',
                      ],
                      values: const ['datar', 'campuran', 'berbukit'],
                      selected: _defaultMedan,
                      onSelected: (v) => setState(() => _defaultMedan = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Gaya Berkendara',
                      options: const ['🐢 Pelan', '🚗 Normal', '🏎️ Agresif'],
                      values: const ['pelan', 'normal', 'agresif'],
                      selected: _defaultGayaBerkendara,
                      onSelected: (v) =>
                          setState(() => _defaultGayaBerkendara = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Beban Bawaan Biasa',
                      options: const ['🎒 Ringan', '🛍️ Sedang', '📦 Berat'],
                      values: const ['ringan', 'sedang', 'berat'],
                      selected: _defaultBeban,
                      onSelected: (v) => setState(() => _defaultBeban = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildToggleField(
                      label: 'Sering Bawa Penumpang?',
                      value: _defaultPenumpang,
                      onChanged: (v) => setState(() => _defaultPenumpang = v),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Input Field yang diperbaiki (Tanpa border ganda)
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    TextInputType? keyboardType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: colorScheme.textSecondary.withAlpha(128),
            ),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // Border saat diam
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            // Border saat aktif/fokus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            // Border saat validasi error
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(80),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.primary.withAlpha(60),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required List<String> values,
    required String? selected,
    required void Function(String?) onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (i) {
            final isSelected = selected == values[i];
            return GestureDetector(
              onTap: () => onSelected(values[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---- Helper: label kondisi jalan ----
  String _kondisiJalanLabel(String? value) {
    switch (value) {
      case 'macet':
        return '🔴 Macet';
      case 'lancar':
        return '🟢 Lancar';
      default:
        return '🟡 Sedang';
    }
  }

  // ---- Widget: Kondisi Jalan Selector (preset + form baru) ----
  Widget _buildKondisiJalanSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isBuatBaru = _selectedPresetName == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Kondisi Jalan Sehari-hari',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        // Dropdown preset jika sudah ada yang tersimpan
        if (_kondisiPresets.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedPresetName ?? '__new__',
            dropdownColor: colorScheme.surfaceContainerHighest,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: colorScheme.onSurfaceVariant,
            ),
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: [
              ..._kondisiPresets.map(
                (p) => DropdownMenuItem(
                  value: p['name'],
                  child: Text(
                    '${p['name']}  •  ${_kondisiJalanLabel(p['value'])}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const DropdownMenuItem(
                value: '__new__',
                child: Text('✏️ Buat Pengaturan Baru'),
              ),
            ],
            onChanged: (val) {
              setState(() {
                if (val == '__new__' || val == null) {
                  _selectedPresetName = null;
                  _namaKondisiController.clear();
                  _defaultKondisiJalan = 'sedang';
                } else {
                  _selectedPresetName = val;
                  final preset = _kondisiPresets.firstWhere(
                    (p) => p['name'] == val,
                    orElse: () => {'name': val, 'value': 'sedang'},
                  );
                  _defaultKondisiJalan = preset['value'] ?? 'sedang';
                }
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        // Form buat baru
        if (isBuatBaru) ...[
          // Field nama kondisi
          TextFormField(
            controller: _namaKondisiController,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Nama kondisi, mis: Kampus, Touring, Kantor…',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withAlpha(100),
                fontSize: 13,
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Chip kondisi jalan
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in [
                ('🔴 Macet', 'macet'),
                ('🟡 Sedang', 'sedang'),
                ('🟢 Lancar', 'lancar'),
              ])
                GestureDetector(
                  onTap: () => setState(() => _defaultKondisiJalan = entry.$2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _defaultKondisiJalan == entry.$2
                          ? colorScheme.primary
                          : colorScheme.surface,
                      border: Border.all(
                        color: _defaultKondisiJalan == entry.$2
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: _defaultKondisiJalan == entry.$2 ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.$1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _defaultKondisiJalan == entry.$2
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _defaultKondisiJalan == entry.$2
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ] else
          // Badge saat preset dipilih
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.primary.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _kondisiJalanLabel(_defaultKondisiJalan),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildToggleField({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMotorcycleTypeDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.motorcycleType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        // PERBAIKAN: Hapus Container pembungkus, gunakan decoration di dalam field
        DropdownButtonFormField<String>(
          initialValue: _selectedMotorcycleType,
          dropdownColor: colorScheme.surfaceContainerHighest,
          isExpanded: true, // Membuat menu pilihan lebarnya sama dengan box
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: colorScheme.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            hintText: l10n.selectMotorcycleType,
            hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha(128)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            // Border saat diam (Satu garis, pas dengan field lain)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),

            // Border saat fokus/diklik (Berubah warna hijau)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.primary, // Warna hijau sesuai theme Anda
                width: 1.5,
              ),
            ),

            // Menghapus border default agar tidak terjadi penumpukan
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: [
            DropdownMenuItem(
              value: 'matic',
              child: Text(l10n.motorcycleTypeMatic),
            ),
            DropdownMenuItem(value: 'manual', child: const Text('Manual')),
            DropdownMenuItem(
              value: 'sport',
              child: Text(l10n.motorcycleTypeSport),
            ),
          ],
          onChanged: (val) => setState(() => _selectedMotorcycleType = val),
        ),
      ],
    );
  }

  Widget _buildMainVehicleCheckbox() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => setState(() => _isMainVehicle = !_isMainVehicle),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _isMainVehicle
                    ? colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: _isMainVehicle
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _isMainVehicle
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.setAsMainVehicle,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.surface,
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSave,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined, color: Colors.white),
            label: Text(
              _isLoading ? 'Menyimpan...' : l10n.save,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    if (_namaKendaraanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama kendaraan tidak boleh kosong'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedMotorcycleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tipe motor wajib dipilih'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse controllers
      final year = int.tryParse(_tahunController.text) ?? 2026;
      final odometer = int.tryParse(_odometerController.text) ?? 0;

      // Create vehicle model
      final vehicle = VehicleModel(
        title: _namaKendaraanController.text,
        make: _merekController.text,
        model: _modelController.text,
        year: year,
        tipeMotor: _selectedMotorcycleType,
        kapasitasCc: _selectedKapasitasCc,
        odometer: odometer,
        licensePlate: _platNomorController.text.isEmpty
            ? null
            : _platNomorController.text,
        color: _warnaController.text.isEmpty ? null : _warnaController.text,
        isPrimary: _isMainVehicle,
        // Parameter default kalkulasi service
        defaultBeban: _defaultBeban,
        defaultPenumpang: _defaultPenumpang,
        defaultGayaBerkendara: _defaultGayaBerkendara,
        defaultKondisiJalan: _defaultKondisiJalan,
        defaultMedan: _defaultMedan,
      );

      // Call API
      await _vehicleService.createVehicle(vehicle);

      // Simpan preset kondisi jalan baru jika user isi nama
      if (_selectedPresetName == null &&
          _namaKondisiController.text.trim().isNotEmpty) {
        await _saveKondisiPreset(
          _namaKondisiController.text.trim(),
          _defaultKondisiJalan,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kendaraan berhasil ditambahkan'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan kendaraan: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
