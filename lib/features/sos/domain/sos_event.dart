class SosEvent {
  SosEvent({
    required this.id,
    required this.eventId,
    required this.sourceNodeId,
    required this.status,
    required this.acknowledgementHistory,
    required this.createdAt,
    required this.isActive,
  });

  final String id;
  final String eventId;
  final String sourceNodeId;
  String status;
  final List<String> acknowledgementHistory;
  final DateTime createdAt;
  bool isActive;

  factory SosEvent.fromJson(Map<String, dynamic> json) {
    return SosEvent(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      sourceNodeId: json['sourceNodeId'] as String,
      status: json['status'] as String,
      acknowledgementHistory: List<String>.from(
        json['acknowledgementHistory'] as List,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'sourceNodeId': sourceNodeId,
    'status': status,
    'acknowledgementHistory': acknowledgementHistory,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };
}
