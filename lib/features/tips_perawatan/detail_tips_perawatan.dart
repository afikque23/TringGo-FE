import 'package:flutter/material.dart';

class DetailTipsPerawatanPage extends StatelessWidget {
  const DetailTipsPerawatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildHeroSection(context),
          Expanded(
            child: SingleChildScrollView(
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
                        _buildToolsSection(),
                        const SizedBox(height: 16),
                        _buildStepsSection(),
                        const SizedBox(height: 16),
                        _buildImportantNote(),
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
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Trending', const Color(0xFFFF8904), Icons.trending_up),
              _buildTag(
                'Rekomendasi AI',
                const Color(0xFF6B7C4F),
                Icons.psychology,
              ),
              _buildTag(
                'Terbukti 96%',
                const Color(0xFF51A2FF),
                Icons.verified,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'Cara Efisien Ganti Oli untuk Pemakaian Harian',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.33,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          // Description
          const Text(
            'Metode ganti oli yang terbukti memperpanjang umur mesin hingga 30% dengan teknik yang sudah divalidasi oleh ribuan pengguna',
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

  Widget _buildTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.65, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.3), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 16.65),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF1E2939), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0x336B7C4F),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text('👨‍🔧', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Budi Santoso',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Top Creator',
                            style: TextStyle(
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
                    const SizedBox(height: 4),
                    const Text(
                      'Honda PCX 160 • 2023',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        color: Color(0xFF99A1AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '23 template • 1240 total likes',
                      style: TextStyle(
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
            '234',
            'Likes',
            const Color(0xFFFB2C36),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            Icons.content_copy,
            '89',
            'Forks',
            const Color(0xFF6B7C4F),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            Icons.group,
            '456',
            'Digunakan',
            const Color(0xFF2B7FFF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            Icons.star,
            '4.8',
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
        Expanded(child: _buildActionButton(Icons.favorite_border, 'Like')),
        const SizedBox(width: 8),
        Expanded(child: _buildActionButton(Icons.bookmark_border, 'Simpan')),
        const SizedBox(width: 8),
        Expanded(child: _buildActionButton(Icons.share, 'Share')),
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
    return Row(
      children: [
        Expanded(
          child: Container(
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
                    Icon(Icons.access_time, size: 16, color: Color(0xFF6B7C4F)),
                    SizedBox(width: 8),
                    Text(
                      'Estimasi Waktu',
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
                const SizedBox(height: 8),
                const Text(
                  '20',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const Text(
                  'menit',
                  style: TextStyle(
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
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
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
                    Icon(Icons.repeat, size: 16, color: Color(0xFF6B7C4F)),
                    SizedBox(width: 8),
                    Text(
                      'Interval',
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
                const SizedBox(height: 8),
                const Text(
                  '2000',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const Text(
                  'km / 60 hari',
                  style: TextStyle(
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
        ),
      ],
    );
  }

  Widget _buildToolsSection() {
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
          _buildToolItem(1, 'Kunci Ring 17'),
          const SizedBox(height: 8),
          _buildToolItem(2, 'Wadah Oli Bekas'),
          const SizedBox(height: 8),
          _buildToolItem(3, 'Kain Lap'),
          const SizedBox(height: 8),
          _buildToolItem(4, 'Oli Mesin Original (0.8L)'),
          const SizedBox(height: 8),
          _buildToolItem(5, 'Filter Oli (opsional)'),
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
          _buildStepCard(
            1,
            'Persiapan Alat dan Bahan',
            'Siapkan semua alat yang diperlukan: kunci ring 17, wadah oli bekas, kain lap, dan oli mesin original. Pastikan motor dalam kondisi dingin.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            2,
            'Posisikan Motor dengan Benar',
            'Parkirkan motor di tempat yang rata dan gunakan standar tengah. Pastikan motor dalam posisi stabil sebelum memulai.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            3,
            'Buka Baut Pembuangan',
            'Lepaskan baut pembuangan oli menggunakan kunci ring 17. Letakkan wadah di bawah untuk menampung oli bekas.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            4,
            'Ganti Filter Oli (Opsional)',
            'Jika sudah waktunya, ganti juga filter oli. Pastikan filter terpasang dengan benar.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            5,
            'Tutup Baut dan Isi Oli Baru',
            'Pasang kembali baut pembuangan dengan torsi yang tepat. Isi oli baru melalui lubang pengisian sesuai takaran.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            6,
            'Cek Level Oli',
            'Hidupkan mesin sebentar, matikan, dan cek level oli menggunakan dipstick. Tambahkan jika kurang.',
          ),
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
              children: const [
                Text(
                  'Catatan Penting',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gunakan oli original untuk hasil terbaik. Ganti oli setiap 2000 km atau 2 bulan untuk penggunaan harian. Buang oli bekas di tempat yang tepat untuk menjaga lingkungan.',
                  style: TextStyle(
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildHashtag('#Oli Mesin'),
        _buildHashtag('#Perawatan Rutin'),
        _buildHashtag('#Daily Rider'),
      ],
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
        // TODO: Navigate to schedule or use this tip
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
}
