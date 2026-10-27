import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';

class HomeQuickFilters extends StatelessWidget {
  const HomeQuickFilters({
    required this.filters,
    required this.onTap,
    super.key,
  });

  final PropertyFilters filters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chips = [
      _FilterChipData(
        icon: Icons.location_on_outlined,
        label: filters.city ?? 'المدينة',
        isSelected: filters.city != null || filters.governorate != null,
      ),
      _FilterChipData(
        icon: Icons.payments_outlined,
        label: _priceLabel(),
        isSelected: filters.minPrice != null || filters.maxPrice != null,
      ),
      _FilterChipData(
        icon: Icons.apartment_rounded,
        label: _propertyTypeLabel(),
        isSelected: filters.propertyType != null,
      ),
      _FilterChipData(
        icon: Icons.wifi_rounded,
        label: filters.amenities.isEmpty
            ? 'الخدمات'
            : 'الخدمات (${filters.amenities.length})',
        isSelected: filters.amenities.isNotEmpty,
      ),
    ];

    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return ActionChip(
            onPressed: onTap,
            avatar: Icon(
              chip.icon,
              size: 16.sp,
              color: chip.isSelected
                  ? const Color(0xFF0B67C8)
                  : const Color(0xFF697B91),
            ),
            label: Text(chip.label),
            labelStyle: TextStyle(
              color: chip.isSelected
                  ? const Color(0xFF0B67C8)
                  : const Color(0xFF5C6D81),
              fontSize: 10.sp,
              fontWeight: chip.isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            backgroundColor: chip.isSelected
                ? const Color(0xFFEAF3FF)
                : Colors.white,
            side: BorderSide(
              color: chip.isSelected
                  ? const Color(0xFFB7D7FA)
                  : const Color(0xFFE6EBF2),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
          );
        },
      ),
    );
  }

  String _priceLabel() {
    if (filters.minPrice == null && filters.maxPrice == null) return 'السعر';
    if (filters.minPrice != null && filters.maxPrice != null) {
      return '${filters.minPrice} - ${filters.maxPrice} ج.م';
    }
    return filters.minPrice != null
        ? 'من ${filters.minPrice} ج.م'
        : 'حتى ${filters.maxPrice} ج.م';
  }

  String _propertyTypeLabel() => switch (filters.propertyType) {
    'STUDENT_HOUSING' => 'سكن طلاب',
    'SHARED_APARTMENT' => 'شقة مشتركة',
    _ => 'نوع السكن',
  };
}

class _FilterChipData {
  const _FilterChipData({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
}
