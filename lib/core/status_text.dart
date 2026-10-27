import '../l10n/app_localizations.dart';

String statusText(AppLocalizations l10n, String status) {
  return switch (status) {
    'pending' => l10n.statusPending,
    'confirmed' => l10n.statusConfirmed,
    'seated' => l10n.statusSeated,
    'completed' => l10n.statusCompleted,
    'cancelled' => l10n.statusCancelled,
    'no_show' => l10n.statusNoShow,
    _ => status,
  };
}

String roleText(AppLocalizations l10n, String role) {
  return switch (role) {
    'owner' => l10n.roleOwner,
    'manager' => l10n.roleManager,
    'waiter' => l10n.roleWaiter,
    _ => role,
  };
}
