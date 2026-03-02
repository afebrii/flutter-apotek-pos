import '../../../data/models/requests/xendit_sale_request.dart';

abstract class XenditEvent {}

class XenditCheckStatus extends XenditEvent {}

class XenditCreateSale extends XenditEvent {
  final XenditSaleRequest request;

  XenditCreateSale(this.request);
}

class XenditCreateInvoice extends XenditEvent {
  final int saleId;
  final String? paymentMethodCode;

  XenditCreateInvoice({
    required this.saleId,
    this.paymentMethodCode,
  });
}

class XenditCheckPaymentStatus extends XenditEvent {
  final int transactionId;

  XenditCheckPaymentStatus(this.transactionId);
}

class XenditCancelPayment extends XenditEvent {
  final int transactionId;

  XenditCancelPayment(this.transactionId);
}

class XenditStartPolling extends XenditEvent {
  final int transactionId;

  XenditStartPolling(this.transactionId);
}

class XenditStopPolling extends XenditEvent {}

class XenditReset extends XenditEvent {}
