class XenditInvoiceResponse {
  final bool success;
  final String message;
  final XenditInvoiceData data;

  XenditInvoiceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory XenditInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return XenditInvoiceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: XenditInvoiceData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class XenditInvoiceData {
  final int transactionId;
  final String externalId;
  final String invoiceUrl;
  final double amount;
  final String status;
  final String expiresAt;

  XenditInvoiceData({
    required this.transactionId,
    required this.externalId,
    required this.invoiceUrl,
    required this.amount,
    required this.status,
    required this.expiresAt,
  });

  factory XenditInvoiceData.fromJson(Map<String, dynamic> json) {
    // Parse amount which can be String, int, or double
    double amountValue = 0;
    final rawAmount = json['amount'];
    if (rawAmount is String) {
      amountValue = double.tryParse(rawAmount) ?? 0;
    } else if (rawAmount is num) {
      amountValue = rawAmount.toDouble();
    }

    return XenditInvoiceData(
      transactionId: json['transaction_id'] ?? 0,
      externalId: json['external_id'] ?? '',
      invoiceUrl: json['invoice_url'] ?? '',
      amount: amountValue,
      status: json['status'] ?? '',
      expiresAt: json['expires_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'external_id': externalId,
        'invoice_url': invoiceUrl,
        'amount': amount,
        'status': status,
        'expires_at': expiresAt,
      };
}
