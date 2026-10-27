import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _email = TextEditingController(text: 'propietario@iturrieta.eus');
  final _password = TextEditingController(text: 'txotx2026!');
  var _busy = false;
  String? _error;
  int _selectedRole = 1; // 0: Camarero, 1: Dueño

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.loginTitle,
      homePath: '/',
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
                    'Acceso Equipo Sidrería',
                    style: GoogleFonts.fraunces(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gestión de sala, asignación de mesas y control administrativo',
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // S1 (Staff Login): Dual-role switcher (Camarero vs Dueño) per specifications
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selección de Rol (S1 Specification)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() {
                              _selectedRole = 0;
                              _email.text = 'camarero@iturrieta.eus';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 0 ? AppColors.bottleGreen : AppColors.paper,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedRole == 0 ? AppColors.bottleGreen : AppColors.line,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: _selectedRole == 0 ? Colors.white : AppColors.ink,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Camarero',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _selectedRole == 0 ? Colors.white : AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'Servicio de Sala',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _selectedRole == 0 ? Colors.white70 : AppColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() {
                              _selectedRole = 1;
                              _email.text = 'propietario@iturrieta.eus';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 1 ? AppColors.bottleGreen : AppColors.paper,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedRole == 1 ? AppColors.bottleGreen : AppColors.line,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  color: _selectedRole == 1 ? Colors.white : AppColors.ink,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dueño',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _selectedRole == 1 ? Colors.white : AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'KPIs, Plano y Ajustes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _selectedRole == 1 ? Colors.white70 : AppColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bottleGreen,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      if (_selectedRole == 0) {
                        context.go('/admin/waiter');
                      } else {
                        context.go('/admin');
                      }
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: Text(
                      _selectedRole == 0 ? 'Entrar a Sala como Camarero' : 'Entrar al Panel como Dueño',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Standard Credentials Form
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acceso con Credenciales Supabase',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: _busy ? l10n.sending : 'Iniciar sesión con contraseña',
                    kind: AppButtonKind.outlined,
                    onPressed: _busy ? null : _submit,
                  ),
                ],
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
      // In demo mode, route according to role
      if (mounted) {
        if (_selectedRole == 0) {
          context.go('/admin/waiter');
        } else {
          context.go('/admin');
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
