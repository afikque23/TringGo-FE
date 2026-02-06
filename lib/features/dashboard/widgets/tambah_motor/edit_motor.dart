import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class EditMotorPage extends StatefulWidget {
  final String name;
  final String brand;
  final String model;
  final String year;
  final String odometer;
  final bool isMainVehicle;

  const EditMotorPage({
    super.key,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.odometer,
    required this.isMainVehicle,
  });

  @override
  State<EditMotorPage> createState() => _EditMotorPageState();
}

class _EditMotorPageState extends State<EditMotorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaKendaraanController;
  late final TextEditingController _merekController;
  late final TextEditingController _modelController;
  late final TextEditingController _tahunController;
  late final TextEditingController _odometerController;
  late bool _isMainVehicle;

  @override
  void initState() {
    super.initState();
    _namaKendaraanController = TextEditingController(text: widget.name);
    _merekController = TextEditingController(text: widget.brand);
    _modelController = TextEditingController(text: widget.model);
    _tahunController = TextEditingController(text: widget.year);
    _odometerController = TextEditingController(text: widget.odometer);
    _isMainVehicle = widget.isMainVehicle;
  }

  @override
  void dispose() {
    _namaKendaraanController.dispose();
    _merekController.dispose();
    _modelController.dispose();
    _tahunController.dispose();
    _odometerController.dispose();
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
                    _buildInputField(
                      label: l10n.currentOdometerKm,
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Checkbox Card
                    _buildMainVehicleCheckbox(),

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
            onPressed: () => Navigator.pop(context),
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
            onPressed: _handleSave,
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              l10n.save,
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

  void _handleSave() {
    if (_namaKendaraanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama kendaraan tidak boleh kosong'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final updatedData = {
      'nama': _namaKendaraanController.text,
      'merek': _merekController.text,
      'model': _modelController.text,
      'tahun': _tahunController.text,
      'odometer': _odometerController.text,
      'isMainVehicle': _isMainVehicle,
    };

    print('Updating vehicle: $updatedData');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kendaraan berhasil diperbarui'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.pop(context);
  }
}
