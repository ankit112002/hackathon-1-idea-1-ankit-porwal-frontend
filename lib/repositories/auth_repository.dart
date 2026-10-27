import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/house_event.dart';
import '../models/staff_role.dart';
import 'supabase_guard.dart';

/// Staff sign-in. Roles live in `profiles`, enforced again by RLS.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<void> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<StaffRole?> currentRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    return parseStaffRole(row?['role']);
  }

  Future<List<StaffProfile>> staff() async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, role')
        .order('full_name');
    return rowList(rows).map(StaffProfile.fromMap).toList();
  }

  Future<void> setRole(String id, String role) {
    return guardBooking(() async {
      await _client.from('profiles').update({'role': role}).eq('id', id);
    });
  }
}
