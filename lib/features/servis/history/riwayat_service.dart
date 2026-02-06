import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../widget/bottom_navbar.dart';
import '../../widget/page_transition.dart';
import '../service.dart';
import '../schedule/jadwal.dart';
import 'tambah_riwayat_service.dart';
import 'edit_riwayat_service.dart';

class RiwayatServicePage extends StatefulWidget {
  const RiwayatServicePage({super.key});

  @override
  State<RiwayatServicePage> createState() => _RiwayatServicePageState();
}

class _RiwayatServicePageState extends State<RiwayatServicePage> {
  final List<Map<String, dynamic>> _serviceHistory = [
    {
      'title': 'Oil Change',
      'date': '15 Januari 2026',
      'cost': 'Rp 295.000',
      'odometer': '8000 km',
      'workshop': 'Kawasaki Authorized',
      'notes': 'Full synthetic oil used',
      'icon': Icons.settings,
    },
    {
      'title': 'Tire Replacement',
      'date': '10 Desember 2025',
      'cost': 'Rp 1.180.000',
      'odometer': '7500 km',
      'workshop': 'Tire Pro',
      'notes': 'Front and rear tires replaced',
      'icon': Icons.settings,
    },
    {
      'title': 'Chain Adjustment',
      'date': '5 November 2025',
      'cost': 'Rp 125.000',
      'odometer': '7200 km',
      'workshop': 'Local Garage',
      'notes': 'Chain cleaned and lubricated',
      'icon': Icons.settings,
    },
    {
      'title': 'Oil Change',
      'date': '20 Oktober 2025',
      'cost': 'Rp 295.000',
      'odometer': '6500 km',
      'workshop': 'Kawasaki Authorized',
      'notes': 'Regular maintenance',
      'icon': Icons.settings,
    },
  ];

  int _calculateTotalCost() {
    int total = 0;
    for (var service in _serviceHistory) {
      String costStr = service['cost'].replaceAll(RegExp(r'[^\d]'), '');
      total += int.parse(costStr);
    }
    return total;
  }

  String _formatCurrency(int amount) {
    return 'Rp. ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            l10n.deleteServiceRecord,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            '${l10n.confirmDeleteService} "${service['title']}"?',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _serviceHistory.remove(service);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.delete),
                    backgroundColor: colorScheme.error,
                  ),
                );
              },
              child: Text(
                l10n.delete,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    _buildAddButton(),
                    const SizedBox(height: 16),
                    _buildTotalCostCard(),
                    const SizedBox(height: 16),
                    ..._serviceHistory.map(
                      (service) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildServiceCard(service),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(selectedIndex: 1),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.service,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    icon: Icons.dashboard_outlined,
                    label: l10n.overview,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        SmoothPageRoute(page: const MaintenancePage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    icon: Icons.calendar_today_outlined,
                    label: l10n.schedule,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        SmoothPageRoute(page: const JadwalPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    icon: Icons.history,
                    label: l10n.history,
                    isActive: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : colorScheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isActive ? Colors.white : colorScheme.textSecondary,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SmoothPageRoute(page: const TambahRiwayatServicePage()),
        );
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.addServiceRecord,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCostCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalCost,
            style: TextStyle(color: colorScheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(_calculateTotalCost()),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'],
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: colorScheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          service['date'],
                          style: TextStyle(
                            color: colorScheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                service['cost'],
                style: TextStyle(color: colorScheme.primary, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Odometer',
                    style: TextStyle(
                      color: colorScheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    service['odometer'],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workshop',
                    style: TextStyle(
                      color: colorScheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    service['workshop'],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: colorScheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  service['notes'],
                  style: TextStyle(
                    color: colorScheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(
                          page: EditRiwayatServicePage(serviceData: service),
                        ),
                      );
                    },
                    child: Container(
                      height: 41,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDeleteConfirmation(context, service),
                    child: Container(
                      height: 41,
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.2),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
