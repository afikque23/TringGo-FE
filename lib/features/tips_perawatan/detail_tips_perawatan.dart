import 'package:flutter/material.dart';
import '../../core/model/tip_model.dart';
import '../../core/services/tips_service.dart';

class DetailTipsPerawatanPage extends StatefulWidget {
  final int tipId;

  const DetailTipsPerawatanPage({super.key, required this.tipId});

  @override
  State<DetailTipsPerawatanPage> createState() =>
      _DetailTipsPerawatanPageState();
}

class _DetailTipsPerawatanPageState extends State<DetailTipsPerawatanPage> {
  final _tipsService = TipsService();
  TipModel? _tip;
  bool _isLoading = true;
  String? _error;
  bool _isLiked = false;
  bool _isSaved = false;
  int _userRating = 0;
  int _likesCount = 0;
  int _bookmarksCount = 0;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  Future<void> _loadTip() async {
    try {
      final response = await _tipsService.getTipById(widget.tipId);
      if (!mounted) return;
      setState(() {
        _tip = response.data;
        _isLiked = response.data.isLiked;
        _isSaved = response.data.isBookmarked;
        _likesCount =
            response.data.isLiked && response.data.stats.likesCount == 0
            ? 1
            : response.data.stats.likesCount;
        _bookmarksCount =
            response.data.isBookmarked &&
                response.data.stats.bookmarksCount == 0
            ? 1
            : response.data.stats.bookmarksCount;
        _avgRating = response.data.stats.rating;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail tips';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final newLiked = !_isLiked;
    setState(() {
      _isLiked = newLiked;
      _likesCount = (_likesCount + (newLiked ? 1 : -1)).clamp(0, 999999);
    });
    try {
      final result = await _tipsService.toggleLike(widget.tipId, newLiked);
      if (!mounted) return;
      setState(() {
        _isLiked = (result['is_liked'] as bool?) ?? newLiked;
        final serverCount = (result['likes_count'] as num?)?.toInt();
        if (serverCount != null && serverCount > 0) {
          _likesCount = serverCount;
        }
        // else: keep the optimistic count; server returned 0 or null
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLiked = !newLiked;
        _likesCount += newLiked ? -1 : 1;
      });
    }
  }

  Future<void> _toggleSave() async {
    final newSaved = !_isSaved;
    setState(() {
      _isSaved = newSaved;
      _bookmarksCount = (_bookmarksCount + (newSaved ? 1 : -1)).clamp(
        0,
        999999,
      );
    });
    try {
      final result = await _tipsService.toggleBookmark(widget.tipId, newSaved);
      if (!mounted) return;
      setState(() {
        _isSaved = (result['is_bookmarked'] as bool?) ?? newSaved;
        final serverCount = (result['bookmarks_count'] as num?)?.toInt();
        if (serverCount != null && serverCount > 0) {
          _bookmarksCount = serverCount;
        }
        // else: keep the optimistic count; server returned 0 or null
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaved = !newSaved;
        _bookmarksCount += newSaved ? -1 : 1;
      });
    }
  }

  void _showRatingDialog() {
    int tempRating = _userRating;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF1E2939), width: 0.65),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Beri Rating',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seberapa berguna tips ini?',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        color: Color(0xFF99A1AF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              index < tempRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 40,
                              color: index < tempRating
                                  ? const Color(0xFFF0B100)
                                  : const Color(0xFF99A1AF),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ratingLabel(tempRating),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        color: Color(0xFF6B7C4F),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A0A0A),
                                border: Border.all(
                                  color: const Color(0xFF1E2939),
                                  width: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  color: Color(0xFF99A1AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: tempRating == 0
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    Navigator.pop(context);
                                    try {
                                      final result = await _tipsService.rateTip(
                                        widget.tipId,
                                        tempRating,
                                      );
                                      if (!mounted) return;
                                      setState(() {
                                        _userRating =
                                            (result['user_rating'] as num)
                                                .toInt();
                                        _avgRating =
                                            (result['average_rating'] as num)
                                                .toDouble();
                                      });
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Rating $_userRating bintang dikirim!',
                                          ),
                                          backgroundColor: const Color(
                                            0xFF6B7C4F,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      setState(() {
                                        _userRating = tempRating;
                                      });
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal mengirim rating, coba lagi',
                                          ),
                                          backgroundColor: Color(0xFFE53E3E),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: tempRating == 0
                                    ? const Color(0xFF6B7C4F).withOpacity(0.4)
                                    : const Color(0xFF6B7C4F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Kirim',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Kurang Bermanfaat';
      case 2:
        return 'Cukup Bermanfaat';
      case 3:
        return 'Bermanfaat';
      case 4:
        return 'Sangat Bermanfaat';
      case 5:
        return 'Luar Biasa!';
      default:
        return 'Pilih bintang di atas';
    }
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF99A1AF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Bagikan Tips',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 12),
              ...[
                ('WhatsApp', Icons.chat_outlined, 'whatsapp'),
                ('Instagram', Icons.camera_alt_outlined, 'instagram'),
                ('Twitter / X', Icons.tag, 'twitter'),
                ('Salin Tautan', Icons.link, 'copy_link'),
              ].map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(item.$2, color: const Color(0xFF6B7C4F)),
                  title: Text(
                    item.$1,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _tipsService
                        .shareTip(widget.tipId, item.$3)
                        .catchError((_) => <String, dynamic>{});
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildHeroSection(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B7C4F)),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFF99A1AF),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFF99A1AF)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _loadTip();
                          },
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(color: Color(0xFF6B7C4F)),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAuthorCard(),
                              const SizedBox(height: 12),
                              _buildStatsRow(),
                              const SizedBox(height: 12),
                              _buildActionButtons(),
                              const SizedBox(height: 12),
                              _buildInfoCards(),
                              const SizedBox(height: 16),
                              if ((_tip!.tools ?? []).isNotEmpty)
                                _buildToolsSection(),
                              if ((_tip!.tools ?? []).isNotEmpty)
                                const SizedBox(height: 16),
                              if ((_tip!.steps ?? []).isNotEmpty)
                                _buildStepsSection(),
                              if ((_tip!.steps ?? []).isNotEmpty)
                                const SizedBox(height: 16),
                              if (_tip!.importantNotes != null &&
                                  _tip!.importantNotes!.isNotEmpty)
                                _buildImportantNote(),
                              if (_tip!.importantNotes != null &&
                                  _tip!.importantNotes!.isNotEmpty)
                                const SizedBox(height: 16),
                              _buildTags(),
                              const SizedBox(height: 24),
                              _buildUseThisTipButton(context),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Detail Tips',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    final tip = _tip!;
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tip.title,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.33,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip.description,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.62,
              color: Color(0xFF99A1AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard() {
    final tip = _tip!;
    final author = tip.author;
    final vehicle = tip.vehicle;
    final vehicleText = '${vehicle.brand} ${vehicle.model} • ${vehicle.year}';
    final authorStats = author.stats;
    final statsText = authorStats != null
        ? '${authorStats.tipsCount} template • ${authorStats.followersCount} pengikut'
        : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0x336B7C4F),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: author.avatarUrl != null
                ? Image.network(
                    author.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        author.avatarEmoji ?? '👤',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      author.avatarEmoji ?? '👤',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.name,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicleText,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                if (statsText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    statsText,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.favorite,
            '$_likesCount',
            'Likes',
            const Color(0xFFFB2C36),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            Icons.bookmark,
            '$_bookmarksCount',
            'Disimpan',
            const Color(0xFF6B7C4F),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            Icons.visibility,
            '${_tip!.stats.viewsCount}',
            'Dilihat',
            const Color(0xFF2B7FFF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            Icons.star,
            _avgRating.toStringAsFixed(1),
            'Rating',
            const Color(0xFFF0B100),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: Color(0xFF99A1AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleLike,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: _isLiked
                        ? const Color(0xFFFB2C36)
                        : const Color(0xFF99A1AF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Like',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      color: _isLiked
                          ? const Color(0xFFFB2C36)
                          : const Color(0xFF99A1AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _toggleSave,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: _isSaved
                        ? const Color(0xFF6B7C4F)
                        : const Color(0xFF99A1AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Simpan',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      color: _isSaved
                          ? const Color(0xFF6B7C4F)
                          : const Color(0xFF99A1AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _showShareSheet,
            child: _buildActionButton(Icons.share, 'Share'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _showRatingDialog,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _userRating > 0 ? Icons.star : Icons.star_border,
                    size: 18,
                    color: _userRating > 0
                        ? const Color(0xFFF0B100)
                        : const Color(0xFF99A1AF),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _userRating > 0 ? '$_userRating/5' : 'Rating',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 11,
                      color: _userRating > 0
                          ? const Color(0xFFF0B100)
                          : const Color(0xFF99A1AF),
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

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF99A1AF)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
              color: Color(0xFF99A1AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    final interval = _tip!.maintenanceInterval;
    final distanceKm = interval?.distanceKm != null && interval!.distanceKm! > 0
        ? '${interval.distanceKm}'
        : '-';
    final timeMonths = interval?.timeMonths != null && interval!.timeMonths! > 0
        ? '${interval.timeMonths}'
        : '-';

    return Row(
      children: [
        Expanded(
          child: _buildIntervalCard(
            icon: Icons.route,
            label: 'Interval Jarak',
            value: distanceKm,
            unit: distanceKm != '-' ? 'km' : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildIntervalCard(
            icon: Icons.calendar_month,
            label: 'Interval Bulan',
            value: timeMonths,
            unit: timeMonths != '-' ? 'bulan' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalCard({
    required IconData icon,
    required String label,
    required String value,
    String? unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6B7C4F)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: Color(0xFF99A1AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.33,
              color: Color(0xFFFFFFFF),
            ),
          ),
          if (unit != null)
            Text(
              unit,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.33,
                color: Color(0xFF6A7282),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolsSection() {
    final tools = _tip!.tools ?? [];
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.build, size: 20, color: Color(0xFF6B7C4F)),
              SizedBox(width: 8),
              Text(
                'Alat yang Dibutuhkan',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tools.asMap().entries.map((entry) {
            final i = entry.key;
            final tool = entry.value;
            final label = tool.isOptional
                ? '${tool.name} (opsional)'
                : tool.name;
            return Column(
              children: [
                if (i > 0) const SizedBox(height: 8),
                _buildToolItem(i + 1, label),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToolItem(int number, String tool) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0x336B7C4F),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.33,
                color: Color(0xFF6B7C4F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            tool,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    final steps = _tip!.steps ?? [];
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle, size: 20, color: Color(0xFF6B7C4F)),
              SizedBox(width: 8),
              Text(
                'Langkah-Langkah',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Column(
              children: [
                if (i > 0) const SizedBox(height: 12),
                _buildStepCard(
                  step.stepNumber ?? i + 1,
                  step.title,
                  step.description,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepCard(int step, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x336B7C4F),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.56,
                color: Color(0xFF6B7C4F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.62,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNote() {
    final notes = _tip!.importantNotes ?? '';
    return Container(
      padding: const EdgeInsets.all(16.65),
      decoration: BoxDecoration(
        color: const Color(0x336B7C4F),
        border: Border.all(color: const Color(0x4D6B7C4F), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, size: 20, color: Color(0xFF6B7C4F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Penting',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notes,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.62,
                    color: Color(0xFFD1D5DC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final hashtags = _tip!.hashtags ?? [];
    final tags = _tip!.tags.map((t) => t.name).toList();
    final combined = [...hashtags, ...tags];
    if (combined.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: combined.map((tag) {
        final display = tag.startsWith('#') ? tag : '#$tag';
        return _buildHashtag(display);
      }).toList(),
    );
  }

  Widget _buildHashtag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.65, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          color: Color(0xFF99A1AF),
        ),
      ),
    );
  }

  Widget _buildUseThisTipButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showUseTemplateModal(context);
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF6B7C4F),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_today, size: 20, color: Color(0xFFFFFFFF)),
            SizedBox(width: 8),
            Text(
              'Gunakan Tips Ini',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.56,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUseTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildTemplateModal(context);
      },
    );
  }

  Widget _buildTemplateModal(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E2939), width: 0.65),
              ),
            ),
            child: Column(
              children: [
                // Drag indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF99A1AF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Buat Jadwal dari Template',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          // Modal Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x336B7C4F),
                      border: Border.all(
                        color: const Color(0x4D6B7C4F),
                        width: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFF6B7C4F),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Template ini akan disesuaikan dengan motor Anda',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: Color(0xFFD1D5DC),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service name
                  _buildModalSection(
                    title: 'Nama Perawatan',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF1E2939),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.oil_barrel_outlined,
                            size: 20,
                            color: Color(0xFF6B7C4F),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ganti Oli Mesin',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                          Icon(Icons.edit, size: 18, color: Color(0xFF99A1AF)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interval type selection
                  _buildModalSection(
                    title: 'Jenis Interval',
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildIntervalTypeCard(
                            icon: Icons.speed,
                            label: 'Kilometer',
                            isSelected: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildIntervalTypeCard(
                            icon: Icons.calendar_today,
                            label: 'Waktu',
                            isSelected: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interval value
                  _buildModalSection(
                    title: 'Interval Perawatan',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF1E2939),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              '2000',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                          Text(
                            'km',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF99A1AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current mileage
                  _buildModalSection(
                    title: 'Kilometer Saat Ini',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF1E2939),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.speed, size: 20, color: Color(0xFF6B7C4F)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '15,234 km',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD1D5DC),
                              ),
                            ),
                          ),
                          Text(
                            'Honda PCX 160',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF99A1AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next service prediction
                  _buildModalSection(
                    title: 'Perkiraan Service Berikutnya',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF6B7C4F),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Target Kilometer',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF99A1AF),
                                ),
                              ),
                              Text(
                                '17,234 km',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7C4F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFF1E2939), height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Sisa Jarak',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF99A1AF),
                                ),
                              ),
                              Text(
                                '2,000 km',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reminder toggle
                  _buildModalSection(
                    title: 'Pengingat',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF1E2939),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: Color(0xFF6B7C4F),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Aktifkan Pengingat',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                          Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: const Color(0xFF6B7C4F),
                            activeTrackColor: const Color(
                              0xFF6B7C4F,
                            ).withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes from template
                  _buildModalSection(
                    title: 'Catatan Template',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF1E2939),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tips dari komunitas:',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD1D5DC),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Gunakan oli original untuk hasil terbaik\n• Cek level oli setelah mesin dingin\n• Ganti filter oli setiap 2x ganti oli',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: Color(0xFF99A1AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              border: Border.all(
                                color: const Color(0xFF1E2939),
                                width: 0.65,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF99A1AF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Save schedule with API
                            Navigator.pop(context);
                            _showSuccessSnackbar(context);
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B7C4F),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Buat Jadwal',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFFFFF),
                              ),
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
    );
  }

  Widget _buildModalSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFD1D5DC),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildIntervalTypeCard({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6B7C4F).withOpacity(0.2)
            : const Color(0xFF1A1A1A),
        border: Border.all(
          color: isSelected ? const Color(0xFF6B7C4F) : const Color(0xFF1E2939),
          width: isSelected ? 1.5 : 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected
                ? const Color(0xFF6B7C4F)
                : const Color(0xFF99A1AF),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF6B7C4F)
                  : const Color(0xFF99A1AF),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal berhasil dibuat dari template!'),
        backgroundColor: Color(0xFF6B7C4F),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
