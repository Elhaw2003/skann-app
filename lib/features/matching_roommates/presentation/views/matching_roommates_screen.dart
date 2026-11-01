import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_state.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/widgets/matching_roommates_widgets.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/widgets/roommate_card.dart';

class MatchingRoommatesScreen extends StatelessWidget {
  const MatchingRoommatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MatchingRoommatesCubit>()..load(),
      child: Directionality(
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
          body: const SafeArea(top: false, child: MatchingRoommatesView()),
        ),
      ),
    );
  }
}

class MatchingRoommatesView extends StatefulWidget {
  const MatchingRoommatesView({super.key});

  @override
  State<MatchingRoommatesView> createState() => _MatchingRoommatesViewState();
}

class _MatchingRoommatesViewState extends State<MatchingRoommatesView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNextPageNearBottom);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadNextPageNearBottom)
      ..dispose();
    super.dispose();
  }

  void _loadNextPageNearBottom() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 240) {
      context.read<MatchingRoommatesCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<MatchingRoommatesCubit, MatchingRoommatesState>(
        builder: (context, state) => switch (state) {
          MatchingRoommatesInitial() ||
          MatchingRoommatesLoading() => _buildLoading(),
          MatchingRoommatesFailure(:final message) => _buildFailure(
            context,
            message,
          ),
          MatchingRoommatesLoaded() => _buildRoommateList(context, state),
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
      children: [
        const MatchingRoommatesHeader(),
        SizedBox(height: 130.h),
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ],
    );
  }

  Widget _buildFailure(BuildContext context, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
      children: [
        const MatchingRoommatesHeader(),
        SizedBox(height: 55.h),
        MatchingRoommatesStatus(
          icon: Icons.wifi_off_rounded,
          title: 'تعذر تحميل زملاء السكن',
          message: message,
          actionLabel: 'إعادة المحاولة',
          onAction: context.read<MatchingRoommatesCubit>().load,
        ),
      ],
    );
  }

  Widget _buildRoommateList(
    BuildContext context,
    MatchingRoommatesLoaded state,
  ) {
    final hasRoommates = state.roommates.isNotEmpty;
    final itemCount = hasRoommates ? state.roommates.length + 2 : 2;

    return RefreshIndicator(
      onRefresh: context.read<MatchingRoommatesCubit>().refresh,
      color: AppColors.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                const MatchingRoommatesHeader(),
                if (state.isRefreshing) ...[
                  SizedBox(height: 12.h),
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primaryColor,
                    backgroundColor: Color(0xFFE1EAF5),
                  ),
                ],
                if (state.refreshError case final error?) ...[
                  SizedBox(height: 10.h),
                  MatchingRoommatesInlineError(message: error),
                ],
                SizedBox(height: 16.h),
              ],
            );
          }

          if (!hasRoommates) {
            return const MatchingRoommatesEmptyState();
          }

          if (index <= state.roommates.length) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: RoommateCard(roommate: state.roommates[index - 1]),
            );
          }

          return MatchingRoommatesPaginationFooter(
            isLoading: state.isLoadingMore,
            error: state.loadMoreError,
            onRetry: context.read<MatchingRoommatesCubit>().loadNextPage,
          );
        },
      ),
    );
  }
}
