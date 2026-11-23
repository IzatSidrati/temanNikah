enum RsvpStatus {
  pending,
  attending,
  declined,
  tentative,
}

extension RsvpStatusExtension on RsvpStatus {
  String get label {
    switch (this) {
      case RsvpStatus.pending:
        return 'Belum Konfirmasi';
      case RsvpStatus.attending:
        return 'Akan Hadir';
      case RsvpStatus.declined:
        return 'Tidak Hadir';
      case RsvpStatus.tentative:
        return 'Belum Pasti';
    }
  }
}

class GuestItem {
  final String id;
  final String name;
  final String category; // 'Keluarga Pria', 'Keluarga Wanita', 'Teman Pria', 'Teman Wanita', 'Rekan Kerja', 'VIP', 'Tetangga'
  final int pax;
  final bool isInvitationSent;
  final RsvpStatus rsvpStatus;
  final String tableNumber;
  final String phoneNumber;
  final String notes;

  GuestItem({
    required this.id,
    required this.name,
    required this.category,
    this.pax = 1,
    this.isInvitationSent = false,
    this.rsvpStatus = RsvpStatus.pending,
    this.tableNumber = '',
    this.phoneNumber = '',
    this.notes = '',
  });

  GuestItem copyWith({
    String? id,
    String? name,
    String? category,
    int? pax,
    bool? isInvitationSent,
    RsvpStatus? rsvpStatus,
    String? tableNumber,
    String? phoneNumber,
    String? notes,
  }) {
    return GuestItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      pax: pax ?? this.pax,
      isInvitationSent: isInvitationSent ?? this.isInvitationSent,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      tableNumber: tableNumber ?? this.tableNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'pax': pax,
      'isInvitationSent': isInvitationSent,
      'rsvpStatus': rsvpStatus.index,
      'tableNumber': tableNumber,
      'phoneNumber': phoneNumber,
      'notes': notes,
    };
  }

  factory GuestItem.fromJson(Map<String, dynamic> json) {
    return GuestItem(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'Teman',
      pax: json['pax'] ?? 1,
      isInvitationSent: json['isInvitationSent'] ?? false,
      rsvpStatus: RsvpStatus.values[json['rsvpStatus'] ?? 0],
      tableNumber: json['tableNumber'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
