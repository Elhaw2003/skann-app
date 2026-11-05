import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';

class BookingStatusFilterChips extends StatelessWidget {
  const BookingStatusFilterChips({required this.selectedFilter, super.key});

  final BookingStatusFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: BookingStatusFilter.values.map((filter) {
          final selected = filter == selectedFilter;
          return Padding(
            padding: EdgeInsetsDirectional.only(end: 8.w),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              showCheckmark: false,
              onSelected: selected
                  ? null
                  : (_) => context
                        .read<BookingRequestsCubit>()
                        .filterRequests(filter),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF50647B),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: const Color(0xFF0B67C8),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? const Color(0xFF0B67C8)
                    : const Color(0xFFE0E7EF),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
