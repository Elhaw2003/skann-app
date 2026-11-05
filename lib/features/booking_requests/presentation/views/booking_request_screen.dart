import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_request_form_widgets.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_request_success_view.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

typedef BookingRequestRouteData = ({
  PropertyRoomPropertyModel property,
  PropertyRoomModel room,
});

class BookingRequestScreen extends StatelessWidget {
  const BookingRequestScreen({
    required this.property,
    required this.room,
    super.key,
  });

  final PropertyRoomPropertyModel property;
  final PropertyRoomModel room;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingRequestsCubit>(),
      child: _BookingRequestForm(property: property, room: room),
    );
  }
}

class _BookingRequestForm extends StatefulWidget {
  const _BookingRequestForm({required this.property, required this.room});

  final PropertyRoomPropertyModel property;
  final PropertyRoomModel room;

  @override
  State<_BookingRequestForm> createState() => _BookingRequestFormState();
}

class _BookingRequestFormState extends State<_BookingRequestForm> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          title: const Text('إنشاء طلب حجز'),
          backgroundColor: const Color(0xFFF4F7FB),
          foregroundColor: const Color(0xFF1D3553),
          elevation: 0,
        ),
        body: SafeArea(
          child: BlocBuilder<BookingRequestsCubit, BookingRequestsStates>(
            builder: (context, state) {
              if (state is BookingCreatedSuccessfully) {
                return BookingRequestSuccessView(booking: state.booking);
              }

              return ListView(
                padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
                children: [
                  BookingSelectionSummary(
                    property: widget.property,
                    room: widget.room,
                  ),
                  SizedBox(height: 18.h),
                  BookingRequestMessageForm(
                    controller: _messageController,
                    isSubmitting: state is BookingRequestSubmitting,
                    errorMessage: state is BookingRequestSubmissionError
                        ? state.message
                        : null,
                    onSubmit: () => _submit(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<BookingRequestsCubit>().createBookingRequest(
      propertyId: widget.property.id ?? '',
      roomId: widget.room.id ?? '',
      message: _messageController.text,
    );
  }
}
