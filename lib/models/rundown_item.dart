class RundownItem {
  final String id;
  final String eventType; // 'Akad / Pemberkatan', 'Resepsi', 'Pra-Nikah'
  final String timeRange; // e.g., '08:00 - 09:30'
  final String activity;
  final String pic;
  final String location;
  final String notes;

  RundownItem({
    required this.id,
    required this.eventType,
    required this.timeRange,
    required this.activity,
    this.pic = '',
    this.location = '',
    this.notes = '',
  });

  RundownItem copyWith({
    String? id,
    String? eventType,
    String? timeRange,
    String? activity,
    String? pic,
    String? location,
    String? notes,
  }) {
    return RundownItem(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      timeRange: timeRange ?? this.timeRange,
      activity: activity ?? this.activity,
      pic: pic ?? this.pic,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'timeRange': timeRange,
      'activity': activity,
      'pic': pic,
      'location': location,
      'notes': notes,
    };
  }

  factory RundownItem.fromJson(Map<String, dynamic> json) {
    return RundownItem(
      id: json['id'],
      eventType: json['eventType'] ?? 'Resepsi',
      timeRange: json['timeRange'] ?? '',
      activity: json['activity'] ?? '',
      pic: json['pic'] ?? '',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
