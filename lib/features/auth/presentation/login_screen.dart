import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_messages.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_error_banner.dart';
import '../../../core/widgets/ampex_glass.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_primary_button.dart';
import '../../../core/widgets/ampex_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _emailFocus.requestFocus());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (e) {
      setState(() => _error = authErrorMessageNorwegian(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Skriv inn e-postadressen din først.');
      _emailFocus.requestFocus();
      return;
    }
    try {
      await ref.read(authRepositoryProvider).resetPasswordForEmail(email);
      if (!mounted) return;
      showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('E-post sendt'),
          content: const Text(
            'Sjekk innboksen din for en lenke til å tilbakestille passordet.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = authErrorMessageNorwegian(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmpexBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LogoMark(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppConfig.appName,
                      style: AppTypography.largeTitle.copyWith(fontSize: 36),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Operativsystemet for elektrofirmaer',
                      style: AppTypography.callout,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Glass-kort med skjema ──────────────────────────────────
                    AmpexGlass(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AmpexGroupedSection(
                                margin: EdgeInsets.zero,
                                dividerIndent: AppSpacing.rowH,
                                children: [
                                  AmpexTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    hint: 'E-post',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    autofillHints: const [AutofillHints.email],
                                    onSubmitted: (_) =>
                                        _passwordFocus.requestFocus(),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Skriv inn e-post';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Ugyldig e-postadresse';
                                      }
                                      return null;
                                    },
                                  ),
                                  AmpexTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    hint: 'Passord',
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [AutofillHints.password],
                                    onSubmitted: (_) => _submit(),
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? CupertinoIcons.eye
                                            : CupertinoIcons.eye_slash,
                                        size: 20,
                                        color: AppColors.labelSecondary,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Skriv inn passord';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _loading ? null : _forgotPassword,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accent,
                                    minimumSize:
                                        const Size(0, AppSpacing.minTouch),
                                    textStyle: AppTypography.callout,
                                  ),
                                  child: const Text('Glemt passord?'),
                                ),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                AmpexErrorBanner(message: _error!),
                                const SizedBox(height: AppSpacing.sm),
                              ] else
                                const SizedBox(height: AppSpacing.sm),
                              AmpexPrimaryButton(
                                label: 'Logg inn',
                                onPressed: _submit,
                                isLoading: _loading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Merkevare-logo i gradient glass-chip.
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(CupertinoIcons.bolt_fill, color: Colors.white, size: 36),
    );
  }
}
