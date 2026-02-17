import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../widget/bottom_navbar.dart';
import '../../widget/page_transition.dart';
import '../service.dart';
import '../schedule/jadwal.dart';
import 'tambah_riwayat_service.dart';
import 'detail_riwayat_service.dart';
import '../../../core/services/service_history_service.dart';
import '../../../core/model/service_history_model.dart';
import 'package:intl/intl.dart';

class RiwayatServicePage extends StatefulWidget {
  const RiwayatServicePage({super.key});

  @override
  State<RiwayatServicePage> createState() => _RiwayatServicePageState();
}

class _RiwayatServicePageState extends State<RiwayatServicePage> {
  final _historyService = ServiceHistoryService();
  List<ServiceHistoryModel> _serviceHistory = [];
  Map<String, dynamic>? _costSummary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final histories = await _historyService.getAllHistories();
      final summary = await _historyService.getCostSummary();
      print('📊 Loaded ${histories.length} service histories');
      if (mounted) {
        setState(() {
          _serviceHistory = histories;
          _costSummary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Failed to load histories: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  int _calculateTotalCost() {
    if (_costSummary == null) return 0;
    final total = _costSummary!['total_cost'];
    if (total == null) return 0;
    return total is int ? total : (total as num).toInt();
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp. 0';
    final value = amount is int ? amount : (amount as num).toInt();
    return 'Rp. ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ServiceHistoryModel service,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
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
            '${l10n.confirmDeleteService} "${service.serviceName}"?',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
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
              onPressed: () => Navigator.pop(context, true),
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

    if (confirmed == true && service.id != null) {
      try {
        await _historyService.deleteHistory(service.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Riwayat servis berhasil dihapus'),
              backgroundColor: colorScheme.primary,
            ),
          );
          _loadData(); // Reload data
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: \${e.toString()}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Column(
                          children: [
                            _buildAddButton(),
                            const SizedBox(height: 16),
                            _buildTotalCostCard(),
                            const SizedBox(height: 16),
                            if (_serviceHistory.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Text(
                                  'Belum ada riwayat servis',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              )
                            else
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          SmoothPageRoute(page: const TambahRiwayatServicePage()),
        );
        if (result == true) {
          _loadData(); // Reload data if add was successful
        }
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

  Widget _buildServiceCard(ServiceHistoryModel service) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Format date
    final dateStr = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(service.serviceDate);

    // Format cost
    final costStr = service.cost != null ? _formatCurrency(service.cost!) : '-';

    // Format mileage
    final mileageStr = service.odometer != null
        ? '${service.odometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} KM'
        : '-';

    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with service name and cost
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          service.serviceName,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: colorScheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: colorScheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                costStr,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Detail rows
          Column(
            children: [
              if (service.odometer != null)
                _buildDetailRow('Odometer', mileageStr, colorScheme),
              if (service.odometer != null) const SizedBox(height: 8),
              if (service.serviceProvider != null)
                _buildDetailRow(
                  'Bengkel',
                  service.serviceProvider!,
                  colorScheme,
                ),
            ],
          ),
          // Notes section (if available)
          if (service.notes != null && service.notes!.isNotEmpty) ...[
            const SizedBox(height: 8.65),
            Container(
              padding: const EdgeInsets.only(top: 8.65),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.65,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: colorScheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.notes!,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: colorScheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // View details button
          const SizedBox(height: 12.65),
          Container(
            padding: const EdgeInsets.only(top: 12.65),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
              ),
            ),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  SmoothPageRoute(
                    page: DetailRiwayatServicePage(serviceId: service.id!),
                  ),
                );
                // Reload data if any changes were made (edit or delete)
                if (result == true) {
                  _loadData();
                }
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            color: colorScheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Arial',
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
