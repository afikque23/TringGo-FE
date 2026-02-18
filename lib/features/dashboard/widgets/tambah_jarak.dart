import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/model/vehicle_model.dart';

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

  final TextEditingController _jarakController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
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
    _catatanController.dispose();
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
    if (_jarakController.text.isEmpty ||
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

    // Validate vehicle has an ID
    if (_selectedVehicle!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Kendaraan tidak valid. Silakan pilih kendaraan lain.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Validate distance value
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

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _tripService.addManualDistance(
        vehicleId: _selectedVehicle!.id!,
        distanceKm: distance,
        tripDate: _selectedDate!,
        notes: _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      if (result != null && mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context, true); // Return true to indicate success
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
                      // Jarak Input
                      _buildLabel(l10n.distanceTraveled, required: true),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _jarakController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 18,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.distancePlaceholder,
                          hintStyle: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 18,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outline,
                              width: 0.65,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outline,
                              width: 0.65,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.distanceHint,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tanggal Perjalanan
                      _buildLabel(l10n.tripDate, required: true),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border.all(
                              color: colorScheme.outline,
                              width: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null
                                    ? l10n.selectDate
                                    : _formatDate(_selectedDate!),
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                  color: _selectedDate == null
                                      ? colorScheme.onSurface.withOpacity(0.5)
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Kendaraan Dropdown
                      _buildLabel(l10n.vehicle, required: true),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _vehicles.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Text(
                                  'Tidak ada kendaraan tersedia',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 18,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<VehicleModel>(
                                  value: _selectedVehicle,
                                  hint: Row(
                                    children: [
                                      Icon(
                                        Icons.directions_bike,
                                        size: 20,
                                        color: colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.selectVehicle,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 18,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: colorScheme.secondary,
                                  ),
                                  dropdownColor: colorScheme.surface,
                                  isExpanded: true,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 18,
                                    color: colorScheme.onSurface,
                                  ),
                                  items: _vehicles.map((VehicleModel vehicle) {
                                    return DropdownMenuItem<VehicleModel>(
                                      value: vehicle,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.directions_bike,
                                            size: 20,
                                            color: colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              vehicle.title,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (VehicleModel? newValue) {
                                    setState(() {
                                      _selectedVehicle = newValue;
                                    });
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Catatan (Optional)
                      Row(
                        children: [
                          Text(
                            l10n.notesLabel,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${l10n.optional})',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _catatanController,
                        maxLines: 4,
                        minLines: 4,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.notesPlaceholder,
                          hintStyle: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outline,
                              width: 0.65,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outline,
                              width: 0.65,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                            width: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.distanceWillBeAdded,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.64,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
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
