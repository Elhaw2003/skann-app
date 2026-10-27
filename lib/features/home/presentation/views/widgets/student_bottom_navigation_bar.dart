import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentBottomNavigationBar extends StatelessWidget {
  const StudentBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    _NavigationDestination(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavigationDestination(label: 'البحث', icon: Icons.search_rounded),
    _NavigationDestination(label: 'سكناتي', icon: Icons.apartment_rounded),
    _NavigationDestination(
      label: 'المفضلة',
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
    ),
    _NavigationDestination(
      label: 'حسابي',
      icon: Icons.account_circle_outlined,
      selectedIcon: Icons.account_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: const Color(0xFFE8EDF4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.11),
              blurRadius: 24.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
        child: Row(
          children: List.generate(_destinations.length, (index) {
            final destination = _destinations[index];
            final isSelected = index == selectedIndex;

            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label: destination.label,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () => onDestinationSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 58.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEAF3FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isSelected
                                  ? destination.selectedIcon ?? destination.icon
                                  : destination.icon,
                              key: ValueKey(isSelected),
                              color: isSelected
                                  ? const Color(0xFF0868C9)
                                  : const Color(0xFF555D6B),
                              size: 23.sp,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0868C9)
                                  : const Color(0xFF555D6B),
                              fontSize: 10.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}
