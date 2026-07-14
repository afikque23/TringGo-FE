import 'package:flutter/material.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
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
  final _deviceIdController = TextEditingController();

  String? _selectedMotorcycleType;
  String? _selectedKapasitasCc;
  bool _isMainVehicle = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaKendaraanController.dispose();
    _merekController.dispose();
    _modelController.dispose();
    _tahunController.dispose();
    _odometerController.dispose();
    _deviceIdController.dispose();
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

                    // Checkbox Card
                    _buildMainVehicleCheckbox(),

                    const SizedBox(height: 28),

                    // Section: Perangkat IoT
                    _buildIoTSection(),

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

  // ─── Section Perangkat IoT ─────────────────────────────────────────────────
  Widget _buildIoTSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withAlpha(80),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.secondary.withAlpha(60),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.memory_rounded,
                size: 16,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perangkat IoT (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hubungkan perangkat ESP32 ke motor ini untuk tracking & telemetri.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _deviceIdController,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Device ID (MAC Address)',
                  hintText: 'XX:XX:XX:XX:XX:XX',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withAlpha(80),
                    fontFamily: 'monospace',
                  ),
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  floatingLabelStyle: TextStyle(color: colorScheme.secondary),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
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
                      color: colorScheme.secondary,
                      width: 1.5,
                    ),
                  ),
                  helperText: 'Lihat di Serial Monitor PlatformIO saat ESP32 boot',
                  helperStyle: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(120),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
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
        DropdownButtonFormField<String>(
          initialValue: _selectedMotorcycleType,
          dropdownColor: colorScheme.surfaceContainerHighest,
          isExpanded: true,
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
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
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

      final mac = _deviceIdController.text.trim().toUpperCase();
      
      // Validasi MAC format if provided
      if (mac.isNotEmpty) {
        final regex = RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
        if (!regex.hasMatch(mac)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Format Device ID tidak valid. Gunakan format: XX:XX:XX:XX:XX:XX'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
      }

      setState(() => _isLoading = true);

      try {
        final year = int.tryParse(_tahunController.text) ?? 2026;
        final odometer = int.tryParse(_odometerController.text) ?? 0;

        final vehicle = VehicleModel(
        title: _namaKendaraanController.text,
        make: _merekController.text,
        model: _modelController.text,
        year: year,
        tipeMotor: _selectedMotorcycleType,
        kapasitasCc: _selectedKapasitasCc,
        odometer: odometer,
        isPrimary: _isMainVehicle,
        deviceId: mac.isEmpty ? null : mac,
      );

      await _vehicleService.createVehicle(vehicle);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kendaraan berhasil ditambahkan'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Navigator.pop(context, true);
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
