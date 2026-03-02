import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/shift_remote_datasource.dart';
import 'shift_event.dart';
import 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final ShiftRemoteDatasource _shiftRemoteDatasource;

  ShiftBloc(this._shiftRemoteDatasource) : super(ShiftInitial()) {
    on<ShiftCheckCurrent>(_onCheckCurrent);
    on<ShiftOpen>(_onOpenShift);
    on<ShiftClose>(_onCloseShift);
    on<ShiftFetchSummary>(_onFetchSummary);
    on<ShiftFetchSales>(_onFetchSales);
    on<ShiftReset>(_onReset);
  }

  Future<void> _onCheckCurrent(
    ShiftCheckCurrent event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());

    final result = await _shiftRemoteDatasource.getCurrentShift();

    result.fold(
      (error) => emit(ShiftError(error)),
      (shift) {
        if (shift != null) {
          emit(ShiftActive(shift));
        } else {
          emit(ShiftNotFound());
        }
      },
    );
  }

  Future<void> _onOpenShift(
    ShiftOpen event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());

    final result = await _shiftRemoteDatasource.openShift(event.request);

    result.fold(
      (error) => emit(ShiftError(error)),
      (shift) => emit(ShiftOpened(shift)),
    );
  }

  Future<void> _onCloseShift(
    ShiftClose event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());

    final result = await _shiftRemoteDatasource.closeShift(event.request);

    result.fold(
      (error) => emit(ShiftError(error)),
      (shift) => emit(ShiftClosed(shift)),
    );
  }

  void _onReset(
    ShiftReset event,
    Emitter<ShiftState> emit,
  ) {
    emit(ShiftInitial());
  }

  Future<void> _onFetchSummary(
    ShiftFetchSummary event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());

    final result = await _shiftRemoteDatasource.getShiftSummary();

    result.fold(
      (error) => emit(ShiftError(error)),
      (summary) => emit(ShiftSummaryLoaded(summary)),
    );
  }

  Future<void> _onFetchSales(
    ShiftFetchSales event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());

    final result = await _shiftRemoteDatasource.getShiftSales(perPage: event.perPage);

    result.fold(
      (error) => emit(ShiftError(error)),
      (sales) => emit(ShiftSalesLoaded(sales)),
    );
  }
}
