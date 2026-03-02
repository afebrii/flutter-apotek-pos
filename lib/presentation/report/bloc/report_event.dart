abstract class ReportEvent {}

class ReportFetch extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  ReportFetch({
    required this.startDate,
    required this.endDate,
  });
}

class ReportRefresh extends ReportEvent {}
