import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorcycle_management/core/utils/app_theme.dart';
import '../../../core/services/service_history_service.dart';
import '../../../core/model/service_history_model.dart';
import 'package:intl/intl.dart';
import 'edit_riwayat_service.dart';
import '../../widget/page_transition.dart';

class DetailRiwayatServicePage extends StatefulWidget {
  final int serviceId;

  const DetailRiwayatServicePage({super.key, required this.serviceId});

  @override
  State<DetailRiwayatServicePage> createState() =>
      _DetailRiwayatServicePageState();
}

class _DetailRiwayatServicePageState extends State<DetailRiwayatServicePage> {
  final _historyService = ServiceHistoryService();
  ServiceHistoryModel? _serviceHistory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final history = await _historyService.getHistoryById(widget.serviceId);
      print('🖼️ Receipt URL: ${history.receiptUrl}');
      if (mounted) {
        setState(() {
          _serviceHistory = history;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print('❌ Failed to load service history detail: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final value = amount is int ? amount : (amount as num).toInt();
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _showDeleteConfirmation() async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Hapus Riwayat',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Yakin ingin menghapus riwayat servis ini?',
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
                'Batal',
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
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && _serviceHistory?.id != null) {
      try {
        await _historyService.deleteHistory(_serviceHistory!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Riwayat servis berhasil dihapus'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.pop(context, true); // Return to previous page with success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showImageModal(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Foto tidak dapat dimuat',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'File mungkin tidak tersimpan di server',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat data',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: colorScheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _serviceHistory == null
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _serviceHistory?.serviceName ?? 'Detail Servis',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Detail Riwayat Servis',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final service = _serviceHistory!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateSection(service, colorScheme),
          const SizedBox(height: 16),
          _buildOdometerSection(service, colorScheme),
          const SizedBox(height: 16),
          _buildCostSection(service, colorScheme),
          const SizedBox(height: 16),
          _buildWorkshopSection(service, colorScheme),
          const SizedBox(height: 16),
          _buildNotesSection(service, colorScheme),
          const SizedBox(height: 16),
          _buildPhotoSection(service, colorScheme),
          const SizedBox(height: 16),
          _buildActionButtons(service, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    final dateStr = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(service.serviceDate);

    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildInfoRow(
        icon: Icons.calendar_today_outlined,
        label: 'Tanggal Servis',
        value: dateStr,
        colorScheme: colorScheme,
      ),
    );
  }

  Widget _buildOdometerSection(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildInfoRow(
        icon: Icons.speed_outlined,
        label: 'Odometer',
        value: service.odometer != null
            ? '${service.odometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km'
            : '-',
        colorScheme: colorScheme,
      ),
    );
  }

  Widget _buildCostSection(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildInfoRow(
        icon: Icons.attach_money_outlined,
        label: 'Total Biaya',
        value: _formatCurrency(service.cost),
        colorScheme: colorScheme,
        valueColor: colorScheme.primary,
        valueFontSize: 18,
        valueFontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    Color? valueColor,
    double? valueFontSize,
    FontWeight? valueFontWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: valueFontSize ?? 16,
                  fontWeight: valueFontWeight ?? FontWeight.w400,
                  color: valueColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopSection(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    if (service.serviceProvider == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.store_outlined,
            size: 20,
            color: colorScheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bengkel',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.serviceProvider!,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    final notesText = (service.notes == null || service.notes!.isEmpty)
        ? '-'
        : service.notes!;

    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: colorScheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Catatan',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notesText,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.secondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    final hasPhoto =
        service.receiptUrl != null && service.receiptUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                    color: colorScheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Foto Bukti Servis',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (hasPhoto)
                Text(
                  '1 foto',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasPhoto)
            GestureDetector(
              onTap: () => _showImageModal(service.receiptUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 0.65,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.network(
                    service.receiptUrl!,
                    width: double.infinity,
                    height: 264,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 264,
                        color: colorScheme.surfaceContainerLow,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Image load error: $error');
                      print('🔗 URL: ${service.receiptUrl}');
                      return Container(
                        width: double.infinity,
                        height: 264,
                        color: colorScheme.surfaceContainerLow,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off_outlined,
                                  size: 48,
                                  color: colorScheme.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Foto tidak dapat dimuat',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'File mungkin tidak tersimpan di server',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 11,
                                    color: colorScheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          else
            Text(
              '-',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colorScheme.secondary,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ServiceHistoryModel service,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      height: 65,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  SmoothPageRoute(
                    page: EditRiwayatServicePage(
                      serviceData: {
                        'id': service.id,
                        'vehicleId': service.vehicleId,
                        'type': service.serviceName,
                        'serviceDate': service.serviceDate.toIso8601String(),
                        'odometer': service.odometer,
                        'cost': service.cost,
                        'serviceProvider': service.serviceProvider,
                        'notes': service.notes,
                        'receiptUrl': service.receiptUrl,
                      },
                    ),
                  ),
                );
                if (result == true) {
                  _loadData(); // Reload data if edit was successful
                  if (mounted) {
                    // Also notify parent screen to reload
                    Navigator.pop(context, true);
                  }
                }
              },
              child: Container(
                height: 57,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _showDeleteConfirmation,
              child: Container(
                height: 57,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.65,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
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
}
