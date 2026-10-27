import '../core/money.dart';

class FloorTable {
  const FloorTable({
    required this.id,
    required this.label,
    required this.capacity,
    required this.posX,
    required this.posY,
    required this.width,
    required this.height,
    required this.shape,
    required this.active,
  });

  factory FloorTable.fromMap(Map<String, dynamic> map) {
    return FloorTable(
      id: map['id']?.toString() ?? '',
      label: map['label'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      posX: asMoney(map['pos_x']),
      posY: asMoney(map['pos_y']),
      width: asMoney(map['width']),
      height: asMoney(map['height']),
      shape: map['shape'] as String? ?? 'rect',
      active: map['active'] as bool? ?? true,
    );
  }

  final String id;
  final String label;
  final int capacity;
  final double posX;
  final double posY;
  final double width;
  final double height;
  final String shape;
  final bool active;

  FloorTable copyWith({double? posX, double? posY}) {
    return FloorTable(
      id: id,
      label: label,
      capacity: capacity,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      width: width,
      height: height,
      shape: shape,
      active: active,
    );
  }
}
