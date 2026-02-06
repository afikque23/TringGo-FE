import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class TambahRiwayatServicePage extends StatefulWidget {
  const TambahRiwayatServicePage({super.key});

  @override
  State<TambahRiwayatServicePage> createState() =>
      _TambahRiwayatServicePageState();
}

class _TambahRiwayatServicePageState extends State<TambahRiwayatServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _biayaController = TextEditingController();
  final _bengkelController = TextEditingController();
  final _catatanController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedServiceType;

  @override
  void dispose() {
    _odometerController.dispose();
    _biayaController.dispose();
    _bengkelController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // --- UI HELPER METHODS ---

  // Fungsi sakti untuk membuat input yang rapi tanpa border double
  Widget _buildFormInput({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
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

  // Gaya InputDecoration yang konsisten untuk semua field
  InputDecoration _inputDecoration(String hintText, {IconData? suffixIcon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        color: colorScheme.textSecondary,
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: colorScheme.textSecondary, size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      // Border utama yang rapi
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
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
        centerTitle: false,
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
              l10n.addServiceRecord,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.recordMaintenanceHistory,
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
              // TANGGAL
              _buildFormInput(
                label: l10n.serviceDate,
                icon: Icons.calendar_today,
                child: TextFormField(
                  readOnly: true,
                  onTap: _selectDate,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration(
                    _selectedDate == null
                        ? l10n.selectDate
                        : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                    suffixIcon: Icons.calendar_month,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // JENIS SERVIS
              _buildFormInput(
                label: l10n.serviceType,
                icon: Icons.settings,
                child: DropdownButtonFormField<String>(
                  dropdownColor: colorScheme.surfaceContainerHighest,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.textSecondary,
                  ),
                  decoration: _inputDecoration(l10n.selectServiceType),
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
                      setState(() => _selectedServiceType = val),
                ),
              ),
              const SizedBox(height: 16),

              // ODOMETER
              _buildFormInput(
                label: '${l10n.odometer} (km)',
                icon: Icons.speed,
                child: TextFormField(
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration('${l10n.example}: 8450'),
                ),
              ),
              const SizedBox(height: 16),

              // BIAYA
              _buildFormInput(
                label: '${l10n.cost} (Rp)',
                icon: Icons.account_balance_wallet,
                child: TextFormField(
                  controller: _biayaController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration('${l10n.example}: 150000'),
                ),
              ),
              const SizedBox(height: 16),

              // BENGKEL
              _buildFormInput(
                label: l10n.workshopServiceCenter,
                icon: Icons.storefront,
                child: TextFormField(
                  controller: _bengkelController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration(
                    '${l10n.example}: Bengkel Motor Jaya',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // CATATAN
              _buildFormInput(
                label: l10n.notesOptional,
                icon: Icons.edit_note,
                child: TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: _inputDecoration(l10n.addDetail),
                ),
              ),
              const SizedBox(height: 16),

              // UPLOAD AREA
              _buildFormInput(
                label: l10n.receiptOptional,
                icon: Icons.receipt_long,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 34),
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

              // BUTTONS
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
                      onPressed: _saveServiceRecord,
                      icon: const Icon(
                        Icons.save,
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
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC METHODS ---

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveServiceRecord() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
    }
  }
}
