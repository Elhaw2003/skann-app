import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertySearchField extends StatelessWidget {
  const PropertySearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onOpenFilters,
    required this.activeFilterCount,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(color: const Color(0xFFE7ECF3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F3E64).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'دور على سكنك أو جامعتك',
                hintStyle: TextStyle(
                  color: const Color(0xFF98A5B5),
                  fontSize: 12.sp,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF66819F),
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: onClear,
                          tooltip: 'مسح البحث',
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: const Color(0xFF0B67C8),
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: onOpenFilters,
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  width: 54.w,
                  height: 54.h,
                  child: Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 23.sp,
                  ),
                ),
              ),
            ),
            if (activeFilterCount > 0)
              PositionedDirectional(
                top: -5.h,
                end: -5.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  constraints: BoxConstraints(minWidth: 19.w, minHeight: 19.h),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE67E22),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$activeFilterCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
