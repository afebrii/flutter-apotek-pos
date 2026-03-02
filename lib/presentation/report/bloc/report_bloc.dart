import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/report_remote_datasource.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRemoteDatasource _datasource;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  ReportBloc({ReportRemoteDatasource? datasource})
      : _datasource = datasource ?? ReportRemoteDatasource(),
        super(ReportInitial()) {
    on<ReportFetch>(_onFetch);
    on<ReportRefresh>(_onRefresh);
  }

  Future<void> _onFetch(
    ReportFetch event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    _lastStartDate = event.startDate;
    _lastEndDate = event.endDate;

    final startDateStr = _formatDate(event.startDate);
    final endDateStr = _formatDate(event.endDate);

    final result = await _datasource.getSalesReport(
      startDate: startDateStr,
      endDate: endDateStr,
    );

    result.fold(
      (error) => emit(ReportError(message: error)),
      (report) => emit(ReportLoaded(
        report: report,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onRefresh(
    ReportRefresh event,
    Emitter<ReportState> emit,
  ) async {
    if (_lastStartDate != null && _lastEndDate != null) {
      add(ReportFetch(
        startDate: _lastStartDate!,
        endDate: _lastEndDate!,
      ));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
