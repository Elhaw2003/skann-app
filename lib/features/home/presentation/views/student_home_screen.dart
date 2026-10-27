import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:skann_app/features/home/presentation/cubit/home_state.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_filter_sheet.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_header.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_quick_filters.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_state_views.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_search_field.dart';
import 'package:skann_app/features/home/presentation/views/widgets/student_bottom_navigation_bar.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const _StudentHomeView(),
    );
  }
}

class _StudentHomeView extends StatefulWidget {
  const _StudentHomeView();

  @override
  State<_StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<_StudentHomeView> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  int _selectedNavigationIndex = 0;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        bottomNavigationBar: StudentBottomNavigationBar(
          selectedIndex: _selectedNavigationIndex,
          onDestinationSelected: (index) {
            if (index == 4) {
              context.go(AppRoutes.profile);
              return;
            }
            setState(() => _selectedNavigationIndex = index);
          },
        ),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeInitial() || HomeLoading() => const HomeLoadingView(),
                HomeFailure(:final message) => HomeFailureView(
                  message: message,
                  onRetry: context.read<HomeCubit>().load,
                ),
                HomeLoaded() => _buildLoadedContent(context, state),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, HomeLoaded state) {
    final cubit = context.read<HomeCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      color: const Color(0xFF0B67C8),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 320 &&
              notification.metrics.axisDirection == AxisDirection.down) {
            cubit.loadNextPage();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HomeHeader(),
                    PropertySearchField(
                      controller: _searchController,
                      onChanged: _scheduleSearch,
                      onSubmitted: _submitSearch,
                      onClear: _clearSearch,
                      activeFilterCount: state.filters.activeCount,
                      onOpenFilters: () => _showFilters(context, state),
                    ),
                    SizedBox(height: 12.h),
                    HomeQuickFilters(
                      filters: state.filters,
                      onTap: () => _showFilters(context, state),
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'سكنات ممكن تعجبك',
                            style: TextStyle(
                              color: const Color(0xFF213B5A),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!state.isUpdating)
                          Text(
                            '${state.pagination.totalItems} مكان',
                            style: TextStyle(
                              color: const Color(0xFF8492A3),
                              fontSize: 10.sp,
                            ),
                          ),
                      ],
                    ),
                    if (state.isUpdating) ...[
                      SizedBox(height: 11.h),
                      const LinearProgressIndicator(
                        minHeight: 2,
                        color: Color(0xFF0B67C8),
                        backgroundColor: Color(0xFFE6EEF7),
                      ),
                    ],
                    SizedBox(height: 13.h),
                    if (state.requestError != null)
                      HomeInlineError(
                        message: state.requestError ?? '',
                        actionLabel: 'إعادة المحاولة',
                        onAction: cubit.refresh,
                      ),
                  ],
                ),
              ),
            ),
            if (state.properties.isEmpty && state.isUpdating)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0B67C8)),
                ),
              )
            else if (state.properties.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: HomeEmptyView(
                  onResetFilters: () {
                    _searchDebounce?.cancel();
                    _searchController.clear();
                    cubit.clearSearchAndFilters();
                  },
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final property = state.properties[index];
                    final propertyId = property.id;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
                      child: InkWell(
                        onTap: propertyId == null || propertyId.trim().isEmpty
                            ? null
                            : () => context.push(
                                AppRoutes.propertyDetails.replaceFirst(
                                  ':propertyId',
                                  Uri.encodeComponent(propertyId),
                                ),
                              ),
                        borderRadius: BorderRadius.circular(21.r),
                        child: PropertyCard(
                          key: ValueKey(propertyId),
                          property: property,
                        ),
                      ),
                    );
                  }, childCount: state.properties.length),
                ),
              ),
            if (state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(18.w),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0B67C8),
                    ),
                  ),
                ),
              )
            else if (state.loadMoreError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 20.h),
                  child: HomeInlineError(
                    message: state.loadMoreError ?? '',
                    actionLabel: 'حاول تاني',
                    onAction: cubit.loadNextPage,
                  ),
                ),
              )
            else
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          ],
        ),
      ),
    );
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<HomeCubit>().search(value);
    });
  }

  void _submitSearch(String value) {
    _searchDebounce?.cancel();
    context.read<HomeCubit>().search(value);
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    context.read<HomeCubit>().search('');
  }

  Future<void> _showFilters(BuildContext context, HomeLoaded state) {
    return showHomeFilterSheet(
      context,
      cubit: context.read<HomeCubit>(),
      filters: state.filters,
    );
  }
}
