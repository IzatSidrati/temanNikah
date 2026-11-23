class WeddingInfo {
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String weddingLocation;
  final double totalBudget;
  final String notes;

  WeddingInfo({
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    required this.weddingLocation,
    required this.totalBudget,
    this.notes = '',
  });

  WeddingInfo copyWith({
    String? groomName,
    String? brideName,
    DateTime? weddingDate,
    String? weddingLocation,
    double? totalBudget,
    String? notes,
  }) {
    return WeddingInfo(
      groomName: groomName ?? this.groomName,
      brideName: brideName ?? this.brideName,
      weddingDate: weddingDate ?? this.weddingDate,
      weddingLocation: weddingLocation ?? this.weddingLocation,
      totalBudget: totalBudget ?? this.totalBudget,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groomName': groomName,
      'brideName': brideName,
      'weddingDate': weddingDate.toIso8601String(),
      'weddingLocation': weddingLocation,
      'totalBudget': totalBudget,
      'notes': notes,
    };
  }

  factory WeddingInfo.fromJson(Map<String, dynamic> json) {
    return WeddingInfo(
      groomName: json['groomName'] ?? 'Pengantin Pria',
      brideName: json['brideName'] ?? 'Pengantin Wanita',
      weddingDate: json['weddingDate'] != null 
          ? DateTime.parse(json['weddingDate']) 
          : DateTime.now().add(const Duration(days: 180)),
      weddingLocation: json['weddingLocation'] ?? 'Jakarta, Indonesia',
      totalBudget: (json['totalBudget'] ?? 150000000.0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }
}
