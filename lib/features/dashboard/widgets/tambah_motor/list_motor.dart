import 'package:flutter/material.dart';
import 'tambah_motor.dart';
import 'edit_motor.dart';
import '../../../widget/page_transition.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/vehicle_service.dart';
import '../../../../core/model/vehicle_model.dart';

class ListMotorPage extends StatefulWidget {
  const ListMotorPage({super.key});

  @override
  State<ListMotorPage> createState() => _ListMotorPageState();
}

class _ListMotorPageState extends State<ListMotorPage> {
  final _vehicleService = VehicleService();
  List<VehicleModel> vehicles = [];
  bool _isLoading = false;
  bool _hasChanges = false; // Track if any vehicle changes occurred

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);

    try {
      final fetchedVehicles = await _vehicleService.getAllVehicles();
      if (mounted) {
        setState(() {
          vehicles = fetchedVehicles;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat kendaraan: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Handle system back button/gesture
          Navigator.of(context).pop(_hasChanges);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context, _hasChanges),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 16,
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
                                l10n.myVehicles,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.selectOrManageVehicles,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Vehicle List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bike,
                            size: 64,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada kendaraan',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan kendaraan pertama Anda',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                      itemCount: vehicles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return _buildVehicleCard(
                          context: context,
                          vehicle: vehicle,
                        );
                      },
                    ),
            ),
          ],
        ),
        // Floating Action Button
        floatingActionButton: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 50,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  SmoothPageRoute(page: const TambahMotorPage()),
                );
                // Reload vehicles if a vehicle was added
                if (result == true) {
                  _hasChanges = true;
                  _loadVehicles();
                }
              },
              borderRadius: BorderRadius.circular(999),
              child: Icon(Icons.add, size: 24, color: colorScheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({
    required BuildContext context,
    required VehicleModel vehicle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isActive = vehicle.isPrimary;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          _showSwitchVehicleDialog(vehicle);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
            width: isActive ? 2 : 0.65,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name, badge, and edit button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        vehicle.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.active,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          SmoothPageRoute(
                            page: EditMotorPage(
                              vehicleId: vehicle.id!,
                              name: vehicle.title,
                              brand: vehicle.make,
                              model: vehicle.model,
                              year: vehicle.year.toString(),
                              odometer: vehicle.odometer.toString(),
                              isMainVehicle: vehicle.isPrimary,
                              tipeMotor: vehicle.tipeMotor,
                              kapasitasCc: vehicle.kapasitasCc,
                              licensePlate: vehicle.licensePlate,
                              color: vehicle.color,
                              defaultBeban: vehicle.defaultBeban,
                              defaultPenumpang: vehicle.defaultPenumpang,
                              defaultGayaBerkendara:
                                  vehicle.defaultGayaBerkendara,
                              defaultKondisiJalan: vehicle.defaultKondisiJalan,
                              defaultMedan: vehicle.defaultMedan,
                            ),
                          ),
                        );
                        // Reload vehicles if a vehicle was updated
                        if (result == true) {
                          _hasChanges = true;
                          _loadVehicles();
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showDeleteConfirmation(vehicle);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Vehicle details
            Text(
              '${vehicle.make} ${vehicle.model} • ${vehicle.year}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Odometer badge — full width, left-aligned to match details text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Odometer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${vehicle.odometer.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')} km',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSwitchVehicleDialog(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.switchVehicle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            l10n.switchVehicleConfirm(vehicle.title),
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Mengubah kendaraan utama...'),
                    duration: const Duration(seconds: 1),
                  ),
                );

                try {
                  await _vehicleService.setPrimaryVehicle(vehicle.id!);

                  // Mark that changes occurred
                  _hasChanges = true;

                  // Reload vehicles
                  await _loadVehicles();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${vehicle.title}${l10n.nowActiveVehicle}',
                        ),
                        backgroundColor: colorScheme.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gagal mengubah kendaraan utama: ${e.toString()}',
                        ),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                l10n.yesSwitch,
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteVehicle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            l10n.deleteVehicleConfirm(vehicle.title),
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Menghapus kendaraan...'),
                    duration: const Duration(seconds: 1),
                  ),
                );

                try {
                  await _vehicleService.deleteVehicle(vehicle.id!);

                  // Mark that changes occurred
                  _hasChanges = true;

                  // Reload vehicles
                  await _loadVehicles();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${vehicle.title}${l10n.vehicleDeleted}'),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gagal menghapus kendaraan: ${e.toString()}',
                        ),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                l10n.delete,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
