import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/model/tip_model.dart';
import '../../core/services/tips_service.dart';
import '../widget/bottom_navbar.dart';
import 'detail_tips_perawatan.dart';

class TipsPerawatanPage extends StatefulWidget {
  const TipsPerawatanPage({super.key});

  @override
  State<TipsPerawatanPage> createState() => _TipsPerawatanPageState();
}

class _TipsPerawatanPageState extends State<TipsPerawatanPage> {
  final _tipsService = TipsService();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _showFilter = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<TipModel> _tips = [];
  String _selectedBrand = 'Semua Merek';
  String _selectedDifficulty = 'Semua Tingkat';

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _showFilter = !_showFilter;
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedBrand = 'Semua Merek';
      _selectedDifficulty = 'Semua Tingkat';
    });
    _loadTips();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), _loadTips);
  }

  Map<String, String?> _buildSearchParams(String rawInput) {
    final input = rawInput.trim();
    if (input.isEmpty) {
      return {'search': null, 'hashtags': null};
    }

    final hashtagMatches = RegExp(r'#([^#,;\n]+)').allMatches(input);
    final hashtags = <String>[];
    final seenHashtags = <String>{};

    for (final match in hashtagMatches) {
      final rawTag = (match.group(1) ?? '').trim();
      final normalized = rawTag.replaceAll(RegExp(r'\s+'), ' ');
      if (normalized.isEmpty) {
        continue;
      }

      final key = normalized.toLowerCase();
      if (seenHashtags.add(key)) {
        hashtags.add(normalized);
      }
    }

    final keyword = input
        .replaceAll(RegExp(r'#([^#,;\n]+)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return {
      'search': keyword.isEmpty ? null : keyword,
      'hashtags': hashtags.isEmpty ? null : hashtags.join(','),
    };
  }

  Future<void> _loadTips() async {
    final queryParams = _buildSearchParams(_searchController.text);
    final hasUserQuery = _searchController.text.trim().isNotEmpty;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _tipsService.getAllTips(
        page: 1,
        limit: 20,
        search: queryParams['search'],
        hashtags: queryParams['hashtags'],
        brand: _selectedBrand == 'Semua Merek' ? null : _selectedBrand,
        difficulty: _selectedDifficulty == 'Semua Tingkat'
            ? null
            : _selectedDifficulty,
        sortBy: hasUserQuery ? 'relevance' : 'recommended',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _tips = response.data.tips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _tips = [];
        _isLoading = false;
        _errorMessage = 'Gagal memuat data tips. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Column(
            children: [
              // Fixed header and search bar (won't scroll)
              _buildHeader(),
              _buildSearchBar(),

              // Scrollable content: tips list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadTips,
                  color: const Color(0xFF6B7C4F),
                  backgroundColor: const Color(0xFF1A1A1A),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: [_buildTipsContent(), const SizedBox(height: 24)],
                  ),
                ),
              ),
            ],
          ),
          // Filter overlay and sidebar
          if (_showFilter) ...[
            // Blur overlay (doesn't cover status bar)
            Positioned.fill(
              top: MediaQuery.of(context).padding.top,
              child: GestureDetector(
                onTap: _toggleFilter,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
            // Filter sidebar
            _buildFilterSidebar(),
          ],
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tips Perawatan Motor',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Belajar dari pengalaman pengguna untuk perawatan motor terbaik',
            style: TextStyle(
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 49,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFFFFFF),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Color(0xFF99A1AF),
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _loadTips();
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF99A1AF),
                          ),
                        ),
                  hintText: 'Cari tips atau #hashtag...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleFilter,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7C4F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.filter_list,
                size: 20,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsContent() {
    if (_isLoading && _tips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B7C4F),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_errorMessage != null && _tips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF6467), size: 28),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF99A1AF),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loadTips,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7C4F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_tips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off, color: Color(0xFF6A7282), size: 28),
            SizedBox(height: 8),
            Text(
              'Belum ada tips yang cocok dengan pencarian atau filter Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF99A1AF),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _tips.asMap().entries.map((entry) {
        final index = entry.key;
        final tip = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index == _tips.length - 1 ? 0 : 12),
          child: _buildTipCard(tip),
        );
      }).toList(),
    );
  }

  Widget _buildTipCard(TipModel tip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTipsPerawatanPage(tipId: tip.id),
          ),
        ).then((_) => _loadTips());
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16.65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              tip.title,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              tip.description,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color(0xFF99A1AF),
              ),
            ),
            if (tip.hashtags != null && tip.hashtags!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tip.hashtags!
                    .take(3)
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          border: Border.all(
                            color: const Color(0xFF1E2939),
                            width: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF99A1AF),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),

            // Author Info
            Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E2939), width: 0.65),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x336B7C4F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: tip.author.avatarUrl != null
                        ? Image.network(
                            tip.author.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                tip.author.avatarEmoji ?? '👨‍🔧',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              tip.author.avatarEmoji ?? '👨‍🔧',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.author.name,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        Text(
                          '${tip.vehicle.brand} ${tip.vehicle.model} • ${tip.vehicle.year}',
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFF0B100)),
                    const SizedBox(width: 4),
                    Text(
                      tip.stats.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 12,
                      color: Color(0xFFFB2C36),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tip.stats.likesCount}',
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
                Row(
                  children: [
                    const Icon(
                      Icons.bookmark,
                      size: 12,
                      color: Color(0xFF6B7C4F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tip.stats.bookmarksCount}',
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
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Color(0xFF6B7C4F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tip.stats.successPercentage}%',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        color: Color(0xFF6B7C4F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildBrandOptions() {
    final brands = <String>{};

    for (final tip in _tips) {
      final brand = tip.vehicle.brand.trim();
      if (brand.isNotEmpty) {
        brands.add(brand);
      }
    }

    final sortedBrands = brands.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final options = <String>['Semua Merek', ...sortedBrands];

    if (_selectedBrand != 'Semua Merek' && !options.contains(_selectedBrand)) {
      options.insert(1, _selectedBrand);
    }

    return options;
  }

  List<String> _buildDifficultyOptions() {
    final levels = <String>{};

    for (final tip in _tips) {
      final level = tip.difficulty?.level.trim();
      if (level != null && level.isNotEmpty) {
        levels.add(level);
      }
    }

    const preferredOrder = ['Mudah', 'Sedang', 'Sulit'];
    final ordered = <String>[];

    for (final level in preferredOrder) {
      if (levels.remove(level)) {
        ordered.add(level);
      }
    }

    final remaining = levels.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final options = <String>['Semua Tingkat', ...ordered, ...remaining];

    if (_selectedDifficulty != 'Semua Tingkat' &&
        !options.contains(_selectedDifficulty)) {
      options.insert(1, _selectedDifficulty);
    }

    return options;
  }

  Widget _buildFilterSidebar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 2 / 3;

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: sidebarWidth, end: 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: Container(
              width: sidebarWidth,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                ),
              ),
              child: Column(
                children: [
                  // Header with title and close button
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF1E2939),
                          width: 0.65,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Cerdas',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleFilter,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              border: Border.all(
                                color: const Color(0xFF1E2939),
                                width: 0.65,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF99A1AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Merek Motor Section
                          _buildFilterSection(
                            title: 'Merek Motor',
                            options: _buildBrandOptions(),
                            selectedValue: _selectedBrand,
                            onSelect: (value) {
                              setState(() {
                                _selectedBrand = value;
                              });
                              _loadTips();
                            },
                          ),
                          const SizedBox(height: 24),
                          // Tingkat Kesulitan Section
                          _buildFilterSection(
                            title: 'Tingkat Kesulitan',
                            options: _buildDifficultyOptions(),
                            selectedValue: _selectedDifficulty,
                            onSelect: (value) {
                              setState(() {
                                _selectedDifficulty = value;
                              });
                              _loadTips();
                            },
                          ),
                          const SizedBox(height: 24),
                          // Reset Filter Button
                          GestureDetector(
                            onTap: _resetFilter,
                            child: Container(
                              width: double.infinity,
                              height: 49,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A0A0A),
                                border: Border.all(
                                  color: const Color(0xFF1E2939),
                                  width: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Reset Filter',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  color: Color(0xFF99A1AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xFFD1D5DC),
          ),
        ),
        const SizedBox(height: 12),
        // Options
        Column(
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  width: double.infinity,
                  height: isSelected ? 44 : 45,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B7C4F)
                        : const Color(0xFF0A0A0A),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: const Color(0xFF1E2939),
                            width: 0.65,
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      color: isSelected
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF99A1AF),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
