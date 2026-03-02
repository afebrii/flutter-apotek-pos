import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyLight,
          ),
        ),
        child: Text(
          category.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class CategoryChipList extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategoryChipList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == 0
              ? selectedCategoryId == null
              : selectedCategoryId == category.id;

          return CategoryChip(
            category: category,
            isSelected: isSelected,
            onTap: () {
              onCategorySelected(category.id == 0 ? null : category.id);
            },
          );
        },
      ),
    );
  }
}
