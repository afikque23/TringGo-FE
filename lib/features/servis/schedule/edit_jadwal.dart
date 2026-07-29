import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/service_schedule_service.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/model/service_schedule_model.dart';

class EditJadwalPage extends StatefulWidget {
  final ServiceScheduleModel schedule;

  const EditJadwalPage({super.key, required this.schedule});

  @override
  State<EditJadwalPage> createState() => _EditJadwalPageState();
}

class _EditJadwalPageState extends State<EditJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  final _scheduleService = ServiceScheduleService();
  final _vehicleService = VehicleService();

  late final TextEditingController _namaController;
  late final TextEditingController _kmController;
  late final TextEditingController _bulanController;
  late final TextEditingController _catatanController;

  late bool _isJarakSelected;
  bool _reminderEnabled = true;
  bool _isLoading = false;
  String _reminderBefore = '';
  DateTime? _selectedDate;

  List<String> _reminderOptionsJarak = [];
  List<String> _reminderOptionsWaktu = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _namaController = TextEditingController(
      text: widget.schedule.serviceName ?? '',
    );
    _isJarakSelected = widget.schedule.intervalType == 'mileage';

    if (_isJarakSelected) {
      _kmController = TextEditingController(
        text: widget.schedule.intervalValue.toString(),
      );
      _bulanController = TextEditingController();
    } else {
      _kmController = TextEditingController();
      _bulanController = TextEditingController(
        text: widget.schedule.intervalValue.toString(),
      );
      _selectedDate = widget.schedule.nextServiceDate;
    }

    _catatanController = TextEditingController(
      text: widget.schedule.notes ?? '',
    );
    _reminderEnabled = widget.schedule.reminderEnabled;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kmController.dispose();
    _bulanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _reminderBefore = _isJarakSelected
          ? l10n.reminderDistance200km
          : l10n.reminderTime1Week;
      _reminderOptionsJarak = [
        l10n.reminderDistance100km,
        l10n.reminderDistance200km,
        l10n.reminderDistance300km,
        l10n.reminderDistance500km,
      ];
      _reminderOptionsWaktu = [
        l10n.reminderTime1Day,
        l10n.reminderTime3Days,
        l10n.reminderTime1Week,
        l10n.reminderTime2Weeks,
        l10n.reminderTime1Month,
      ];
    });
  }

  /// Map reminder UI text to backend reminder_option_id
  /// Based on ReminderOptionSeeder data
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
                              l10n.editServiceSchedule,
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
                              l10n.updateScheduleReminder,
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

                        // Jenis Jadwal (Read-only - cannot change type after creation)
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
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 0.65,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isJarakSelected
                                        ? Icons.route
                                        : Icons.schedule,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isJarakSelected
                                        ? l10n.distance
                                        : l10n.time,
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
                                  hintText: l10n.exampleKm10000,
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
                                l10n.serviceDate,
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
                                      Text(
                                        _selectedDate == null
                                            ? l10n.selectDate
                                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 16,
                                          color: _selectedDate == null
                                              ? colorScheme.onSurface
                                                    .withValues(alpha: 0.5)
                                              : colorScheme.onSurface,
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.notifications_outlined,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
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
                                    ],
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
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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

                        // Bottom Buttons
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
                                onPressed: _isLoading ? null : _updateSchedule,
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
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimary,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        l10n.update,
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

  Future<void> _updateSchedule() async {
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
      if (_bulanController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon isi interval waktu'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mohon pilih tanggal servis berikutnya'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Get primary vehicle for calculation
      final vehicle = await _vehicleService.getPrimaryVehicle();
      if (vehicle == null) {
        throw Exception('Tidak ada kendaraan utama ditemukan');
      }

      // Parse values
      final serviceName = _namaController.text.trim();
      final intervalType = _isJarakSelected ? 'mileage' : 'time';
      final intervalValue = _isJarakSelected
          ? int.tryParse(_kmController.text) ?? 0
          : int.tryParse(_bulanController.text) ?? 0;

      // Map reminder text to reminder_option_id
      int? reminderOptionId;
      if (_reminderEnabled && _reminderBefore.isNotEmpty) {
        reminderOptionId = _getReminderOptionId(
          _reminderBefore,
          _isJarakSelected,
        );
      }

      // Calculate next service values
      int? nextServiceMileage;
      int? lastServiceMileage;
      DateTime? nextServiceDate;

      if (_isJarakSelected) {
        // Keep last service mileage, only update next based on new interval
        lastServiceMileage =
            widget.schedule.lastServiceMileage ?? vehicle.odometer;
        nextServiceMileage = lastServiceMileage + intervalValue;
      } else {
        nextServiceDate = _selectedDate;
      }

      // Get notes (don't append reminder info - it's stored separately)
      final notes = _catatanController.text.trim();

      // Create updated schedule model
      final updatedSchedule = widget.schedule.copyWith(
        serviceName: serviceName.isNotEmpty ? serviceName : null,
        serviceTypeId: widget.schedule.serviceTypeId ?? 1,
        intervalType: intervalType,
        intervalValue: intervalValue,
        lastServiceMileage: lastServiceMileage,
        nextServiceMileage: nextServiceMileage,
        nextServiceDate: nextServiceDate,
        reminderThreshold: reminderOptionId,
        reminderEnabled: _reminderEnabled,
        notes: notes.isNotEmpty ? notes : null,
      );

      // Call API
      await _scheduleService.updateSchedule(
        widget.schedule.id!,
        updatedSchedule,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.scheduleUpdated),
          backgroundColor: colorScheme.primary,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate: ${e.toString()}'),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
