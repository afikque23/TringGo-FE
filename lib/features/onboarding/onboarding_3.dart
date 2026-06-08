import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class Onboarding3 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const Onboarding3({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Skip Button
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: onSkip,
                            child: Text(
                              l10n.skip,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        // Icon Container
                        _buildIconContainer(),
                        const SizedBox(height: 40),
                        // Heading
                        Text(
                          l10n.onboarding3Title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          l10n.onboarding3Desc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.625,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        // Progress Indicators
                        _buildProgressIndicators(context),
                        const SizedBox(height: 24),
                        // Action Buttons (Back and Next)
                        _buildActionButtons(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Image.asset(
      'assets/icon/onboarding_3.png',
      width: 160,
      height: 160,
      fit: BoxFit.contain,
    );
  }

  Widget _buildProgressIndicators(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First two inactive indicators
        ...List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        // Active indicator (third)
        Container(
          width: 32,
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 8),
        // Last inactive indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Back Button
        SizedBox(
          width: 130,
          height: 53,
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(
                color: colorScheme.surfaceContainerHighest,
                width: 0.65,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 18),
                const SizedBox(width: 4),
                Text(
                  l10n.back,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Next Button
        Expanded(
          child: SizedBox(
            height: 53,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.next,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
