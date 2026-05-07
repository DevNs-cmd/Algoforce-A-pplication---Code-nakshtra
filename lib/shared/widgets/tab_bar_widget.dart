import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class TabBarWidget extends StatefulWidget {
  const TabBarWidget({
    super.key,
    required this.tabs,
    required this.onChange,
    this.initialIndex = 0,
  });

  final List<String> tabs;
  final ValueChanged<int> onChange;
  final int initialIndex;

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < widget.tabs.length; i++)
          InkWell(
            onTap: () {
              setState(() => _index = i);
              widget.onChange(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _index == i ? AppColors.purple : AppColors.border,
                    width: _index == i ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                widget.tabs[i],
                style: AppText.body(
                  size: 13,
                  color: _index == i ? AppColors.purple : AppColors.textMuted,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
