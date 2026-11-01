import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommates_directory_filters.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_state.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/widgets/roommate_card.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/widgets/roommates_directory_widgets.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/widgets/roommates_filter_sheet.dart';

class RoommatesDirectoryView extends StatefulWidget {
  const RoommatesDirectoryView({super.key});

  @override
  State<RoommatesDirectoryView> createState() => _RoommatesDirectoryViewState();
}

class _RoommatesDirectoryViewState extends State<RoommatesDirectoryView> {
  final _scrollController = ScrollController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RoommatesDirectoryCubit>();
    final currentState = cubit.state;
    _searchController = TextEditingController(
      text: currentState is RoommatesDirectoryLoaded ? currentState.search : '',
    );
    _scrollController.addListener(_loadNextPageNearBottom);
    cubit.load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadNextPageNearBottom)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadNextPageNearBottom() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 240) {
      context.read<RoommatesDirectoryCubit>().loadNextPage();
    }
  }

  Future<void> _openFilters(RoommatesDirectoryLoaded state) {
    return showRoommatesFilterSheet(
      context,
      cubit: context.read<RoommatesDirectoryCubit>(),
      filters: state.filters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoommatesDirectoryCubit, RoommatesDirectoryState>(
      builder: (context, state) => switch (state) {
        RoommatesDirectoryInitial() ||
        RoommatesDirectoryLoading() => _buildLoading(),
        RoommatesDirectoryFailure(:final message) => _buildFailure(
          context,
          message,
        ),
        RoommatesDirectoryLoaded() => _buildDirectory(context, state),
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
      children: [
        _buildToolbar(const RoommatesDirectoryFilters()),
        SizedBox(height: 90.h),
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ],
    );
  }

  Widget _buildFailure(BuildContext context, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
      children: [
        _buildToolbar(const RoommatesDirectoryFilters()),
        SizedBox(height: 38.h),
        RoommatesDirectoryStatus(
          icon: Icons.wifi_off_rounded,
          title: 'تعذر تحميل الطلاب',
          message: message,
          actionLabel: 'إعادة المحاولة',
          onAction: context.read<RoommatesDirectoryCubit>().load,
        ),
      ],
    );
  }

  Widget _buildDirectory(BuildContext context, RoommatesDirectoryLoaded state) {
    final roommates = state.visibleRoommates;
    final isEmpty = roommates.isEmpty;
    final itemCount = isEmpty ? 3 : roommates.length + 2;

    return RefreshIndicator(
      onRefresh: context.read<RoommatesDirectoryCubit>().refresh,
      color: AppColors.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 18.h),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildToolbar(state.filters, state: state);
          }
          if (isEmpty && index == 1) {
            return RoommatesDirectoryStatus(
              icon: Icons.search_off_rounded,
              title: state.search.isNotEmpty
                  ? 'مفيش زملاء سكن مطابقين للبحث'
                  : 'لا يوجد زملاء سكن مطابقون',
              message: 'جرّب تغيّر الفلاتر أو تبحث بمعايير مختلفة.',
              actionLabel: state.search.isNotEmpty || !state.filters.isEmpty
                  ? 'مسح البحث والفلاتر'
                  : null,
              onAction: state.search.isNotEmpty || !state.filters.isEmpty
                  ? () => _clearSearchAndFilters(context)
                  : null,
            );
          }
          if (!isEmpty && index <= roommates.length) {
            return Padding(
              padding: EdgeInsets.only(bottom: 11.h),
              child: RoommateCard(roommate: roommates[index - 1]),
            );
          }

          return RoommatesDirectoryPaginationFooter(
            isLoading: state.isLoadingMore,
            hasNextPage: state.pagination.hasNextPage,
            error: state.loadMoreError,
            onRetry: context.read<RoommatesDirectoryCubit>().loadNextPage,
          );
        },
      ),
    );
  }

  Widget _buildToolbar(
    RoommatesDirectoryFilters filters, {
    RoommatesDirectoryLoaded? state,
  }) {
    final cubit = context.read<RoommatesDirectoryCubit>();
    return RoommatesDirectoryToolbar(
      controller: _searchController,
      filters: filters,
      state: state,
      onSearchChanged: cubit.updateSearch,
      onClearSearch: () {
        _searchController.clear();
        cubit.updateSearch('');
      },
      onOpenFilters: state == null ? null : () => _openFilters(state),
      onFiltersChanged: cubit.applyFilters,
    );
  }

  Future<void> _clearSearchAndFilters(BuildContext context) async {
    _searchController.clear();
    final cubit = context.read<RoommatesDirectoryCubit>();
    cubit.updateSearch('');
    await cubit.resetFilters();
  }
}
