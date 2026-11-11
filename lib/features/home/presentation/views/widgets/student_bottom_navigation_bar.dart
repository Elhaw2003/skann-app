import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_unread_cubit.dart';

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
    _NavigationDestination(
      label: 'المفضلة',
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
    ),
    _NavigationDestination(
      label: 'البروفايل',
      icon: Icons.account_circle_outlined,
      selectedIcon: Icons.account_circle_rounded,
    ),
    _NavigationDestination(
      label: 'حجوزاتي',
      icon: Icons.bookmark_border_rounded,
      selectedIcon: Icons.bookmark_rounded,
    ),
    _NavigationDestination(
      label: 'المحادثات',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatUnreadCubit, ChatUnreadState>(
      builder: (context, unreadState) => SafeArea(
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
                                  ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                              child: _DestinationIcon(
                                key: ValueKey(isSelected),
                                destination: destination,
                                isSelected: isSelected,
                                unreadCount: index == 4 ? unreadState.count : 0,
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
      ),
    );
  }
}

class _DestinationIcon extends StatelessWidget {
  const _DestinationIcon({
    required this.destination,
    required this.isSelected,
    required this.unreadCount,
    super.key,
  });

  final _NavigationDestination destination;
  final bool isSelected;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isSelected
              ? destination.selectedIcon ?? destination.icon
              : destination.icon,
          color: isSelected ? const Color(0xFF0868C9) : const Color(0xFF555D6B),
          size: 23.sp,
        ),
        if (unreadCount > 0)
          Positioned(
            top: -7.h,
            right: -11.w,
            child: Container(
              constraints: BoxConstraints(minWidth: 17.w, minHeight: 17.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE44855),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
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
