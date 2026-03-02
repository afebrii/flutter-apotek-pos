import '../../../data/models/responses/shift_model.dart';

abstract class ShiftEvent {}

class ShiftCheckCurrent extends ShiftEvent {}

class ShiftOpen extends ShiftEvent {
  final OpenShiftRequest request;

  ShiftOpen(this.request);
}

class ShiftClose extends ShiftEvent {
  final CloseShiftRequest request;

  ShiftClose(this.request);
}

class ShiftFetchSummary extends ShiftEvent {}

class ShiftFetchSales extends ShiftEvent {
  final int perPage;

  ShiftFetchSales({this.perPage = 20});
}

class ShiftReset extends ShiftEvent {}
