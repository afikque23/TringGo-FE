import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditRiwayatServicePage extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const EditRiwayatServicePage({super.key, required this.serviceData});

  @override
  State<EditRiwayatServicePage> createState() => _EditRiwayatServicePageState();
}

class _EditRiwayatServicePageState extends State<EditRiwayatServicePage> {
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

  String? _mapServiceType(String englishName) {
    final Map<String, String> serviceTypeMap = {
      'Oil Change': 'Ganti Oli',
      'Tire Replacement': 'Ganti Ban',
      'Chain Adjustment': 'Ganti Rantai & Gir',
      'Brake Pad Replacement': 'Ganti Kampas Rem',
      'Tune Up': 'Tune Up',
      'Spark Plug Replacement': 'Ganti Busi',
    };
    return serviceTypeMap[englishName];
  }

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    String serviceTitle = widget.serviceData['title'];
    _selectedServiceType =
        _mapServiceType(serviceTitle) ??
        (_serviceTypes.contains(serviceTitle) ? serviceTitle : null);
    _odometerController.text = widget.serviceData['odometer'].replaceAll(
      ' km',
      '',
    );
    _biayaController.text = widget.serviceData['cost'].replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    _bengkelController.text = widget.serviceData['workshop'];
    _catatanController.text = widget.serviceData['notes'];

    // Parse date
    try {
      _selectedDate = DateFormat(
        'dd MMMM yyyy',
      ).parse(widget.serviceData['date']);
    } catch (e) {
      _selectedDate = DateTime.now();
    }
  }

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

  void _updateServiceRecord() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement update logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Catatan servis berhasil diperbarui'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      'Edit Catatan Servis',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perbarui riwayat perawatan motor Anda',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Tanggal Servis',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
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
                            ? colorScheme.onSurface.withOpacity(0.5)
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Jenis Servis',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              hint: Text(
                'Pilih jenis servis',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              dropdownColor: colorScheme.surfaceContainerLow,
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Odometer (km)',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                isDense: true,
                hintText: 'Contoh: 8450',
                hintStyle: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan odometer';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiayaField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Biaya (Rp)',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _biayaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                isDense: true,
                hintText: 'Contoh: 150000',
                hintStyle: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan biaya';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBengkelField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Bengkel / Service Center',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _bengkelController,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                isDense: true,
                hintText: 'Contoh: Bengkel Motor Jaya',
                hintStyle: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama bengkel';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _catatanController,
              maxLines: 4,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                isDense: true,
                hintText: 'Tambahkan detail tambahan...',
                hintStyle: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadField() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Struk/Nota (Opsional)',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // TODO: Implement file picker
            },
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: colorScheme.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unggah foto struk',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface.withOpacity(0.85),
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG atau JPEG (Maks 5MB)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.33,
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

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 49,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _updateServiceRecord,
            child: Container(
              height: 49,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: colorScheme.onPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Simpan Catatan',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onPrimary,
                      height: 1.5,
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
