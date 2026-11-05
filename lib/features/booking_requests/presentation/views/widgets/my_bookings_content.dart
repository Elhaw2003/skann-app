import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_list_state_views.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_request_card.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_status_filter_chips.dart';

class MyBookingsContent extends StatelessWidget {
  const MyBookingsContent({
    required this.state,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    super.key,
  });

  final BookingRequestsLoaded state;
  final bool isLoadingMore;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingRequestsCubit>();
    return RefreshIndicator(
      onRefresh: cubit.refreshRequests,
      color: const Color(0xFF0B67C8),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 300 &&
              notification.metrics.axisDirection == AxisDirection.down) {
            cubit.loadMoreRequests();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حجوزاتي',
                      style: TextStyle(
                        color: const Color(0xFF1D3553),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'تابع حالة طلبات الحجز الخاصة بك',
                      style: TextStyle(
                        color: const Color(0xFF748398),
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    BookingStatusFilterChips(selectedFilter: state.filter),
                    if (isRefreshing) ...[
                      SizedBox(height: 12.h),
                      const LinearProgressIndicator(
                        minHeight: 2,
                        color: Color(0xFF0B67C8),
                      ),
                    ],
                    if (state.refreshError case final error?) ...[
                      SizedBox(height: 10.h),
                      InlineBookingError(
                        message: error,
                        onRetry: cubit.refreshRequests,
                      ),
                    ],
                    if (state.cancellationError case final error?) ...[
                      SizedBox(height: 10.h),
                      Text(
                        error,
                        style: TextStyle(
                          color: const Color(0xFF9F3F3F),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (state.bookings.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyBookingsView(filter: state.filter),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 18.h),
                sliver: SliverList.builder(
                  itemCount: state.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];
                    final currentState = state;
                    final isCancelling =
                        currentState is BookingRequestsCancelling &&
                        currentState.bookingId == booking.id;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: BookingRequestCard(
                        booking: booking,
                        isCancelling: isCancelling,
                        onCancel: () =>
                            _confirmCancellation(context, cubit, booking),
                        onTap: () => context.push(
                          AppRoutes.bookingRequestDetails,
                          extra: booking,
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (isLoadingMore)
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
            else if (state.loadMoreError case final error?)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                  child: InlineBookingError(
                    message: error,
                    onRetry: cubit.loadMoreRequests,
                  ),
                ),
              )
            else
              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    BookingRequestsCubit cubit,
    BookingRequestModel booking,
  ) async {
    if (booking.status != 'PENDING') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء طلب الحجز'),
        content: const Text('هل أنت متأكد من إلغاء طلب الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await cubit.cancelBookingRequest(booking);
  }
}
