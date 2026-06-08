import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/vehicle_service.dart';
import '../../../../core/model/vehicle_model.dart';

class EditMotorPage extends StatefulWidget {
  final int vehicleId;
  final String name;
  final String brand;
  final String model;
  final String year;
  final String odometer;
  final bool isMainVehicle;
  final String? tipeMotor;
  final String? kapasitasCc;
  final String? transmisi;
  final String? licensePlate;
  final String? color;
  // Parameter default
  final String? defaultBeban;
  final bool? defaultPenumpang;
  final String? defaultGayaBerkendara;
  final String? defaultKondisiJalan;
  final String? defaultMedan;

  const EditMotorPage({
    super.key,
    required this.vehicleId,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.odometer,
    required this.isMainVehicle,
    this.tipeMotor,
    this.kapasitasCc,
    this.transmisi,
    this.licensePlate,
    this.color,
    this.defaultBeban,
    this.defaultPenumpang,
    this.defaultGayaBerkendara,
    this.defaultKondisiJalan,
    this.defaultMedan,
  });

  @override
  State<EditMotorPage> createState() => _EditMotorPageState();
}

class _EditMotorPageState extends State<EditMotorPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleService = VehicleService();
  late final TextEditingController _namaKendaraanController;
  late final TextEditingController _merekController;
  late final TextEditingController _modelController;
  late final TextEditingController _tahunController;
  late final TextEditingController _odometerController;
  late final TextEditingController _platNomorController;
  late final TextEditingController _warnaController;
  late bool _isMainVehicle;
  String? _selectedMotorcycleType;
  String? _selectedKapasitasCc;
  String? _selectedTransmisi;
  bool _isLoading = false;

  // Parameter default penggunaan
  String _defaultBeban = 'ringan';
  bool _defaultPenumpang = false;
  String _defaultGayaBerkendara = 'normal';
  String _defaultKondisiJalan = 'sedang';
  String _defaultMedan = 'datar';

  @override
  void initState() {
    super.initState();
    _namaKendaraanController = TextEditingController(text: widget.name);
    _merekController = TextEditingController(text: widget.brand);
    _modelController = TextEditingController(text: widget.model);
    _tahunController = TextEditingController(text: widget.year);
    _odometerController = TextEditingController(text: widget.odometer);
    _platNomorController = TextEditingController(
      text: widget.licensePlate ?? '',
    );
    _warnaController = TextEditingController(text: widget.color ?? '');
    _isMainVehicle = widget.isMainVehicle;
    _selectedMotorcycleType = widget.tipeMotor;
    _selectedKapasitasCc = widget.kapasitasCc;
    _selectedTransmisi = widget.transmisi;
    // Inisialisasi parameter default dengan nilai dari widget atau fallback
    _defaultBeban = widget.defaultBeban ?? 'ringan';
    _defaultPenumpang = widget.defaultPenumpang ?? false;
    _defaultGayaBerkendara = widget.defaultGayaBerkendara ?? 'normal';
    _defaultKondisiJalan = widget.defaultKondisiJalan ?? 'sedang';
    _defaultMedan = widget.defaultMedan ?? 'datar';
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
                    l10n.editVehicle,
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
                    _buildChipSelector(
                      label: 'Transmisi',
                      options: const ['Manual', 'Otomatis (CVT)'],
                      values: const ['manual', 'cvt'],
                      selected: _selectedTransmisi,
                      onSelected: (v) => setState(() => _selectedTransmisi = v),
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

                    // Section: Parameter Default
                    _buildSectionHeader(
                      'Parameter Default Penggunaan',
                      'Digunakan sebagai baseline kalkulasi jadwal service.',
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Kondisi Jalan Sehari-hari',
                      options: const ['🔴 Macet', '🟡 Sedang', '🟢 Lancar'],
                      values: const ['macet', 'sedang', 'lancar'],
                      selected: _defaultKondisiJalan,
                      onSelected: (v) =>
                          setState(() => _defaultKondisiJalan = v!),
                    ),
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

  Widget _buildSectionHeader(String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary.withAlpha(60), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: colorScheme.primary),
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

  // Fungsi Input Field yang diperbaiki (Sama dengan TambahMotorPage)
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
              color: colorScheme.textSecondary.withOpacity(0.5),
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

  Widget _buildMotorcycleTypeDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            l10n.motorcycleType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        // Gunakan SizedBox untuk mengunci lebar field agar konsisten
        SizedBox(
          width: double.infinity, // Atau atur angka spesifik misal: 300
          child: DropdownButtonFormField<String>(
            initialValue: _selectedMotorcycleType,
            dropdownColor: colorScheme.surfaceContainerHighest,
            // PERBAIKAN: Matikan isExpanded agar menu tidak memaksa melebar penuh layar
            isExpanded: false,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: colorScheme.onSurfaceVariant,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surface,
              hintText: l10n.selectMotorcycleType,
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
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
                borderSide: BorderSide(
                  color: colorScheme.primary, // Warna hijau (6B7C4F)
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'matic',
                child: Text(l10n.motorcycleTypeMatic),
              ),
              DropdownMenuItem(value: 'manual', child: Text('Manual')),
              DropdownMenuItem(
                value: 'sport',
                child: Text(l10n.motorcycleTypeSport),
              ),
            ],
            onChanged: (val) => setState(() => _selectedMotorcycleType = val),
          ),
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
                : const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
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

      // Create vehicle model with updated data
      final vehicle = VehicleModel(
        id: widget.vehicleId,
        title: _namaKendaraanController.text,
        make: _merekController.text,
        model: _modelController.text,
        year: year,
        tipeMotor: _selectedMotorcycleType,
        kapasitasCc: _selectedKapasitasCc,
        transmisi: _selectedTransmisi,
        odometer: odometer,
        licensePlate: _platNomorController.text.isEmpty
            ? null
            : _platNomorController.text,
        color: _warnaController.text.isEmpty ? null : _warnaController.text,
        isPrimary: _isMainVehicle,
        // Parameter default
        defaultBeban: _defaultBeban,
        defaultPenumpang: _defaultPenumpang,
        defaultGayaBerkendara: _defaultGayaBerkendara,
        defaultKondisiJalan: _defaultKondisiJalan,
        defaultMedan: _defaultMedan,
      );

      // Call API
      await _vehicleService.updateVehicle(widget.vehicleId, vehicle);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kendaraan berhasil diperbarui'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui kendaraan: ${e.toString()}'),
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
