import 'package:flutter/material.dart';
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
  final String? deviceId;

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
    this.deviceId,
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
  late final TextEditingController _deviceIdController;
  late bool _isMainVehicle;
  String? _selectedMotorcycleType;
  String? _selectedKapasitasCc;
  bool _isLoading = false;
  bool _isLinkingDevice = false;

  // State perangkat IoT — dikelola terpisah dari form utama
  String? _linkedDeviceId;

  @override
  void initState() {
    super.initState();
    _namaKendaraanController = TextEditingController(text: widget.name);
    _merekController = TextEditingController(text: widget.brand);
    _modelController = TextEditingController(text: widget.model);
    _tahunController = TextEditingController(text: widget.year);
    _odometerController = TextEditingController(text: widget.odometer);
    _deviceIdController = TextEditingController();
    _isMainVehicle = widget.isMainVehicle;
    _selectedMotorcycleType = widget.tipeMotor;
    _selectedKapasitasCc = widget.kapasitasCc;
    _linkedDeviceId = widget.deviceId;
  }

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

  // ─── Validasi format MAC Address ───────────────────────────────────────────
  bool _isValidMac(String mac) {
    final regex = RegExp(
      r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$',
    );
    return regex.hasMatch(mac.trim());
  }

  // ─── Hubungkan perangkat (set device_id) ────────────────────────────────────
  Future<void> _handleLinkDevice() async {
    final mac = _deviceIdController.text.trim().toUpperCase();

    if (mac.isEmpty) {
      _showSnack('Masukkan Device ID terlebih dahulu', isError: true);
      return;
    }

    if (!_isValidMac(mac)) {
      _showSnack(
        'Format tidak valid. Gunakan format: XX:XX:XX:XX:XX:XX',
        isError: true,
      );
      return;
    }

    setState(() => _isLinkingDevice = true);

    try {
      final year = int.tryParse(_tahunController.text) ?? 2026;
      final odometer = int.tryParse(_odometerController.text) ?? 0;

      final vehicle = VehicleModel(
        id: widget.vehicleId,
        title: _namaKendaraanController.text,
        make: _merekController.text,
        model: _modelController.text,
        year: year,
        tipeMotor: _selectedMotorcycleType,
        kapasitasCc: _selectedKapasitasCc,
        odometer: odometer,
        isPrimary: _isMainVehicle,
        deviceId: mac,
      );

      await _vehicleService.updateVehicle(widget.vehicleId, vehicle);

      if (!mounted) return;
      setState(() {
        _linkedDeviceId = mac;
        _deviceIdController.clear();
      });
      _showSnack('Perangkat berhasil dihubungkan! 🔌');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal menghubungkan: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLinkingDevice = false);
    }
  }

  // ─── Putuskan perangkat (set device_id = null) ─────────────────────────────
  Future<void> _handleUnlinkDevice() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Putuskan Perangkat?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          content: Text(
            'Motor ini tidak akan lagi menerima data dari perangkat IoT. '
            'Kamu bisa menghubungkan kembali kapanpun.',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Putuskan',
                  style: TextStyle(color: cs.error)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLinkingDevice = true);

    try {
      final year = int.tryParse(_tahunController.text) ?? 2026;
      final odometer = int.tryParse(_odometerController.text) ?? 0;

      final vehicle = VehicleModel(
        id: widget.vehicleId,
        title: _namaKendaraanController.text,
        make: _merekController.text,
        model: _modelController.text,
        year: year,
        tipeMotor: _selectedMotorcycleType,
        kapasitasCc: _selectedKapasitasCc,
        odometer: odometer,
        isPrimary: _isMainVehicle,
        deviceId: null,
      );

      await _vehicleService.updateVehicle(widget.vehicleId, vehicle);

      if (!mounted) return;
      setState(() => _linkedDeviceId = null);
      _showSnack('Perangkat berhasil diputus');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal memutus perangkat: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLinkingDevice = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
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
                    _buildInputField(
                      label: l10n.currentOdometerKm,
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Checkbox Card
                    _buildMainVehicleCheckbox(),

                    const SizedBox(height: 28),

                    // ── Section: Perangkat IoT ──────────────────────────────
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
    final bool isLinked = _linkedDeviceId != null && _linkedDeviceId!.isNotEmpty;

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
                      'Perangkat IoT',
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

        if (isLinked) ...[
          // ── Sudah terhubung ──────────────────────────────────────────────
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
                // Status badge
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terhubung',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Device ID display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device ID',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _linkedDeviceId!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Unlink button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLinkingDevice ? null : _handleUnlinkDevice,
                    icon: _isLinkingDevice
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.error,
                            ),
                          )
                        : Icon(
                            Icons.link_off_rounded,
                            size: 18,
                            color: colorScheme.error,
                          ),
                    label: Text(
                      _isLinkingDevice ? 'Memutus...' : 'Putuskan Perangkat',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.error.withAlpha(100)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // ── Belum terhubung ──────────────────────────────────────────────
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
                // Not linked info
                Row(
                  children: [
                    Icon(
                      Icons.link_off_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Belum ada perangkat terhubung',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Device ID input
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
                    labelStyle:
                        TextStyle(color: colorScheme.onSurfaceVariant),
                    floatingLabelStyle:
                        TextStyle(color: colorScheme.secondary),
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
                    helperText: 'Cek Serial Monitor PlatformIO saat ESP32 menyala',
                    helperStyle: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Link button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLinkingDevice ? null : _handleLinkDevice,
                    icon: _isLinkingDevice
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isLinkingDevice
                          ? 'Menghubungkan...'
                          : 'Hubungkan Perangkat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Info box: perilaku device_id saat dijadikan kendaraan aktif
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(70),
                    borderRadius: BorderRadius.circular(8),
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
                            Icons.info_outline_rounded,
                            size: 13,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Perilaku Device ID saat dijadikan Kendaraan Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        colorScheme,
                        '• Belum punya Device ID:',
                        'Device ID dari kendaraan aktif sebelumnya dipindah ke sini secara otomatis.',
                      ),
                      const SizedBox(height: 3),
                      _buildInfoRow(
                        colorScheme,
                        '• Sudah punya Device ID:',
                        'Device ID tetap, tidak diubah.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    ColorScheme colorScheme,
    String label,
    String value,
  ) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurface.withAlpha(160),
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: ' $value'),
        ],
      ),
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
              color: colorScheme.textSecondary.withOpacity(0.5),
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
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedMotorcycleType,
            dropdownColor: colorScheme.surfaceContainerHighest,
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
                  color: colorScheme.primary,
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
      _showSnack('Nama kendaraan tidak boleh kosong', isError: true);
      return;
    }

    if (_selectedMotorcycleType == null) {
      _showSnack('Tipe motor wajib dipilih', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final year = int.tryParse(_tahunController.text) ?? 2026;
      final odometer = int.tryParse(_odometerController.text) ?? 0;

      final vehicle = VehicleModel(
        id: widget.vehicleId,
        title: _namaKendaraanController.text,
        make: _merekController.text,
        model: _modelController.text,
        year: year,
        tipeMotor: _selectedMotorcycleType,
        kapasitasCc: _selectedKapasitasCc,
        odometer: odometer,
        isPrimary: _isMainVehicle,
        deviceId: _linkedDeviceId, // Preserve linked device
      );

      await _vehicleService.updateVehicle(widget.vehicleId, vehicle);

      if (!mounted) return;
      _showSnack('Kendaraan berhasil diperbarui');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal memperbarui kendaraan: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
