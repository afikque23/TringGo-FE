import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Ahmad Rifai',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'ahmad.rifai@example.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+62 812 3456 7890',
  );
  final TextEditingController _locationController = TextEditingController(
    text: 'Jakarta, Indonesia',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.saveChanges),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  void _changeProfilePhoto() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implement photo picker logic
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogColorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: dialogColorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.updateProfilePhoto,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: dialogColorScheme.onSurface,
            ),
          ),
          content: Text(
            'Fitur mengubah foto profil akan segera tersedia.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: dialogColorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: dialogColorScheme.primary,
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
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            SafeArea(
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
                        width: 20,
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
                            l10n.editProfile,
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
                            l10n.editProfileDescription,
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
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: [
                    // Profile Photo Section
                    _buildProfilePhotoCard(),
                    const SizedBox(height: 24),
                    // Form Fields
                    _buildFormFields(),
                    const SizedBox(height: 24),
                    // Tips Section
                    _buildTipsCard(),
                    const SizedBox(height: 24),
                    // Save Button
                    _buildSaveButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(120, 24.65, 120, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar with Camera Button
          Stack(
            children: [
              // Avatar
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              // Camera Button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeProfilePhoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 1.96,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          // Help Text
          Text(
            l10n.updateProfilePhoto,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.43,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Name Field
        _buildInputField(
          label: l10n.fullName,
          controller: _nameController,
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        // Email Field
        _buildInputField(
          label: l10n.email,
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        // Phone Field
        _buildInputField(
          label: l10n.phoneNumber,
          optionalLabel: '(${l10n.optional})',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        // Location Field
        _buildInputField(
          label: l10n.location,
          optionalLabel: '(${l10n.optional})',
          controller: _locationController,
          icon: Icons.location_on_outlined,
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    String? optionalLabel,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF99A1AF),
                height: 1.43,
              ),
            ),
            if (optionalLabel != null) ...[
              const SizedBox(width: 4),
              Text(
                optionalLabel,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4A5565),
                  height: 1.43,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Input Field
        Container(
          height: 57.27,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              // Vertical Divider
              Container(
                width: 0.65,
                height: 24,
                color: colorScheme.outlineVariant,
              ),
              // Text Input
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.125,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.64,
              ),
              children: [
                TextSpan(
                  text: '💡 Tips: ',
                  style: TextStyle(color: colorScheme.primary),
                ),
                TextSpan(
                  text: l10n.profileTipsEmail,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _saveChanges,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
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
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 20, color: colorScheme.onPrimary),
            const SizedBox(width: 8),
            Text(
              l10n.save,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
