abstract class CategoryEvent {}

class CategoryFetch extends CategoryEvent {}

class CategorySelect extends CategoryEvent {
  final int? categoryId;

  CategorySelect(this.categoryId);
}

class CategoryReset extends CategoryEvent {}
