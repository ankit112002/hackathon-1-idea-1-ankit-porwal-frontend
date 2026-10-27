import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../viewport_controller.dart';
import 'locale_switcher.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.homePath,
    this.actions = const [],
    this.showBrandHeader = true,
  });

  final String title;
  final Widget body;
  final String? homePath;
  final List<Widget> actions;
  final bool showBrandHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewportMode = ref.watch(viewportModeProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktopWidth = width >= 800;

    Widget content = Scaffold(
      backgroundColor: AppColors.paper,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.line, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.center,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (homePath != null) ...[
                  IconButton(
                    tooltip: 'Volver',
                    onPressed: () => context.go(homePath!),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                // Brand wordmark & subtitle
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.go('/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Iturrieta',
                          style: GoogleFonts.fraunces(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bottleGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.bottleGreenWash,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.bottleGreen.withValues(alpha: 0.2)),
                          ),
                          child: const Text(
                            'Aramaio',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bottleGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (isDesktopWidth && viewportMode == ViewportMode.responsive) ...[
                          const SizedBox(width: 8),
                          Text(
                            '·  "Sagarretik txotxera"',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Desktop navigation links
                if (isDesktopWidth && viewportMode == ViewportMode.responsive) ...[
                  TextButton(
                    onPressed: () => context.go('/book'),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.bottleGreen),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/manage/ITU-8924'),
                    child: const Text(
                      'Tu Reserva',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/admin/login'),
                    child: const Text(
                      'Equipo',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.inkMuted),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                // Viewport mode switcher button (only shown on desktop or when mobile simulation is active)
                if (isDesktopWidth || viewportMode == ViewportMode.mobile390)
                  Tooltip(
                    message: viewportMode == ViewportMode.responsive
                        ? 'Simular Móvil (390px)'
                        : 'Ver Escritorio (1280px)',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => ref.read(viewportModeProvider.notifier).toggle(),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: viewportMode == ViewportMode.mobile390
                              ? AppColors.ciderWash
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: viewportMode == ViewportMode.mobile390
                                ? AppColors.cider
                                : AppColors.line,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              viewportMode == ViewportMode.mobile390
                                  ? Icons.phone_android
                                  : Icons.desktop_mac,
                              size: 16,
                              color: viewportMode == ViewportMode.mobile390
                                  ? AppColors.cider
                                  : AppColors.ink,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              viewportMode == ViewportMode.mobile390 ? '390px' : '1280px',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: viewportMode == ViewportMode.mobile390
                                    ? AppColors.cider
                                    : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ...actions,
                const LocaleSwitcher(),
              ],
            ),
          ),
        ),
      ),
      body: body,
    );

    // If 390px mobile viewport mode is active, center inside a simulated phone container
    if (viewportMode == ViewportMode.mobile390 && width > 450) {
      return Scaffold(
        backgroundColor: const Color(0xFFE8E0D2),
        body: Center(
          child: Container(
            width: 390,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.ink.withValues(alpha: 0.15), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
