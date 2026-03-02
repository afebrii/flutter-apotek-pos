class XenditSaleResponse {
  final bool success;
  final String message;
  final XenditSaleData data;

  XenditSaleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory XenditSaleResponse.fromJson(Map<String, dynamic> json) {
    return XenditSaleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: XenditSaleData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class XenditSaleData {
  final int saleId;
  final String invoiceNumber;
  final double total;
  final XenditInfo xendit;

  XenditSaleData({
    required this.saleId,
    required this.invoiceNumber,
    required this.total,
    required this.xendit,
  });

  factory XenditSaleData.fromJson(Map<String, dynamic> json) {
    // Parse total which can be String, int, or double
    double totalAmount = 0;
    final rawTotal = json['total'];
    if (rawTotal is String) {
      totalAmount = double.tryParse(rawTotal) ?? 0;
    } else if (rawTotal is num) {
      totalAmount = rawTotal.toDouble();
    }

    return XenditSaleData(
      saleId: json['sale_id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      total: totalAmount,
      xendit: XenditInfo.fromJson(json['xendit'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'sale_id': saleId,
        'invoice_number': invoiceNumber,
        'total': total,
        'xendit': xendit.toJson(),
      };
}

class XenditInfo {
  final int transactionId;
  final String externalId;
  final String invoiceUrl;
  final String status;
  final String expiresAt;

  XenditInfo({
    required this.transactionId,
    required this.externalId,
    required this.invoiceUrl,
    required this.status,
    required this.expiresAt,
  });

  factory XenditInfo.fromJson(Map<String, dynamic> json) {
    return XenditInfo(
      transactionId: json['transaction_id'] ?? 0,
      externalId: json['external_id'] ?? '',
      invoiceUrl: json['invoice_url'] ?? '',
      status: json['status'] ?? '',
      expiresAt: json['expires_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'external_id': externalId,
        'invoice_url': invoiceUrl,
        'status': status,
        'expires_at': expiresAt,
      };
}
