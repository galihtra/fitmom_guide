import 'package:flutter/material.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../data/model/category/category_news_model.dart';
import '../../../../data/services/category_news/category_news_service.dart';

class CategoryFilterWidget extends StatefulWidget {
  final CategoryNewsService categoryService;
  final Function(String?) onCategorySelected;

  const CategoryFilterWidget({
    super.key,
    required this.categoryService,
    required this.onCategorySelected,
  });

  @override
  _CategoryFilterWidgetState createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: StreamBuilder<List<CategoryNewsModel>>(
        stream: widget.categoryService.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: const Text("Semua"),
                  selected: _selectedCategory == null,
                  selectedColor: MyColor.secondaryColor,
                  labelStyle: TextStyle(
                    color:
                        _selectedCategory == null ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedCategory = null);
                    widget.onCategorySelected(null);
                  },
                ),
              ),
              ...categories.map((category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(category.category),
                      selected: _selectedCategory == category.category,
                      selectedColor: MyColor.secondaryColor,
                      labelStyle: TextStyle(
                        color: _selectedCategory == category.category
                            ? Colors.white
                            : Colors.black,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = category.category);
                        widget.onCategorySelected(category.category);
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
