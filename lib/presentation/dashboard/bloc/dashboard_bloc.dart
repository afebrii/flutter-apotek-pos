import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../data/models/responses/dashboard_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDatasource _datasource;

  DashboardBloc({DashboardRemoteDatasource? datasource})
      : _datasource = datasource ?? DashboardRemoteDatasource(),
        super(DashboardInitial()) {
    on<DashboardFetch>(_onFetch);
    on<DashboardRefresh>(_onRefresh);
  }

  Future<void> _onFetch(DashboardFetch event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    // Fetch summary first
    final summaryResult = await _datasource.getSummary();

    if (summaryResult.isLeft()) {
      final error = summaryResult.fold((l) => l, (r) => '');
      emit(DashboardError(message: error));
      return;
    }

    final summary = summaryResult.fold((l) => null, (r) => r);
    if (summary == null) {
      emit(DashboardError(message: 'Gagal memuat dashboard'));
      return;
    }

    // Emit initial loaded state with loading flags
    emit(DashboardLoaded(
      summary: summary,
      isLoadingLowStock: true,
      isLoadingExpiring: true,
    ));

    // Fetch low stock and expiring data in parallel
    final results = await Future.wait([
      _datasource.getLowStockProducts(),
      _datasource.getExpiringBatches(),
    ]);

    final lowStockResult = results[0];
    final expiringResult = results[1];

    // Get latest state
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    // Extract data
    List<LowStockProductModel> lowStockProducts = [];
    List<ExpiringBatchModel> expiringBatches = [];

    if (lowStockResult.isRight()) {
      lowStockProducts = lowStockResult.fold(
        (l) => <LowStockProductModel>[],
        (r) => r as List<LowStockProductModel>,
      );
    }

    if (expiringResult.isRight()) {
      expiringBatches = expiringResult.fold(
        (l) => <ExpiringBatchModel>[],
        (r) => r as List<ExpiringBatchModel>,
      );
    }

    // Emit final state with all data
    emit(currentState.copyWith(
      lowStockProducts: lowStockProducts,
      expiringBatches: expiringBatches,
      isLoadingLowStock: false,
      isLoadingExpiring: false,
    ));
  }

  Future<void> _onRefresh(DashboardRefresh event, Emitter<DashboardState> emit) async {
    add(DashboardFetch());
  }
}
