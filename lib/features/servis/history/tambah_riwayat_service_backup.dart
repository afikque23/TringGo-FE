import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';

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

  final List<String> _serviceTypes = [
    'Ganti Oli',
    'Ganti Kampas Rem',
    'Ganti Ban',
    'Ganti Rantai & Gir',
    'Tune Up',
    'Ganti Busi',
    'Servis Berkala',
    'Perbaikan Mesin',
    'Lainnya',
  ];

  @override
  void dispose() {
    _odometerController.dispose();
    _biayaController.dispose();
    _bengkelController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (dialogContext, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(backgroundColor: colorScheme.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveServiceRecord() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan servis berhasil disimpan'),
          backgroundColor: Color(0xFF6B7C4F),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildServiceTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildOdometerField(),
                      const SizedBox(height: 16),
                      _buildBiayaField(),
                      const SizedBox(height: 16),
                      _buildBengkelField(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                      const SizedBox(height: 16),
                      _buildFileUploadField(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 14, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Catatan Servis',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Catat riwayat perawatan motor Anda',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF99A1AF),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Tanggal Servis',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: cs.brightness == Brightness.dark
                      ? const Color(0xFFD1D5DC)
                      : cs.textSecondary,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              height: 49.29,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.brightness == Brightness.dark
                    ? const Color(0xFF252525)
                    : cs.inputFillColor,
                border: Border.all(color: cs.outlineVariant, width: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Pilih tanggal servis'
                          : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: _selectedDate == null
                            ? cs.onSurface.withOpacity(0.5)
                            : cs.onSurface,
                        height: 18 / 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Jenis Servis',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: cs.brightness == Brightness.dark
                      ? const Color(0xFFD1D5DC)
                      : cs.textSecondary,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 47.55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.brightness == Brightness.dark
                  ? const Color(0xFF252525)
                  : cs.inputFillColor,
              border: Border.all(color: cs.outlineVariant, width: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              hint: Text(
                'Pilih jenis servis',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0x80FFFFFF),
                  height: 18 / 16,
                ),
              ),
              dropdownColor: cs.brightness == Brightness.dark
                  ? const Color(0xFF252525)
                  : cs.inputFillColor,
              icon: Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: cs.onSurface,
              ),
              items: _serviceTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServiceType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih jenis servis';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerField() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.cardBackground,
        border: Border.all(color: cs.dividerLight, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Odometer (km)',
                style: TextStyle(fontSize: 14, color: cs.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.inputFillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.dividerLight, width: 0.65),
            ),
            child: TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 16, color: cs.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Contoh: 8450',
                hintStyle: TextStyle(color: cs.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiayaField() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.cardBackground,
        border: Border.all(color: cs.dividerLight, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Biaya (Rp)',
                style: TextStyle(fontSize: 14, color: cs.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.inputFillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.dividerLight, width: 0.65),
            ),
            child: TextFormField(
              controller: _biayaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 16, color: cs.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Contoh: 150000',
                hintStyle: TextStyle(color: cs.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBengkelField() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.cardBackground,
        border: Border.all(color: cs.dividerLight, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Bengkel / Service Center',
                style: TextStyle(fontSize: 14, color: cs.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.inputFillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.dividerLight, width: 0.65),
            ),
            child: TextFormField(
              controller: _bengkelController,
              style: TextStyle(fontSize: 16, color: cs.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Contoh: Bengkel Motor Jaya',
                hintStyle: TextStyle(color: cs.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.cardBackground,
        border: Border.all(color: cs.dividerLight, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Catatan (Opsional)',
                style: TextStyle(fontSize: 14, color: cs.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.inputFillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.dividerLight, width: 0.65),
            ),
            child: TextFormField(
              controller: _catatanController,
              maxLines: 4,
              style: TextStyle(fontSize: 16, color: cs.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Tambahkan detail tambahan...',
                hintStyle: TextStyle(color: cs.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadField() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.cardBackground,
        border: Border.all(color: cs.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Icon(Icons.receipt, color: cs.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Struk / Nota (Opsional)',
                style: TextStyle(fontSize: 14, color: cs.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Field abu di dalam card
          GestureDetector(
            onTap: () {
              // TODO: file picker
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: cs.inputFillColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: cs.primary,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unggah foto struk',
                      style: TextStyle(fontSize: 14, color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PNG, JPG, JPEG • Maks 5MB',
                      style: TextStyle(fontSize: 12, color: cs.textSecondary),
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

  Widget _buildActionButtons() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 49.29,
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant, width: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: cs.onSurface,
                  height: 24 / 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _saveServiceRecord,
            child: Container(
              height: 49.29,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: cs.onPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Simpan Catatan',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: cs.onPrimary,
                      height: 24 / 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
