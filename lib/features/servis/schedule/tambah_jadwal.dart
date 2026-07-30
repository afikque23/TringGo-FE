import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/service_schedule_service.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/model/service_schedule_model.dart';

import '../../../core/model/tip_model.dart';

class TambahJadwalPage extends StatefulWidget {
  final TipModel? templateTip;
  
  const TambahJadwalPage({super.key, this.templateTip});

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  final _scheduleService = ServiceScheduleService();
  final _vehicleService = VehicleService();

  final _namaController = TextEditingController();
  final _kmController = TextEditingController();
  final _bulanController = TextEditingController();
  final _catatanController = TextEditingController();
  final _customReminderController = TextEditingController();

  bool _isJarakSelected = true; // true = jarak, false = waktu
  bool _reminderEnabled = true;
  String _reminderBefore = '';
  DateTime? _selectedDate;

  List<String> _reminderOptionsJarak = [];
  List<String> _reminderOptionsWaktu = [];
  final String _customOption = '✏️ Custom (Input Manual)';

  @override
  void dispose() {
    _namaController.dispose();
    _kmController.dispose();
    _bulanController.dispose();
    _catatanController.dispose();
    _customReminderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });

    // Listener: Jika user mengetik interval bulan, kosongkan tanggal yang dipilih
    _bulanController.addListener(() {
      if (_bulanController.text.isNotEmpty && _selectedDate != null) {
        setState(() {
          _selectedDate = null;
        });
      }
    });
  }

  void _initializeData() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _reminderBefore = l10n.reminderDistance200km;
      _reminderOptionsJarak = [
        l10n.reminderDistance100km,
        l10n.reminderDistance200km,
        l10n.reminderDistance300km,
        l10n.reminderDistance500km,
        _customOption, // Custom option
      ];
      _reminderOptionsWaktu = [
        l10n.reminderTime1Day,
        l10n.reminderTime3Days,
        l10n.reminderTime1Week,
        l10n.reminderTime2Weeks,
        l10n.reminderTime1Month,
        _customOption, // Custom option
      ];
      
      // Load data from template if provided
      if (widget.templateTip != null) {
        final tip = widget.templateTip!;
        _namaController.text = tip.title;
        
        if (tip.importantNotes != null) {
          _catatanController.text = tip.importantNotes!;
        }
        
        if (tip.maintenanceInterval != null) {
          final interval = tip.maintenanceInterval!;
          
          // Populate both fields if available so user can switch tabs freely
          if (interval.distanceKm != null && interval.distanceKm! > 0) {
            _kmController.text = interval.distanceKm.toString();
          }
          if (interval.timeMonths != null && interval.timeMonths! > 0) {
            _bulanController.text = interval.timeMonths.toString();
          }
          
          // Determine which tab to show by default
          if (interval.distanceKm != null && interval.distanceKm! > 0) {
            _isJarakSelected = true;
          } else if (interval.timeMonths != null && interval.timeMonths! > 0) {
            _isJarakSelected = false;
            _reminderBefore = l10n.reminderTime1Week; // Switch default reminder for time
          }
        }
      }
    });
  }

  /// Map reminder UI text to backend reminder_option_id
  /// Based on ReminderOptionSeeder data
  // ignore: unused_element
  int? _getReminderOptionId(String reminderText, bool isJarak) {
    final l10n = AppLocalizations.of(context)!;

    if (isJarak) {
      // Jarak/KM based reminders (IDs: 1=100km, 2=200km, 3=300km, 4=500km, 5=1000km)
      if (reminderText == l10n.reminderDistance100km) return 1; // 100 km
      if (reminderText == l10n.reminderDistance200km) return 2; // 200 km
      if (reminderText == l10n.reminderDistance300km) return 3; // 300 km
      if (reminderText == l10n.reminderDistance500km) return 4; // 500 km
    } else {
      // Time based reminders (IDs: 6=3days, 7=7days, 8=14days, 9=1week, 10=2weeks, etc)
      if (reminderText == l10n.reminderTime1Day) {
        return 6; // 1 day -> map to 3 days (closest)
      }
      if (reminderText == l10n.reminderTime3Days) return 6; // 3 days
      if (reminderText == l10n.reminderTime1Week) return 7; // 7 days / 1 week
      if (reminderText == l10n.reminderTime2Weeks) {
        return 8; // 14 days / 2 weeks
      }
      if (reminderText == l10n.reminderTime1Month) return 11; // 1 month
    }

    return null; // No reminder
  }

  /// Get reminder threshold value (km or days before service)
  int? _getReminderThreshold(String reminderText, bool isJarak) {
    final l10n = AppLocalizations.of(context)!;

    // If custom option, get value from custom input field
    if (reminderText == _customOption) {
      final customValue = _customReminderController.text.trim();
      if (customValue.isEmpty) return null;
      return int.tryParse(customValue);
    }

    // Extract threshold from predefined options
    if (isJarak) {
      // Jarak/KM based reminders
      if (reminderText == l10n.reminderDistance100km) return 100;
      if (reminderText == l10n.reminderDistance200km) return 200;
      if (reminderText == l10n.reminderDistance300km) return 300;
      if (reminderText == l10n.reminderDistance500km) return 500;
    } else {
      // Time based reminders (in days)
      if (reminderText == l10n.reminderTime1Day) return 1;
      if (reminderText == l10n.reminderTime3Days) return 3;
      if (reminderText == l10n.reminderTime1Week) return 7;
      if (reminderText == l10n.reminderTime2Weeks) return 14;
      if (reminderText == l10n.reminderTime1Month) return 30;
    }

    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surfaceContainerHighest,
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
        _bulanController.clear(); // Hapus inputan bulan jika tanggal dipilih
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 14, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
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
                              l10n.addServiceSchedule,
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
                              l10n.setMaintenanceReminder,
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
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Perawatan
                        _buildInputField(
                          label: l10n.maintenanceName,
                          controller: _namaController,
                          hintText: l10n.exampleOilChange,
                          icon: Icons.build_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Mohon isi nama perawatan';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Jenis Jadwal
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.scheduleType,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTypeButton(
                                    label: l10n.distance,
                                    isSelected: _isJarakSelected,
                                    onTap: () {
                                      setState(() {
                                        _isJarakSelected = true;
                                        _reminderBefore =
                                            l10n.reminderDistance200km;
                                        _customReminderController.clear();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTypeButton(
                                    label: l10n.time,
                                    isSelected: !_isJarakSelected,
                                    onTap: () {
                                      setState(() {
                                        _isJarakSelected = false;
                                        _reminderBefore =
                                            l10n.reminderTime1Week;
                                        _customReminderController.clear();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Servis pada (km) - untuk tab Jarak
                        if (_isJarakSelected) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.serviceIntervalKm,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface,
                                  height: 1.43,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _kmController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Contoh: 5000',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      colorScheme.surfaceContainerHighest,
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
                                      width: 0.65,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.enterIntervalKm,
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
                          const SizedBox(height: 24),
                        ],

                        // Fields untuk tab Waktu
                        if (!_isJarakSelected) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.inMonths,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface,
                                  height: 1.43,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _bulanController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.exampleMonths6,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      colorScheme.surfaceContainerHighest,
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
                                      width: 0.65,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.orSelectSpecificDate,
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
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.serviceDate} (Opsional)',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface,
                                  height: 1.43,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedDate == null
                                              ? 'Kosongkan untuk dihitung otomatis'
                                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 16,
                                            color: _selectedDate == null
                                                ? colorScheme.onSurface
                                                      .withValues(alpha: 0.5)
                                                : colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Divider
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 0.65,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Pengingat Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.notifications_outlined,
                                          size: 20,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.reminder,
                                                style: TextStyle(
                                                  fontFamily: 'Arial',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: colorScheme.onSurface,
                                                  height: 1.43,
                                                ),
                                              ),
                                              const SizedBox(height: 0),
                                              Text(
                                                l10n.remindMeBeforeDue,
                                                style: TextStyle(
                                                  fontFamily: 'Arial',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      colorScheme.onSurfaceVariant,
                                                  height: 1.33,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _reminderEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _reminderEnabled = value;
                                      });
                                    },
                                    thumbColor: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    trackColor: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Ingatkan sebelum dropdown
                              if (_reminderEnabled) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.remindBefore,
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: colorScheme.onSurface,
                                        height: 1.43,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        border: Border.all(
                                          color: colorScheme.outline,
                                          width: 0.65,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _reminderBefore.isEmpty
                                            ? null
                                            : _reminderBefore,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                        ),
                                        dropdownColor:
                                            colorScheme.surfaceContainerHighest,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 16,
                                          color: colorScheme.onSurface,
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        items:
                                            (_isJarakSelected
                                                    ? _reminderOptionsJarak
                                                    : _reminderOptionsWaktu)
                                                .map((String value) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                })
                                                .toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _reminderBefore = newValue;
                                              // Clear custom input when switching from custom
                                              if (newValue != _customOption) {
                                                _customReminderController
                                                    .clear();
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // Custom reminder input field
                                if (_reminderBefore == _customOption) ...[
                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isJarakSelected
                                            ? 'Masukkan jarak (km)'
                                            : 'Masukkan waktu (hari)',
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: colorScheme.onSurface,
                                          height: 1.43,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _customReminderController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 16,
                                          color: colorScheme.onSurface,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: _isJarakSelected
                                              ? 'Contoh: 50 (untuk 50 km sebelumnya)'
                                              : 'Contoh: 7 (untuk 7 hari sebelumnya)',
                                          hintStyle: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                          filled: true,
                                          fillColor: colorScheme
                                              .surfaceContainerHighest,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorScheme.outline,
                                              width: 0.65,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorScheme.outline,
                                              width: 0.65,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorScheme.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorScheme.error,
                                              width: 0.65,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                        ),
                                        validator: (value) {
                                          if (_reminderEnabled &&
                                              _reminderBefore ==
                                                  _customOption &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return _isJarakSelected
                                                ? 'Masukkan jarak pengingat'
                                                : 'Masukkan waktu pengingat';
                                          }
                                          if (_reminderEnabled &&
                                              _reminderBefore ==
                                                  _customOption &&
                                              int.tryParse(value!) == null) {
                                            return 'Masukkan angka yang valid';
                                          }
                                          if (_reminderEnabled &&
                                              _reminderBefore ==
                                                  _customOption &&
                                              int.parse(value!) <= 0) {
                                            return 'Nilai harus lebih dari 0';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _isJarakSelected
                                                    ? 'Notifikasi akan muncul beberapa km sebelum jadwal servis'
                                                    : 'Notifikasi akan muncul beberapa hari sebelum jadwal servis',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme.onSurface,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Catatan
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.notesOptional,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _catatanController,
                              maxLines: 4,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.addNotesIfNeeded,
                                hintStyle: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
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
                                    width: 0.65,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bottom Buttons (inside form)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(
                                    color: colorScheme.outline,
                                    width: 0.65,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  l10n.cancel,
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveSchedule,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  elevation: 0,
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  l10n.save,
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.onPrimary,
                                    height: 1.5,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            height: 1.43,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            prefixIcon: Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
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
              borderSide: BorderSide(color: colorScheme.primary, width: 0.65),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              height: 1.43,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Validate required fields based on type
    if (_isJarakSelected && _kmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon isi interval jarak'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (!_isJarakSelected) {
      if (_bulanController.text.isEmpty && _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon isi interval waktu atau pilih tanggal servis'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }
      // Removed date validation - allow auto-calculation from interval
      // User can either:
      // 1. Input interval (months) only -> auto-calculate target date
      // 2. Input interval AND pick specific date -> use picked date
    }

    try {
      // Get primary vehicle from server first
      final vehicle = await _vehicleService.getPrimaryVehicle();
      if (vehicle == null) {
        throw Exception('Tidak ada kendaraan utama ditemukan');
      }

      // Debug: Log vehicle info
      print('Vehicle ID: ${vehicle.id}');
      print('Vehicle Title: ${vehicle.title}');
      print('Vehicle User ID: ${vehicle.userId}');

      // Check if vehicle has server ID (synced with server)
      if (vehicle.id == null || vehicle.id! <= 0) {
        throw Exception(
          'Kendaraan belum tersinkronisasi dengan server. Silakan hapus dan tambah ulang kendaraan Anda saat terhubung internet.',
        );
      }

      // Verify vehicle exists on server by trying to set as primary
      try {
        await _vehicleService.setPrimaryVehicle(vehicle.id!);
        print('Successfully verified vehicle on server');
      } catch (e) {
        print('ERROR: Vehicle not found on server: $e');
        throw Exception(
          'Kendaraan tidak ditemukan di server. Silakan:\n'
          '1. Pastikan Anda terhubung internet\n'
          '2. Buka menu Tambah Kendaraan\n'
          '3. Hapus kendaraan "${vehicle.title}"\n'
          '4. Tambahkan kembali kendaraan tersebut\n'
          '5. Coba buat jadwal servis lagi',
        );
      }

      // Parse values
      final serviceName = _namaController.text.trim();
      final intervalType = _isJarakSelected ? 'mileage' : 'time';
      final intervalValue = _isJarakSelected
          ? int.tryParse(_kmController.text) ?? 0
          : int.tryParse(_bulanController.text) ?? 0;

      // Map reminder text to reminder_option_id
      int? reminderThreshold;
      if (_reminderEnabled && _reminderBefore.isNotEmpty) {
        reminderThreshold = _getReminderThreshold(
          _reminderBefore,
          _isJarakSelected,
        );
      }

      // Calculate next service values
      int? nextServiceMileage;
      int? lastServiceMileage;
      DateTime? nextServiceDate;

      if (_isJarakSelected) {
        final currentMileage = vehicle.odometer;
        lastServiceMileage = currentMileage; // Set last service to current
        nextServiceMileage = currentMileage + intervalValue;
        
        // Frontend validation for reminder vs interval
        if (reminderThreshold != null && reminderThreshold >= intervalValue) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jarak pengingat ($reminderThreshold km) harus lebih kecil dari interval ($intervalValue km)'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }
      } else {
        nextServiceDate = _selectedDate;
        
        // Hitung target date sementara untuk validasi
        DateTime targetDate;
        if (nextServiceDate != null) {
          targetDate = nextServiceDate;
        } else {
          final now = DateTime.now();
          final monthsToAdd = intervalValue > 0 ? intervalValue : 1;
          targetDate = DateTime(now.year, now.month + monthsToAdd, now.day);
          if (!targetDate.isAfter(now)) {
            targetDate = DateTime(now.year, now.month + monthsToAdd + 1, now.day);
          }
        }
        
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
        final diffDays = targetDateOnly.difference(today).inDays;
        
        if (diffDays <= 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tanggal servis harus setelah hari ini (minimal besok)'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }
        
        if (reminderThreshold != null && reminderThreshold >= diffDays) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Waktu pengingat ($reminderThreshold hari) tidak boleh lebih lama dari sisa hari ($diffDays hari)'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }
      }

      // Get notes (don't append reminder info - it's stored separately)
      final notes = _catatanController.text.trim();

      // Create new schedule model
      final newSchedule = ServiceScheduleModel(
        vehicleId: vehicle.id!,
        serviceName: serviceName.isNotEmpty ? serviceName : null,
        serviceTypeId:
            1, // Default service type (you can make this dynamic later)
        intervalType: intervalType,
        intervalValue: intervalValue,
        lastServiceMileage: lastServiceMileage,
        nextServiceMileage: nextServiceMileage,
        nextServiceDate: nextServiceDate,
        reminderThreshold: reminderThreshold, // Use calculated threshold value
        reminderEnabled: _reminderEnabled,
        status: 'active',
        notes: notes.isNotEmpty ? notes : null,
      );

      // Debug: Log schedule data being sent
      print('Creating schedule for vehicle_id: ${vehicle.id}');
      print('Schedule type: $intervalType');
      print('Interval value: $intervalValue');

      // Call API
      await _scheduleService.createSchedule(newSchedule);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.scheduleSaved),
          backgroundColor: colorScheme.primary,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: \${e.toString()}'),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {}
  }
}
