import '../../../data/models/responses/shift_model.dart';
import '../../../data/models/responses/shift_summary_model.dart';

abstract class ShiftState {}

class ShiftInitial extends ShiftState {}

class ShiftLoading extends ShiftState {}

/// No active shift - need to open one
class ShiftNotFound extends ShiftState {}

/// Has active shift
class ShiftActive extends ShiftState {
  final ShiftModel shift;

  ShiftActive(this.shift);
}

/// Shift opened successfully
class ShiftOpened extends ShiftState {
  final ShiftModel shift;

  ShiftOpened(this.shift);
}

/// Shift closed successfully
class ShiftClosed extends ShiftState {
  final ShiftModel shift;

  ShiftClosed(this.shift);
}

/// Shift summary loaded
class ShiftSummaryLoaded extends ShiftState {
  final ShiftSummaryModel summary;

  ShiftSummaryLoaded(this.summary);
}

/// Shift sales loaded
class ShiftSalesLoaded extends ShiftState {
  final ShiftSalesResponse sales;

  ShiftSalesLoaded(this.sales);
}

class ShiftError extends ShiftState {
  final String message;

  ShiftError(this.message);
}
