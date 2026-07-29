import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/model/vehicle_model.dart';

enum InputMode { jarakTempuh, odometerTerakhir }

class TambahJarakPage extends StatefulWidget {
  const TambahJarakPage({super.key});

  @override
  State<TambahJarakPage> createState() => _TambahJarakPageState();
}

class _TambahJarakPageState extends State<TambahJarakPage> {
  final _vehicleService = VehicleService();
  final _tripService = TripService();

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  InputMode _inputMode = InputMode.jarakTempuh;
  final TextEditingController _jarakController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  DateTime? _selectedDate;
  VehicleModel? _selectedVehicle;

  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        // Auto-select primary vehicle if available
        if (_vehicles.isNotEmpty) {
          final primaryVehicle = _vehicles.firstWhere(
            (v) => v.isPrimary,
            orElse: () => _vehicles.first,
          );
          _selectedVehicle = primaryVehicle;
        }
      });
    } catch (e) {
      print('Error loading vehicles: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal memuat daftar kendaraan'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _jarakController.dispose();
    _odometerController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colorScheme.primary,
              onPrimary: Colors.white,
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

  Future<void> _handleSave() async {
    if ((_inputMode == InputMode.jarakTempuh && _jarakController.text.isEmpty) ||
        (_inputMode == InputMode.odometerTerakhir && _odometerController.text.isEmpty) ||
        _durasiController.text.isEmpty ||
        _selectedDate == null ||
        _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedVehicle!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kendaraan tidak valid. Silakan pilih kendaraan lain.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    double finalDistance = 0;
    if (_inputMode == InputMode.jarakTempuh) {
      final distance = double.tryParse(_jarakController.text);
      if (distance == null || distance <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jarak harus berupa angka yang valid'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      finalDistance = distance;
    } else {
      final inputOdo = double.tryParse(_odometerController.text);
      if (inputOdo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Odometer harus berupa angka yang valid'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      final currentOdo = _selectedVehicle!.odometer ?? 0;
      final selisih = inputOdo - currentOdo;
      if (selisih <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Angka odometer harus lebih besar dari odometer saat ini ($currentOdo km)'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      finalDistance = selisih;
    }

    final duration = int.tryParse(_durasiController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Durasi harus berupa angka yang valid'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _tripService.addManualDistance(
        vehicleId: _selectedVehicle!.id!,
        distanceKm: finalDistance,
        tripDate: _selectedDate!,
        durationMinutes: duration,
      );

      if (result != null && mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.distanceSaved),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menyimpan jarak. Silakan coba lagi.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error saving manual distance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Terjadi kesalahan. Silakan coba lagi.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Show loading indicator while fetching vehicles
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.inputDistance,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.addMissedTrip,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Mode Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _inputMode = InputMode.jarakTempuh),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _inputMode == InputMode.jarakTempuh ? colorScheme.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Jarak Tempuh',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 14,
                                        fontWeight: _inputMode == InputMode.jarakTempuh ? FontWeight.w700 : FontWeight.w400,
                                        color: _inputMode == InputMode.jarakTempuh ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _inputMode = InputMode.odometerTerakhir),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _inputMode == InputMode.odometerTerakhir ? colorScheme.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Odometer Terakhir',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 14,
                                        fontWeight: _inputMode == InputMode.odometerTerakhir ? FontWeight.w700 : FontWeight.w400,
                                        color: _inputMode == InputMode.odometerTerakhir ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_inputMode == InputMode.jarakTempuh) ...[
                        _buildLabel(l10n.distanceTraveled, required: true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _jarakController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontFamily: 'Arial', fontSize: 18, color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Misal: 15.5',
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.outline, width: 0.65),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.outline, width: 0.65),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.primary, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ] else ...[
                        _buildLabel('Angka Odometer Saat Ini (km)', required: true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _odometerController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontFamily: 'Arial', fontSize: 18, color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Lihat angka speedometer',
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.outline, width: 0.65),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.outline, width: 0.65),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colorScheme.primary, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sistem otomatis menghitung selisih dari odometer motor saat ini (${_selectedVehicle?.odometer ?? 0} km)',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Tanggal Perjalanan
                      _buildLabel(l10n.tripDate, required: true),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border.all(color: colorScheme.outline, width: 0.65),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20, color: colorScheme.secondary),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null ? l10n.selectDate : _formatDate(_selectedDate!),
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                  color: _selectedDate == null ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Durasi Perjalanan
                      _buildLabel('Durasi Perjalanan (Menit)', required: true),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _durasiController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontFamily: 'Arial', fontSize: 18, color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Estimasi perjalanan dalam menit',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colorScheme.outline, width: 0.65),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colorScheme.outline, width: 0.65),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colorScheme.primary, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 0.65),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Data akan disimpan untuk kalkulasi jarak dan Fuzzy Logic secara akurat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurface,
                                side: BorderSide(
                                  color: colorScheme.outline,
                                  width: 0.65,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                l10n.cancel,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  14,
                                ),
                                elevation: 0,
                                shadowColor: Colors.black.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      l10n.save,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: colorScheme.onSurface,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.error,
            ),
          ),
      ],
    );
  }
}
