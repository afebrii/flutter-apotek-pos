import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/store_remote_datasource.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRemoteDatasource _datasource;

  StoreBloc({StoreRemoteDatasource? datasource})
      : _datasource = datasource ?? StoreRemoteDatasource(),
        super(StoreInitial()) {
    on<StoreFetch>(_onStoreFetch);
    on<SettingsFetch>(_onSettingsFetch);
    on<StoreAndSettingsFetch>(_onStoreAndSettingsFetch);
    on<StoreReset>(_onReset);
  }

  Future<void> _onStoreFetch(StoreFetch event, Emitter<StoreState> emit) async {
    emit(StoreLoading());

    final result = await _datasource.getStore();

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(StoreError(message: error));
    } else {
      final store = result.fold((l) => null, (r) => r);
      if (store != null) {
        emit(StoreLoaded(store: store));
      } else {
        emit(StoreError(message: 'Gagal memuat data toko'));
      }
    }
  }

  Future<void> _onSettingsFetch(SettingsFetch event, Emitter<StoreState> emit) async {
    emit(StoreLoading());

    final result = await _datasource.getSettings();

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(StoreError(message: error));
    } else {
      final settings = result.fold((l) => null, (r) => r);
      if (settings != null) {
        emit(SettingsLoaded(settings: settings));
      } else {
        emit(StoreError(message: 'Gagal memuat settings'));
      }
    }
  }

  Future<void> _onStoreAndSettingsFetch(
    StoreAndSettingsFetch event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());

    final storeResult = await _datasource.getStore();

    if (storeResult.isLeft()) {
      final error = storeResult.fold((l) => l, (r) => '');
      emit(StoreError(message: error));
      return;
    }

    final store = storeResult.fold((l) => null, (r) => r);
    if (store == null) {
      emit(StoreError(message: 'Gagal memuat data toko'));
      return;
    }

    // Also fetch settings
    final settingsResult = await _datasource.getSettings();
    final settings = settingsResult.fold((l) => null, (r) => r);

    emit(StoreLoaded(store: store, settings: settings));
  }

  void _onReset(StoreReset event, Emitter<StoreState> emit) {
    emit(StoreInitial());
  }
}
