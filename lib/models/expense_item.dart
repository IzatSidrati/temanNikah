enum PaymentStatus {
  unpaid,
  downPayment,
  paid,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Belum Bayar';
      case PaymentStatus.downPayment:
        return 'DP (Down Payment)';
      case PaymentStatus.paid:
        return 'Lunas';
    }
  }

  String get shortLabel {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Belum';
      case PaymentStatus.downPayment:
        return 'DP';
      case PaymentStatus.paid:
        return 'Lunas';
    }
  }
}

class ExpenseItem {
  final String id;
  final String title;
  final String category; // 'Venue & Dekorasi', 'Katering', 'Busana & MUA', 'Foto & Video', 'Undangan & Souvenir', 'Mahar & Seserahan', 'Lainnya'
  final double estimatedCost;
  final double actualCost;
  final double paidAmount;
  final PaymentStatus status;
  final DateTime? dueDate;
  final String notes;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.estimatedCost,
    required this.actualCost,
    this.paidAmount = 0,
    this.status = PaymentStatus.unpaid,
    this.dueDate,
    this.notes = '',
  });

  double get remainingAmount => (actualCost > 0 ? actualCost : estimatedCost) - paidAmount;

  ExpenseItem copyWith({
    String? id,
    String? title,
    String? category,
    double? estimatedCost,
    double? actualCost,
    double? paidAmount,
    PaymentStatus? status,
    DateTime? dueDate,
    String? notes,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'paidAmount': paidAmount,
      'status': status.index,
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'],
      title: json['title'],
      category: json['category'] ?? 'Lainnya',
      estimatedCost: (json['estimatedCost'] ?? 0.0).toDouble(),
      actualCost: (json['actualCost'] ?? 0.0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
      status: PaymentStatus.values[json['status'] ?? 0],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      notes: json['notes'] ?? '',
    );
  }
}
