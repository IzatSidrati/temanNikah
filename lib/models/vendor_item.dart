class VendorItem {
  final String id;
  final String name;
  final String category; // 'Venue', 'Katering', 'Dekorasi', 'MUA & Busana', 'Dokumentasi', 'WO / Planner', 'Musik & MC', 'Undangan & Souvenir'
  final String contactPerson;
  final String phone;
  final String instagram;
  final double cost;
  final String status; // 'Riset', 'Diskusi', 'Booking (DP)', 'Lunas'
  final String notes;

  VendorItem({
    required this.id,
    required this.name,
    required this.category,
    this.contactPerson = '',
    this.phone = '',
    this.instagram = '',
    this.cost = 0.0,
    this.status = 'Riset',
    this.notes = '',
  });

  VendorItem copyWith({
    String? id,
    String? name,
    String? category,
    String? contactPerson,
    String? phone,
    String? instagram,
    double? cost,
    String? status,
    String? notes,
  }) {
    return VendorItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      instagram: instagram ?? this.instagram,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'contactPerson': contactPerson,
      'phone': phone,
      'instagram': instagram,
      'cost': cost,
      'status': status,
      'notes': notes,
    };
  }

  factory VendorItem.fromJson(Map<String, dynamic> json) {
    return VendorItem(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'Lainnya',
      contactPerson: json['contactPerson'] ?? '',
      phone: json['phone'] ?? '',
      instagram: json['instagram'] ?? '',
      cost: (json['cost'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Riset',
      notes: json['notes'] ?? '',
    );
  }
}
