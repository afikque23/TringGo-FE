import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/service_history_service.dart';
import '../../../core/model/service_history_model.dart';

class EditRiwayatServicePage extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const EditRiwayatServicePage({super.key, required this.serviceData});

  @override
  State<EditRiwayatServicePage> createState() => _EditRiwayatServicePageState();
}

class _EditRiwayatServicePageState extends State<EditRiwayatServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _historyService = ServiceHistoryService();

  // Controllers
  late TextEditingController _odometerController;
  late TextEditingController _biayaController;
  late TextEditingController _bengkelController;
  late TextEditingController _catatanController;

  DateTime? _selectedDate;
  String _selectedServiceType = 'other'; // Initialize with default value
  bool _isLoading = false;

  // Mapping tipe servis dari database ke key yang sesuai
  String _mapServiceType(String englishName) {
    final Map<String, String> serviceTypeMap = {
      'Oil Change': 'oilChange',
      'Tire Replacement': 'tireReplacement',
      'Chain Adjustment': 'chainSprocketReplacement',
      'Brake Pad Replacement': 'brakePadReplacement',
      'Tune Up': 'tuneUp',
      'Spark Plug Replacement': 'sparkPlugReplacement',
      'Periodic Service': 'periodicService',
      'Engine Repair': 'engineRepair',
    };
    return serviceTypeMap[englishName] ?? 'other';
  }

  @override
  void initState() {
    super.initState();
    // Konversi tanggal dengan aman (safety parse)
    _selectedDate =
        DateTime.tryParse(widget.serviceData['serviceDate'] ?? '') ??
        DateTime.now();

    // Inisialisasi dropdown dan text controller dengan data yang sudah ada
    _selectedServiceType = _mapServiceType(widget.serviceData['type'] ?? '');
    _odometerController = TextEditingController(
      text: widget.serviceData['odometer']?.toString() ?? '',
    );
    _biayaController = TextEditingController(
      text: widget.serviceData['cost']?.toString() ?? '',
    );
    _bengkelController = TextEditingController(
      text: widget.serviceData['serviceProvider'] ?? '',
    );
    _catatanController = TextEditingController(
      text: widget.serviceData['notes'] ?? '',
    );
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _biayaController.dispose();
    _bengkelController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // --- UI COMPONENTS (SAMA DENGAN HALAMAN TAMBAH) ---

  Widget _buildFormSection({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String hint, {IconData? suffix}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.textSecondary, fontSize: 16),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      suffixIcon: suffix != null
          ? Icon(suffix, color: colorScheme.textSecondary, size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: colorScheme.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.editServiceRecord,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.updateMaintenanceInfo,
              style: TextStyle(fontSize: 14, color: colorScheme.textSecondary),
            ),
          ],
        ),
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FIELD TANGGAL
              _buildFormSection(
                label: l10n.serviceDate,
                icon: Icons.calendar_today,
                child: TextFormField(
                  readOnly: true,
                  onTap: _selectDate,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputStyle(
                    _selectedDate == null
                        ? l10n.selectDate
                        : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                    suffix: Icons.calendar_month,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FIELD JENIS SERVIS
              _buildFormSection(
                label: l10n.serviceType,
                icon: Icons.settings,
                child: DropdownButtonFormField<String>(
                  value: _selectedServiceType,
                  dropdownColor: colorScheme.surfaceContainerHighest,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.textSecondary,
                  ),
                  decoration: _inputStyle(l10n.selectServiceType),
                  items: [
                    DropdownMenuItem(
                      value: 'oilChange',
                      child: Text(l10n.oilChange),
                    ),
                    DropdownMenuItem(
                      value: 'brakePadReplacement',
                      child: Text(l10n.brakePadReplacement),
                    ),
                    DropdownMenuItem(
                      value: 'tireReplacement',
                      child: Text(l10n.tireReplacement),
                    ),
                    DropdownMenuItem(
                      value: 'chainSprocketReplacement',
                      child: Text(l10n.chainSprocketReplacement),
                    ),
                    DropdownMenuItem(value: 'tuneUp', child: Text(l10n.tuneUp)),
                    DropdownMenuItem(
                      value: 'sparkPlugReplacement',
                      child: Text(l10n.sparkPlugReplacement),
                    ),
                    DropdownMenuItem(
                      value: 'periodicService',
                      child: Text(l10n.periodicService),
                    ),
                    DropdownMenuItem(
                      value: 'engineRepair',
                      child: Text(l10n.engineRepair),
                    ),
                    DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedServiceType = val ?? 'other'),
                ),
              ),
              const SizedBox(height: 16),

              // FIELD ODOMETER
              _buildFormSection(
                label: '${l10n.odometer} (km)',
                icon: Icons.speed,
                child: TextFormField(
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputStyle('${l10n.example}: 8450'),
                ),
              ),
              const SizedBox(height: 16),

              // FIELD BIAYA
              _buildFormSection(
                label: '${l10n.cost} (Rp)',
                icon: Icons.account_balance_wallet,
                child: TextFormField(
                  controller: _biayaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputStyle('${l10n.example}: 150000'),
                ),
              ),
              const SizedBox(height: 16),

              // FIELD BENGKEL
              _buildFormSection(
                label: l10n.workshopServiceCenter,
                icon: Icons.storefront,
                child: TextFormField(
                  controller: _bengkelController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputStyle(
                    '${l10n.example}: Bengkel Motor Jaya',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FIELD CATATAN
              _buildFormSection(
                label: l10n.notesOptional,
                icon: Icons.edit_note,
                child: TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputStyle(l10n.addDetail),
                ),
              ),
              const SizedBox(height: 16),

              // UPLOAD STRUK AREA
              _buildFormSection(
                label: l10n.receiptOptional,
                icon: Icons.receipt_long,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outline, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: colorScheme.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.uploadReceipt,
                        style: TextStyle(color: colorScheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // TOMBOL AKSI
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _updateServiceRecord,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.save,
                        style: const TextStyle(color: Colors.white),
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC METHODS ---

  Future<void> _selectDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              surface: colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _updateServiceRecord() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih tanggal servis'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse input values
      final odometer = _odometerController.text.isEmpty
          ? null
          : int.tryParse(_odometerController.text);
      final cost = _biayaController.text.isEmpty
          ? null
          : double.tryParse(
              _biayaController.text.replaceAll(RegExp(r'[^\d]'), ''),
            );
      final historyId = widget.serviceData['id'] as int?;

      if (historyId == null) {
        throw Exception('ID riwayat servis tidak ditemukan');
      }

      // Map service type to readable name
      final serviceNameMap = {
        'oilChange': l10n.oilChange,
        'tireReplacement': l10n.tireReplacement,
        'chainSprocketReplacement': 'Ganti Rantai & Gir',
        'brakePadReplacement': l10n.brakePadReplacement,
        'tuneUp': 'Tune Up',
        'sparkPlugReplacement': l10n.sparkPlugReplacement,
        'periodicService': l10n.periodicService,
        'engineRepair': l10n.engineRepair,
        'other': l10n.other,
      };

      // Create updated service history model
      final updatedHistory = ServiceHistoryModel(
        id: historyId,
        vehicleId: widget.serviceData['vehicleId'] as int,
        serviceName:
            serviceNameMap[_selectedServiceType] ?? _selectedServiceType,
        serviceDate: _selectedDate!,
        odometer: odometer,
        cost: cost,
        serviceProvider: _bengkelController.text.isEmpty
            ? null
            : _bengkelController.text,
        notes: _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      // Call API
      await _historyService.updateHistory(historyId, updatedHistory);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.serviceRecordUpdated),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: \${e.toString()}'),
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
