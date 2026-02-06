import 'package:flutter/material.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../dashboard/dashboard.dart';
import '../widget/page_transition.dart';
import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                // App Icon
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 80,
                  height: 80,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 5),
                // App Name
                Text(
                  l10n.appName,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // Tagline
                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Login Card
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Text
                      Text(
                        l10n.welcomeBack,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.email,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.emailHint,
                              hintStyle: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.password,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.passwordHint,
                              hintStyle: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.65,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(page: const ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Login Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Dashboard
                            if (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              Navigator.pushReplacement(
                                context,
                                SmoothPageRoute(page: const DashboardPage()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.dontHaveAccount,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              color: colorScheme.secondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SmoothPageRoute(page: const RegisterPage()),
                              );
                            },
                            child: Text(
                              l10n.register,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
