// lib/widgets/list_category_menu_widget.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:landing_page_menu/domain/entities/category_entity.dart';

class ListCategoryMenuWidget extends StatefulWidget {
  final List<CategoryEntity> categories;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ListCategoryMenuWidget({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<ListCategoryMenuWidget> createState() => _ListCategoryMenuWidgetState();
}

class _ListCategoryMenuWidgetState extends State<ListCategoryMenuWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Menu Icon
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFEB5EAD)),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),

          // Tabs
          Expanded(
            child: SizedBox(
              height: 48,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.categories.map((category) {
                      final isSelected = widget.selectedIndex == category.id;
                      return GestureDetector(
                        onTap: () {
                          if (category.id != null) {
                            widget.onTabSelected(category.id!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFFEB5EAD)
                                        : Colors.black,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    // ✅ Jarak 4px
                                    margin: const EdgeInsets.only(top: 4.0),
                                    height: 3.0,
                                    // ✅ Lebar mengikuti teks
                                    width: double.infinity,
                                    color: const Color(0xFFEB5EAD),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
