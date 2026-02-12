import 'package:flutter/material.dart';
import '../widget/bottom_navbar.dart';
import 'detail_tips_perawatan.dart';

class TipsPerawatanPage extends StatefulWidget {
  const TipsPerawatanPage({super.key});

  @override
  State<TipsPerawatanPage> createState() => _TipsPerawatanPageState();
}

class _TipsPerawatanPageState extends State<TipsPerawatanPage> {
  bool _showFilter = false;
  String _selectedBrand = 'Semua Merek';
  String _selectedDifficulty = 'Semua Tingkat';

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

              // Scrollable content: tips list + ranking
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  children: [
                    // Tips list
                    _buildTipsList(),
                    const SizedBox(height: 12),
                    // Ranking button
                    _buildRankingButton(),
                    const SizedBox(height: 24),
                  ],
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
                child: Container(color: Colors.black.withOpacity(0.5)),
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
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF99A1AF),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Cari tips sesuai motor anda....',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ),
                ],
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

  Widget _buildTipsList() {
    return Column(
      children: [
        _buildTipCard(
          tags: [
            _TagData('Trending', const Color(0xFFFF8904), Icons.trending_up),
            _TagData(
              'Rekomendasi AI',
              const Color(0xFF6B7C4F),
              Icons.psychology,
            ),
            _TagData('Terbukti', const Color(0xFF51A2FF), Icons.verified),
          ],
          title: 'Cara Efisien Ganti Oli untuk Pemakaian Harian',
          description:
              'Metode ganti oli yang terbukti memperpanjang umur mesin hingga 30%',
          author: 'Budi Santoso',
          vehicle: 'Honda PCX 160 • 2023',
          authorEmoji: '👨‍🔧',
          authorBadge: 'Top Creator',
          difficulty: 'Mudah',
          difficultyColor: const Color(0xFF6B7C4F),
          rating: '4.8',
          likes: '234',
          bookmarks: '89',
          percentage: '96%',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          tags: [
            _TagData('Trending', const Color(0xFFFF8904), Icons.trending_up),
            _TagData('Terbukti', const Color(0xFF51A2FF), Icons.verified),
          ],
          title: 'Perawatan Rantai untuk Long Trip',
          description:
              'Teknik khusus merawat rantai motor agar tetap optimal saat perjalanan jauh',
          author: 'Andi Wijaya',
          vehicle: 'Yamaha NMAX • 2022',
          authorEmoji: '🧑‍🔧',
          authorBadge: 'AI Verified',
          difficulty: 'Sedang',
          difficultyColor: const Color(0xFFF0B100),
          rating: '4.6',
          likes: '189',
          bookmarks: '67',
          percentage: '94%',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          tags: [
            _TagData(
              'Rekomendasi AI',
              const Color(0xFF6B7C4F),
              Icons.psychology,
            ),
            _TagData('Terbukti', const Color(0xFF51A2FF), Icons.verified),
          ],
          title: 'Cek Kampas Rem untuk Berkendara Agresif',
          description:
              'Panduan lengkap mengecek dan mengganti kampas rem untuk gaya berkendara agresif',
          author: 'Dimas Racing',
          vehicle: 'Kawasaki Ninja 250 • 2023',
          authorEmoji: '🏍️',
          authorBadge: 'Expert',
          difficulty: 'Sulit',
          difficultyColor: const Color(0xFFFB2C36),
          rating: '4.9',
          likes: '312',
          bookmarks: '124',
          percentage: '98%',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          tags: [_TagData('Terbukti', const Color(0xFF51A2FF), Icons.verified)],
          title: 'Pembersihan Filter Udara Motor Matic',
          description:
              'Cara mudah dan cepat membersihkan filter udara untuk performa maksimal',
          author: 'Ibu Sri',
          vehicle: 'Honda Vario 125 • 2023',
          authorEmoji: '👩‍🔧',
          authorBadge: 'Top Creator',
          difficulty: 'Mudah',
          difficultyColor: const Color(0xFF6B7C4F),
          rating: '4.7',
          likes: '167',
          bookmarks: '54',
          percentage: '92%',
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required List<_TagData> tags,
    required String title,
    required String description,
    required String author,
    required String vehicle,
    required String authorEmoji,
    String? authorBadge,
    required String difficulty,
    required Color difficultyColor,
    required String rating,
    required String likes,
    required String bookmarks,
    required String percentage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailTipsPerawatanPage(),
          ),
        );
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
            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: 12),

            // Title
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
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color(0xFF99A1AF),
              ),
            ),
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
                    alignment: Alignment.center,
                    child: Text(
                      authorEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        Text(
                          vehicle,
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
                  if (authorBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.65,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x336B7C4F),
                        border: Border.all(
                          color: const Color(0x4D6B7C4F),
                          width: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        authorBadge,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          color: Color(0xFF6B7C4F),
                        ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      color: difficultyColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFF0B100)),
                    const SizedBox(width: 4),
                    Text(
                      rating,
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
                Text(
                  '❤️ $likes',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                Text(
                  '📋 $bookmarks',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                Text(
                  percentage,
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
      ),
    );
  }

  Widget _buildTag(_TagData tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.65, vertical: 4.5),
      decoration: BoxDecoration(
        color: tag.color.withOpacity(0.2),
        border: Border.all(color: tag.color.withOpacity(0.3), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 12, color: tag.color),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: tag.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingButton() {
    return Container(
      height: 73,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x33F0B100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  size: 24,
                  color: Color(0xFFF0B100),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ranking Kontributor',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  Text(
                    'Lihat pengguna paling berdampak',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      color: Color(0xFF99A1AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Color(0xFF99A1AF),
          ),
        ],
      ),
    );
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
                            options: [
                              'Semua Merek',
                              'Honda',
                              'Yamaha',
                              'Kawasaki',
                            ],
                            selectedValue: _selectedBrand,
                            onSelect: (value) {
                              setState(() {
                                _selectedBrand = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Tingkat Kesulitan Section
                          _buildFilterSection(
                            title: 'Tingkat Kesulitan',
                            options: [
                              'Semua Tingkat',
                              'Mudah',
                              'Sedang',
                              'Sulit',
                            ],
                            selectedValue: _selectedDifficulty,
                            onSelect: (value) {
                              setState(() {
                                _selectedDifficulty = value;
                              });
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

class _TagData {
  final String label;
  final Color color;
  final IconData icon;

  _TagData(this.label, this.color, this.icon);
}
