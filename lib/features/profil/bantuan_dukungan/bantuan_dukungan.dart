import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/model/content_model.dart';
import '../../../core/services/content_service.dart';
import 'syarat_ketentuan.dart';
import 'kebijakan_privasi.dart';
import 'panduan_pengguna.dart';

class BantuanDukunganPage extends StatefulWidget {
  const BantuanDukunganPage({super.key});

  @override
  State<BantuanDukunganPage> createState() => _BantuanDukunganPageState();
}

class _BantuanDukunganPageState extends State<BantuanDukunganPage> {
  int _expandedFaqIndex = -1; // No FAQ is expanded by default
  List<FaqItemModel> _dynamicFaqItems = const [];

  String? _supportEmail;
  String? _supportPhone;
  String? _supportLiveChatSubtitle;

  @override
  void initState() {
    super.initState();
    _loadFaqFromApi();
    _loadSupportFromApi();
  }

  Future<void> _loadFaqFromApi() async {
    try {
      final items = await ContentService().getFaqItems();
      if (!mounted) return;
      if (items.isEmpty) return;
      setState(() {
        _dynamicFaqItems = items;
      });
    } catch (_) {
      // Silent fallback to localized FAQ
    }
  }

  Future<void> _loadSupportFromApi() async {
    try {
      final sections = await ContentService().getDocumentSections(
        'support',
        mergeAll: true,
      );
      if (!mounted) return;
      if (sections.isEmpty) return;

      final candidates = <String>[];
      for (final s in sections) {
        candidates.addAll(s.paragraphs);
        candidates.addAll(s.bullets);
      }

      String? email;
      String? phone;

      final emailRegex = RegExp(
        r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
      );
      final phoneRegex = RegExp(r'(\+?\d[\d\s\-()]{7,}\d)');

      for (final text in candidates) {
        if (email == null) {
          final match = emailRegex.firstMatch(text);
          if (match != null) {
            email = match.group(1);
          }
        }
        if (phone == null) {
          final match = phoneRegex.firstMatch(text);
          if (match != null) {
            phone = match.group(1);
          }
        }
        if (email != null && phone != null) break;
      }

      final liveChatSubtitle = sections.first.paragraphs.isNotEmpty
          ? sections.first.paragraphs.first.trim()
          : null;

      setState(() {
        _supportEmail = email?.trim();
        _supportPhone = phone?.trim();
        _supportLiveChatSubtitle =
            liveChatSubtitle != null && liveChatSubtitle.isNotEmpty
            ? liveChatSubtitle
            : null;
      });
    } catch (_) {
      // Silent fallback to localized/static contact text
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    // Contact Us Section
                    _buildContactSection(),
                    const SizedBox(height: 22),
                    // FAQ Section
                    _buildFaqSection(),
                    const SizedBox(height: 22),
                    // Resources Section
                    _buildResourcesSection(),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 12),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helpSupport,
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
                    l10n.getInTouch,
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
    );
  }

  Widget _buildContactSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final email = _supportEmail ?? 'support@mototracker.id';
    final phone = _supportPhone ?? '+62 812-3456-7890';
    final liveChatSubtitle = _supportLiveChatSubtitle ?? l10n.liveChatSubtitle;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.contactUs,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Live Chat
                _buildContactCard(
                  icon: Icons.chat_bubble_outline,
                  title: l10n.liveChat,
                  subtitle: liveChatSubtitle,
                  actionText: l10n.startChat,
                  onTap: () {
                    // TODO: Open live chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka live chat...'),
                        backgroundColor: Color(0xFF6B7C4F),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Email Support
                _buildContactCard(
                  icon: Icons.email_outlined,
                  title: l10n.emailSupport,
                  subtitle: email,
                  actionText: l10n.sendEmail,
                  onTap: () {
                    // TODO: Open email client
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka email client...'),
                        backgroundColor: Color(0xFF6B7C4F),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Phone (Disabled)
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101828).withValues(alpha: 0.5),
                      border: Border.all(
                        color: const Color(0xFF1E2939),
                        width: 1.96,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2939),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color: const Color(0xFF4A5565),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l10n.phone,
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFFFFFFF),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Coming Soon Badge
                                  DecoratedBox(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E2939),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        l10n.comingSoon,
                                        style: const TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF99A1AF),
                                          height: 1.33,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF99A1AF),
                                  height: 1.33,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant, width: 1.96),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.primary,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final fallbackFaqItems = <FaqItemModel>[
      FaqItemModel(
        question: l10n.faqAddMotorcycle,
        answer: l10n.faqAddMotorcycleAnswer,
      ),
      FaqItemModel(
        question: l10n.faqStartTracking,
        answer: l10n.faqStartTrackingAnswer,
      ),
      FaqItemModel(
        question: l10n.faqNoNotifications,
        answer: l10n.faqNoNotificationsAnswer,
      ),
      FaqItemModel(
        question: l10n.faqSwitchMotorcycle,
        answer: l10n.faqSwitchMotorcycleAnswer,
      ),
      FaqItemModel(question: l10n.faqDataLost, answer: l10n.faqDataLostAnswer),
      FaqItemModel(
        question: l10n.faqContactWorkshop,
        answer: l10n.faqContactWorkshopAnswer,
      ),
    ];

    final faqItems = _dynamicFaqItems.isNotEmpty
        ? _dynamicFaqItems
        : fallbackFaqItems;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.faq,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // FAQ Items
          ...List.generate(faqItems.length, (index) {
            final isExpanded = _expandedFaqIndex == index;
            final hasAnswer = faqItems[index].answer.isNotEmpty;

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < faqItems.length - 1
                      ? BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                          width: 0.65,
                        )
                      : BorderSide.none,
                ),
              ),
              child: GestureDetector(
                onTap: hasAnswer
                    ? () {
                        setState(() {
                          _expandedFaqIndex = isExpanded ? -1 : index;
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faqItems[index].question,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Transform.rotate(
                            angle: isExpanded && hasAnswer
                                ? 3.14159
                                : 0, // 180 degrees in radians to flip up when expanded
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded && hasAnswer) ...[
                        const SizedBox(height: 8),
                        Text(
                          faqItems[index].answer,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.64,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResourcesSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.resources,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Resource Items
          _buildResourceItem(
            icon: Icons.menu_book_outlined,
            title: l10n.userGuide,
            subtitle: l10n.userGuideDesc,
            showDivider: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PanduanPenggunaPage(),
                ),
              );
            },
          ),
          _buildResourceItem(
            icon: Icons.menu_book_outlined,
            title: l10n.privacyPolicy,
            subtitle: l10n.privacyPolicyDesc,
            showDivider: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const KebijakanPrivasiPage(),
                ),
              );
            },
          ),
          _buildResourceItem(
            icon: Icons.menu_book_outlined,
            title: l10n.termsConditions,
            subtitle: l10n.termsConditionsDesc,
            showDivider: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SyaratKetentuanPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.65,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
