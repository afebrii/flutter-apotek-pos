import '../../../data/models/responses/store_model.dart';

abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final StoreModel store;
  final SettingsModel? settings;

  StoreLoaded({
    required this.store,
    this.settings,
  });

  StoreLoaded copyWith({
    StoreModel? store,
    SettingsModel? settings,
  }) {
    return StoreLoaded(
      store: store ?? this.store,
      settings: settings ?? this.settings,
    );
  }
}

class SettingsLoaded extends StoreState {
  final SettingsModel settings;

  SettingsLoaded({required this.settings});
}

class StoreError extends StoreState {
  final String message;

  StoreError({required this.message});
}
