import 'package:flutter/material.dart';
import 'tambah_motor.dart';
import 'edit_motor.dart';
import '../../../widget/page_transition.dart';
import '../../../../l10n/app_localizations.dart';

class ListMotorPage extends StatefulWidget {
  const ListMotorPage({super.key});

  @override
  State<ListMotorPage> createState() => _ListMotorPageState();
}

class _ListMotorPageState extends State<ListMotorPage> {
  // Sample data
  final List<Map<String, dynamic>> vehicles = [
    {
      'name': 'My Ninja',
      'brand': 'Kawasaki',
      'model': 'Ninja 250',
      'year': '2022',
      'odometer': '8,450',
      'isActive': true,
    },
    {
      'name': 'Daily Commuter',
      'brand': 'Honda',
      'model': 'PCX 160',
      'year': '2023',
      'odometer': '5,200',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
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
                        onTap: () => Navigator.pop(context),
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
              itemCount: vehicles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return _buildVehicleCard(
                  context: context,
                  name: vehicle['name'],
                  brand: vehicle['brand'],
                  model: vehicle['model'],
                  year: vehicle['year'],
                  odometer: vehicle['odometer'],
                  isActive: vehicle['isActive'],
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
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: const TambahMotorPage()),
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Icon(Icons.add, size: 24, color: colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({
    required BuildContext context,
    required String name,
    required String brand,
    required String model,
    required String year,
    required String odometer,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          _showSwitchVehicleDialog(name);
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
                        name,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(
                            page: EditMotorPage(
                              name: name,
                              brand: brand,
                              model: model,
                              year: year,
                              odometer: odometer,
                              isMainVehicle: isActive,
                            ),
                          ),
                        );
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
                        _showDeleteConfirmation(name);
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
              '$brand $model • $year',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Odometer badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    '$odometer km',
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

  void _showSwitchVehicleDialog(String vehicleName) {
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
            l10n.switchVehicleConfirm(vehicleName),
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
              onPressed: () {
                // TODO: Implement switch active vehicle
                setState(() {
                  // Update active vehicle logic here
                  for (var vehicle in vehicles) {
                    vehicle['isActive'] = vehicle['name'] == vehicleName;
                  }
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$vehicleName${l10n.nowActiveVehicle}'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
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

  void _showDeleteConfirmation(String vehicleName) {
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
            l10n.deleteVehicleConfirm(vehicleName),
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
              onPressed: () {
                // TODO: Implement delete vehicle
                setState(() {
                  vehicles.removeWhere(
                    (vehicle) => vehicle['name'] == vehicleName,
                  );
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$vehicleName${l10n.vehicleDeleted}'),
                    backgroundColor: colorScheme.error,
                  ),
                );
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
