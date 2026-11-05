import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_common_widgets.dart';

class BookingRoomAction extends StatelessWidget {
  const BookingRoomAction({required this.room, required this.property, super.key});

  final PropertyRoomModel room;
  final PropertyRoomPropertyModel? property;

  @override
  Widget build(BuildContext context) {
    final propertyId = property?.id ?? '';
    final roomId = room.id ?? '';
    return BlocBuilder<BookingRequestsCubit, BookingRequestsStates>(
      builder: (context, state) {
        if (state case BookingRoomAvailable(
          propertyId: final checkedPropertyId,
          roomId: final checkedRoomId,
        ) when checkedPropertyId == propertyId && checkedRoomId == roomId) {
          final selectedProperty = property;
          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selectedProperty == null
                  ? null
                  : () async {
                      await context.push<void>(
                        AppRoutes.createBookingRequest,
                        extra: (property: selectedProperty, room: room),
                      );
                      if (!context.mounted) return;
                      await context
                          .read<BookingRequestsCubit>()
                          .checkRoomBooking(
                            propertyId: propertyId,
                            roomId: roomId,
                            force: true,
                          );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B67C8),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: const Text('إرسال طلب حجز'),
            ),
          );
        }

        if (state is BookingRoomAlreadyRequested &&
            _matchesBooking(state.booking, propertyId, roomId)) {
          return PropertySectionCard(
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFAD7413),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'لديك طلب حجز سابق لهذه الغرفة (${_statusLabel(state.booking)}).',
                    style: TextStyle(
                      color: const Color(0xFF52657B),
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is BookingRoomCheckError &&
            state.propertyId == propertyId &&
            state.roomId == roomId) {
          return PropertySectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.message,
                  style: TextStyle(
                    color: const Color(0xFF9F3F3F),
                    fontSize: 12.sp,
                  ),
                ),
                TextButton(
                  onPressed: () => context
                      .read<BookingRequestsCubit>()
                      .checkRoomBooking(
                        propertyId: propertyId,
                        roomId: roomId,
                        force: true,
                      ),
                  child: const Text('إعادة التحقق'),
                ),
              ],
            ),
          );
        }

        return PropertySectionCard(
          child: Row(
            children: [
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0B67C8),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'جارٍ التحقق من طلبات الحجز السابقة',
                style: TextStyle(
                  color: const Color(0xFF65778D),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _matchesBooking(
    BookingRequestModel booking,
    String propertyId,
    String roomId,
  ) {
    return (booking.propertyId ?? booking.property?.id) == propertyId &&
        (booking.roomId ?? booking.room?.id) == roomId;
  }

  String _statusLabel(BookingRequestModel booking) =>
      switch (booking.status?.toUpperCase()) {
        'PENDING' => 'قيد المراجعة',
        'APPROVED' => 'مقبول',
        'REJECTED' => 'مرفوض',
        _ => booking.status ?? 'غير محدد',
      };
}
