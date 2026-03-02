class ShiftModel {
  final int id;
  final String openingCash;
  final String? expectedCash;
  final String? actualCash;
  final String? difference;
  final DateTime openingTime;
  final DateTime? closingTime;
  final String status;
  final String? notes;

  ShiftModel({
    required this.id,
    required this.openingCash,
    this.expectedCash,
    this.actualCash,
    this.difference,
    required this.openingTime,
    this.closingTime,
    required this.status,
    this.notes,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] ?? 0,
      openingCash: json['opening_cash']?.toString() ?? '0',
      expectedCash: json['expected_cash']?.toString(),
      actualCash: json['actual_cash']?.toString(),
      difference: json['difference']?.toString(),
      openingTime: DateTime.parse(json['opening_time']),
      closingTime: json['closing_time'] != null
          ? DateTime.parse(json['closing_time'])
          : null,
      status: json['status'] ?? 'open',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'opening_cash': openingCash,
        'expected_cash': expectedCash,
        'actual_cash': actualCash,
        'difference': difference,
        'opening_time': openingTime.toIso8601String(),
        'closing_time': closingTime?.toIso8601String(),
        'status': status,
        'notes': notes,
      };

  bool get isOpen => status == 'open';

  double get openingCashAmount => double.tryParse(openingCash) ?? 0;
  double get expectedCashAmount => double.tryParse(expectedCash ?? '0') ?? 0;
  double get actualCashAmount => double.tryParse(actualCash ?? '0') ?? 0;
  double get differenceAmount => double.tryParse(difference ?? '0') ?? 0;
}

class OpenShiftRequest {
  final double openingCash;
  final String? notes;

  OpenShiftRequest({
    required this.openingCash,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'opening_cash': openingCash,
        if (notes != null) 'notes': notes,
      };
}

class CloseShiftRequest {
  final double actualCash;
  final String? notes;

  CloseShiftRequest({
    required this.actualCash,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'actual_cash': actualCash,
        if (notes != null) 'notes': notes,
      };
}
