class XenditCheckResponse {
  final bool success;
  final XenditCheckData data;

  XenditCheckResponse({
    required this.success,
    required this.data,
  });

  factory XenditCheckResponse.fromJson(Map<String, dynamic> json) {
    return XenditCheckResponse(
      success: json['success'] ?? false,
      data: XenditCheckData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.toJson(),
      };
}

class XenditCheckData {
  final String status;
  final bool isPaid;
  final bool? isExpired;
  final String? paidAt;
  final String? expiresAt;
  final String? paymentMethod;
  final String? paymentChannel;
  final int? saleId;

  XenditCheckData({
    required this.status,
    required this.isPaid,
    this.isExpired,
    this.paidAt,
    this.expiresAt,
    this.paymentMethod,
    this.paymentChannel,
    this.saleId,
  });

  factory XenditCheckData.fromJson(Map<String, dynamic> json) {
    return XenditCheckData(
      status: json['status'] ?? '',
      isPaid: json['is_paid'] ?? false,
      isExpired: json['is_expired'],
      paidAt: json['paid_at'],
      expiresAt: json['expires_at'],
      paymentMethod: json['payment_method'],
      paymentChannel: json['payment_channel'],
      saleId: json['sale_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'is_paid': isPaid,
        'is_expired': isExpired,
        'paid_at': paidAt,
        'expires_at': expiresAt,
        'payment_method': paymentMethod,
        'payment_channel': paymentChannel,
        'sale_id': saleId,
      };
}
