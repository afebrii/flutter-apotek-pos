import '../../../data/models/responses/xendit_check_response.dart';
import '../../../data/models/responses/xendit_invoice_response.dart';
import '../../../data/models/responses/xendit_sale_response.dart';
import '../../../data/models/responses/xendit_status_response.dart';

abstract class XenditState {}

class XenditInitial extends XenditState {}

class XenditLoading extends XenditState {}

// Status states
class XenditStatusLoaded extends XenditState {
  final XenditStatusData status;

  XenditStatusLoaded(this.status);
}

class XenditStatusError extends XenditState {
  final String message;

  XenditStatusError(this.message);
}

// Sale creation states
class XenditSaleCreated extends XenditState {
  final XenditSaleData sale;

  XenditSaleCreated(this.sale);
}

class XenditSaleError extends XenditState {
  final String message;

  XenditSaleError(this.message);
}

// Invoice creation states
class XenditInvoiceCreated extends XenditState {
  final XenditInvoiceData invoice;

  XenditInvoiceCreated(this.invoice);
}

class XenditInvoiceError extends XenditState {
  final String message;

  XenditInvoiceError(this.message);
}

// Payment status states
class XenditPaymentPending extends XenditState {
  final XenditCheckData data;

  XenditPaymentPending(this.data);
}

class XenditPaymentSuccess extends XenditState {
  final XenditCheckData data;

  XenditPaymentSuccess(this.data);
}

class XenditPaymentExpired extends XenditState {
  final XenditCheckData data;

  XenditPaymentExpired(this.data);
}

class XenditPaymentError extends XenditState {
  final String message;

  XenditPaymentError(this.message);
}

// Cancel states
class XenditPaymentCancelled extends XenditState {
  final String message;

  XenditPaymentCancelled(this.message);
}
