import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_list_state_views.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/my_bookings_content.dart';
import 'package:skann_app/features/home/presentation/views/widgets/student_bottom_navigation_bar.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingRequestsCubit>()..loadRequests(),
      child: const _MyBookingsView(),
    );
  }
}

class _MyBookingsView extends StatelessWidget {
  const _MyBookingsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        bottomNavigationBar: StudentBottomNavigationBar(
          selectedIndex: 3,
          onDestinationSelected: (index) {
            if (index == 0) context.go(AppRoutes.studentHome);
            if (index == 1) context.go(AppRoutes.favorites);
            if (index == 2) context.go(AppRoutes.profile);
          },
        ),
        body: SafeArea(
          child: BlocBuilder<BookingRequestsCubit, BookingRequestsStates>(
            builder: (context, state) => switch (state) {
              BookingRequestsInitial() ||
              BookingRequestsLoading() => const BookingListLoadingView(),
              BookingRequestsError(:final message, :final filter) =>
                BookingListErrorView(
                  message: message,
                  onRetry: () => context
                      .read<BookingRequestsCubit>()
                      .loadRequests(filter: filter),
                ),
              BookingRequestsLoadingMore() => MyBookingsContent(
                state: state,
                isLoadingMore: true,
              ),
              BookingRequestsRefreshing() => MyBookingsContent(
                state: state,
                isRefreshing: true,
              ),
              BookingRequestsLoaded() => MyBookingsContent(state: state),
              _ => const BookingListLoadingView(),
            },
          ),
        ),
      ),
    );
  }
}
