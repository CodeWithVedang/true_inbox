import 'package:flutter/material.dart';

import '../../models/sms_category.dart';

class CategoryFilterBar extends StatelessWidget {
  final SmsCategory selected;
  final ValueChanged<SmsCategory> onChanged;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = SmsCategory.values;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final c = categories[index];
          final isSelected = c == selected;
          final colorScheme = Theme.of(context).colorScheme;

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  c.icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : c == SmsCategory.malicious
                          ? colorScheme.error
                          : c.color,
                ),
                const SizedBox(width: 4),
                Text(c.label),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onChanged(c),
          );
        },
      ),
    );
  }
}
