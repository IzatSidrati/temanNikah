class ChecklistItem {
  final String id;
  final String title;
  final String category; // 'H-12 Bulan', 'H-6 Bulan', 'H-3 Bulan', 'H-1 Bulan', 'H-1 Minggu', 'Hari H'
  final bool isDone;
  final DateTime? dueDate;
  final String pic;
  final String notes;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    this.isDone = false,
    this.dueDate,
    this.pic = '',
    this.notes = '',
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isDone,
    DateTime? dueDate,
    String? pic,
    String? notes,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      pic: pic ?? this.pic,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
      'pic': pic,
      'notes': notes,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      title: json['title'],
      category: json['category'] ?? 'Lainnya',
      isDone: json['isDone'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      pic: json['pic'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
