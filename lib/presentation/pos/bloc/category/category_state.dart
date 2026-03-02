import '../../../../data/models/responses/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;

  CategoryLoaded({
    required this.categories,
    this.selectedCategoryId,
  });

  CategoryLoaded copyWith({
    List<CategoryModel>? categories,
    int? selectedCategoryId,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}
