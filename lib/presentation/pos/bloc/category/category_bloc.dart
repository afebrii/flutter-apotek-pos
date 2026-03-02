import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/category_remote_datasource.dart';
import '../../../../data/models/responses/category_model.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRemoteDatasource _categoryRemoteDatasource;

  CategoryBloc(this._categoryRemoteDatasource) : super(CategoryInitial()) {
    on<CategoryFetch>(_onFetch);
    on<CategorySelect>(_onSelect);
    on<CategoryReset>(_onReset);
  }

  Future<void> _onFetch(
    CategoryFetch event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await _categoryRemoteDatasource.getCategories();

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(CategoryError(error));
    } else {
      final categories = result.fold((l) => <CategoryModel>[], (r) => r);
      // Add "All" category at the beginning
      final allCategories = [CategoryModel.all(), ...categories];
      emit(CategoryLoaded(
        categories: allCategories,
        selectedCategoryId: null, // null means "All"
      ));
    }
  }

  void _onSelect(
    CategorySelect event,
    Emitter<CategoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(currentState.copyWith(
        selectedCategoryId: event.categoryId,
      ));
    }
  }

  void _onReset(
    CategoryReset event,
    Emitter<CategoryState> emit,
  ) {
    emit(CategoryInitial());
  }
}
