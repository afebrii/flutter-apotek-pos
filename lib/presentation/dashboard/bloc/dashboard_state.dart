import '../../../data/models/responses/dashboard_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummaryModel summary;
  final List<LowStockProductModel> lowStockProducts;
  final List<ExpiringBatchModel> expiringBatches;
  final bool isLoadingLowStock;
  final bool isLoadingExpiring;

  DashboardLoaded({
    required this.summary,
    this.lowStockProducts = const [],
    this.expiringBatches = const [],
    this.isLoadingLowStock = false,
    this.isLoadingExpiring = false,
  });

  DashboardLoaded copyWith({
    DashboardSummaryModel? summary,
    List<LowStockProductModel>? lowStockProducts,
    List<ExpiringBatchModel>? expiringBatches,
    bool? isLoadingLowStock,
    bool? isLoadingExpiring,
  }) {
    return DashboardLoaded(
      summary: summary ?? this.summary,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      expiringBatches: expiringBatches ?? this.expiringBatches,
      isLoadingLowStock: isLoadingLowStock ?? this.isLoadingLowStock,
      isLoadingExpiring: isLoadingExpiring ?? this.isLoadingExpiring,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}
