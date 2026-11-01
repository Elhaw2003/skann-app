import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/matching_roommates_screen.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/roommates_directory_view.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/widgets/roommates_tab_selector.dart';

class RoommatesScreen extends StatelessWidget {
  const RoommatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MatchingRoommatesCubit>()..load()),
        BlocProvider(create: (_) => sl<RoommatesDirectoryCubit>()),
      ],
      child: const RoommatesView(),
    );
  }
}

class RoommatesView extends StatefulWidget {
  const RoommatesView({super.key});

  @override
  State<RoommatesView> createState() => _RoommatesViewState();
}

class _RoommatesViewState extends State<RoommatesView> {
  int _selectedTab = 0;
  Widget? _directoryTab;

  void _selectTab(int index) {
    if (index == _selectedTab) return;
    setState(() {
      _selectedTab = index;
      if (index == 1) {
        _directoryTab ??= const RoommatesDirectoryView();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F7FB),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'زملاء السكن',
            style: TextStyle(
              color: const Color(0xFF14263F),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 14.h),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'اعثر على زميل السكن المناسب ليك',
                    style: TextStyle(
                      color: const Color(0xFF71809A),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: RoommatesTabSelector(
                  selectedIndex: _selectedTab,
                  onSelected: _selectTab,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    const MatchingRoommatesView(),
                    _directoryTab ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
