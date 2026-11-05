import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:skann_app/features/favorites/presentation/widgets/favorite_property_card.dart';
import 'package:skann_app/features/favorites/presentation/widgets/favorites_header.dart';
import 'package:skann_app/features/favorites/presentation/widgets/favorites_state_views.dart';

class FavoritesContent extends StatelessWidget {
  const FavoritesContent({required this.state, super.key});

  final FavoritesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoritesCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refreshFavorites,
      color: const Color(0xFF0B67C8),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 320 &&
              notification.metrics.axisDirection == AxisDirection.down) {
            cubit.loadMoreFavorites();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: FavoritesHeader(state: state)),
            if (state.isRefreshing)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: Color(0xFF0B67C8),
                ),
              ),
            if (state.errorMessage case final message?)
              SliverToBoxAdapter(
                child: InlineFavoritesError(
                  message: message,
                  onRetry: cubit.refreshFavorites,
                ),
              ),
            if (state.properties.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: FavoritesEmptyView(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                sliver: SliverList.builder(
                  itemCount: state.properties.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: FavoritePropertyCard(
                      property: state.properties[index],
                    ),
                  ),
                ),
              ),
            if (state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0B67C8),
                    ),
                  ),
                ),
              )
            else if (state.loadMoreError case final message?)
              SliverToBoxAdapter(
                child: InlineFavoritesError(
                  message: message,
                  onRetry: cubit.loadMoreFavorites,
                ),
              )
            else
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          ],
        ),
      ),
    );
  }
}
