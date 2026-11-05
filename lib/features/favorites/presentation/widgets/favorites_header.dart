import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_state.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({required this.state, super.key});

  final FavoritesState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 4.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [Color(0xFFEAF3FF), Color(0xFFF9FBFE)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFDCE9F7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المفضلة',
                    style: TextStyle(
                      color: const Color(0xFF1D3553),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'الأماكن اللي اخترتها لسكنك القادم',
                    style: TextStyle(
                      color: const Color(0xFF6D8097),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: const Color(0xFFE44861),
                    size: 22.sp,
                  ),
                  if (state.hasLoaded)
                    Text(
                      '${state.pagination.totalItems}',
                      style: TextStyle(
                        color: const Color(0xFF536A84),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
