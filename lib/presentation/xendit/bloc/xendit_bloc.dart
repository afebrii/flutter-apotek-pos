import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/xendit_remote_datasource.dart';
import 'xendit_event.dart';
import 'xendit_state.dart';

class XenditBloc extends Bloc<XenditEvent, XenditState> {
  final XenditRemoteDatasource _datasource;
  Timer? _pollingTimer;

  XenditBloc(this._datasource) : super(XenditInitial()) {
    on<XenditCheckStatus>(_onCheckStatus);
    on<XenditCreateSale>(_onCreateSale);
    on<XenditCreateInvoice>(_onCreateInvoice);
    on<XenditCheckPaymentStatus>(_onCheckPaymentStatus);
    on<XenditCancelPayment>(_onCancelPayment);
    on<XenditStartPolling>(_onStartPolling);
    on<XenditStopPolling>(_onStopPolling);
    on<XenditReset>(_onReset);
  }

  Future<void> _onCheckStatus(
    XenditCheckStatus event,
    Emitter<XenditState> emit,
  ) async {
    emit(XenditLoading());
    final result = await _datasource.getStatus();
    result.fold(
      (error) => emit(XenditStatusError(error)),
      (response) => emit(XenditStatusLoaded(response.data)),
    );
  }

  Future<void> _onCreateSale(
    XenditCreateSale event,
    Emitter<XenditState> emit,
  ) async {
    emit(XenditLoading());
    final result = await _datasource.createSaleWithPayment(event.request);
    result.fold(
      (error) => emit(XenditSaleError(error)),
      (response) => emit(XenditSaleCreated(response.data)),
    );
  }

  Future<void> _onCreateInvoice(
    XenditCreateInvoice event,
    Emitter<XenditState> emit,
  ) async {
    emit(XenditLoading());
    final result = await _datasource.createInvoice(
      saleId: event.saleId,
      paymentMethodCode: event.paymentMethodCode,
    );
    result.fold(
      (error) => emit(XenditInvoiceError(error)),
      (response) => emit(XenditInvoiceCreated(response.data)),
    );
  }

  Future<void> _onCheckPaymentStatus(
    XenditCheckPaymentStatus event,
    Emitter<XenditState> emit,
  ) async {
    final result = await _datasource.checkStatus(event.transactionId);
    result.fold(
      (error) => emit(XenditPaymentError(error)),
      (response) {
        final data = response.data;
        if (data.isPaid) {
          _stopPollingTimer();
          emit(XenditPaymentSuccess(data));
        } else if (data.isExpired == true) {
          _stopPollingTimer();
          emit(XenditPaymentExpired(data));
        } else {
          emit(XenditPaymentPending(data));
        }
      },
    );
  }

  Future<void> _onCancelPayment(
    XenditCancelPayment event,
    Emitter<XenditState> emit,
  ) async {
    emit(XenditLoading());
    final result = await _datasource.cancelPayment(event.transactionId);
    result.fold(
      (error) => emit(XenditPaymentError(error)),
      (message) {
        _stopPollingTimer();
        emit(XenditPaymentCancelled(message));
      },
    );
  }

  void _onStartPolling(
    XenditStartPolling event,
    Emitter<XenditState> emit,
  ) {
    _stopPollingTimer();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      add(XenditCheckPaymentStatus(event.transactionId));
    });
  }

  void _onStopPolling(
    XenditStopPolling event,
    Emitter<XenditState> emit,
  ) {
    _stopPollingTimer();
  }

  void _onReset(
    XenditReset event,
    Emitter<XenditState> emit,
  ) {
    _stopPollingTimer();
    emit(XenditInitial());
  }

  void _stopPollingTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _stopPollingTimer();
    return super.close();
  }
}
