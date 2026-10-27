import 'staff_role.dart';

class HouseEvent {
  const HouseEvent({
    required this.id,
    required this.title,
    required this.description,
    DateTime? eventDate,
    this.imageUrl,
    this.published = false,
    DateTime? startsAt,
  }) : eventDate = eventDate ?? startsAt;

  factory HouseEvent.fromMap(Map<String, dynamic> map) {
    return HouseEvent(
      id: map['id']?.toString() ?? '',
      title: _textMap(map['title']),
      description: _textMap(map['description']),
      eventDate: DateTime.tryParse(map['event_date']?.toString() ?? ''),
      imageUrl: map['image_url'] as String?,
      published: map['published'] as bool? ?? false,
    );
  }

  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final DateTime? eventDate;
  DateTime? get startsAt => eventDate;
  final String? imageUrl;
  final bool published;

  String text(Map<String, String> values, String language) {
    return values['en'] ?? values[language] ?? values['es'] ?? values['eu'] ?? '';
  }

  static Map<String, String> _textMap(Object? value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item.toString()));
    }
    return const {};
  }
}

class ClosedDay {
  const ClosedDay({required this.day, required this.reason});

  factory ClosedDay.fromMap(Map<String, dynamic> map) {
    final raw = DateTime.tryParse(map['day']?.toString() ?? '');
    return ClosedDay(
      day: raw == null ? DateTime.now() : DateTime(raw.year, raw.month, raw.day),
      reason: map['reason'] as String? ?? '',
    );
  }

  final DateTime day;
  final String reason;
}

class AuditEntry {
  const AuditEntry({
    this.tableName = 'general',
    required this.action,
    this.createdAt,
    this.id,
    this.actorEmail,
    this.diff,
  });

  factory AuditEntry.fromMap(Map<String, dynamic> map) {
    return AuditEntry(
      tableName: map['table_name'] as String? ?? 'general',
      action: map['action'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      id: map['id']?.toString(),
      actorEmail: map['actor_email'] as String?,
      diff: map['diff'] as String?,
    );
  }

  final String tableName;
  final String action;
  final DateTime? createdAt;
  final String? id;
  final String? actorEmail;
  final String? diff;
}

class StaffProfile {
  StaffProfile({
    required this.id,
    this.fullName = '',
    dynamic role = 'waiter',
    String? email,
    this.active = true,
  })  : role = role is StaffRole ? role : (parseStaffRole(role?.toString()) ?? StaffRole.waiter),
        email = email ?? (fullName.isNotEmpty ? '${fullName.toLowerCase().replaceAll(' ', '.')}@iturrieta.eus' : 'staff@iturrieta.eus');

  factory StaffProfile.fromMap(Map<String, dynamic> map) {
    return StaffProfile(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: map['role']?.toString() ?? 'waiter',
      email: map['email'] as String?,
      active: map['active'] as bool? ?? true,
    );
  }

  final String id;
  final String fullName;
  final StaffRole role;
  final String email;
  final bool active;
}
