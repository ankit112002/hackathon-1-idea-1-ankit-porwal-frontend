import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/i18n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = ref.watch(supabaseReadyProvider);
    final roleState = ref.watch(staffRoleProvider);
    final signedIn = ready && Supabase.instance.client.auth.currentSession != null;
    final missingRole = signedIn &&
        roleState.hasValue &&
        !roleState.isLoading &&
        roleState.value == null;

    return AppScaffold(
      title: l10n.loginTitle,
      homePath: '/',
      hidePublicNav: true,
      body: MaxWidth(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.bottleGreenWash,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bottleGreen.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.lock_outline, color: AppColors.bottleGreen, size: 28),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.tr(
                      es: 'Acceso del equipo',
                      eu: 'Lan-taldearen sarbidea',
                      en: 'Staff sign in',
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fraunces(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(
                      es: 'Entra con tu cuenta. El camarero abre la sala y el dueño abre el panel.',
                      eu: 'Sartu zure kontuarekin. Zerbitzariak jangela irekitzen du eta jabeak panela.',
                      en: 'Sign in with your account. A waiter opens the dining room. An owner opens the dashboard.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppField(
                    label: l10n.email,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppField(label: l10n.password, controller: _password, obscure: true),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(_error!, style: const TextStyle(color: AppColors.danger)),
                  ],
                  if (missingRole) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.tr(
                        es: 'Esta cuenta no tiene un perfil de equipo. Pide al dueño que asigne camarero, jefe o dueño.',
                        eu: 'Kontu honek ez du lan-taldeko rolik. Eskatu jabeari zerbitzari, arduradun edo jabe rola emateko.',
                        en: 'This account has no staff role. Ask the owner to assign waiter, manager, or owner.',
                      ),
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.signOut,
                      kind: AppButtonKind.outlined,
                      fullWidth: true,
                      onPressed: _signOut,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: _busy ? l10n.sending : l10n.loginTitle,
                    fullWidth: true,
                    onPressed: _busy ? null : _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.bottleGreen),
                label: Text(
                  context.tr(
                    es: 'Volver a la web pública de clientes',
                    eu: 'Itzuli bezeroen webgune publikora',
                    en: 'Return to public customer website',
                  ),
                  style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(_email.text, _password.text);
      ref.read(authEpochProvider.notifier).bump();
    } on AuthException {
      if (mounted) setState(() => _error = l10n.authFailed);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final epoch = ref.read(authEpochProvider.notifier);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {}
    epoch.bump();
  }
}
