import '../../../data/models/responses/report_model.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final SalesReportModel report;
  final DateTime startDate;
  final DateTime endDate;

  ReportLoaded({
    required this.report,
    required this.startDate,
    required this.endDate,
  });
}

class ReportError extends ReportState {
  final String message;

  ReportError({required this.message});
}
