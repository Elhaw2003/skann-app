import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';

class RoommatesTabSelector extends StatelessWidget {
  const RoommatesTabSelector({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFF7),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          _RoommatesTab(
            label: 'مقترحون ليك',
            icon: Icons.auto_awesome_outlined,
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _RoommatesTab(
            label: 'استكشف الطلاب',
            icon: Icons.search_rounded,
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
        ],
      ),
    );
  }
}

class _RoommatesTab extends StatelessWidget {
  const _RoommatesTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 7.w),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFF20344F,
                          ).withValues(alpha: 0.06),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 17.sp,
                    color: selected
                        ? AppColors.primaryColor
                        : const Color(0xFF7F90A6),
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF20344F)
                            : const Color(0xFF71809A),
                        fontSize: 11.sp,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
