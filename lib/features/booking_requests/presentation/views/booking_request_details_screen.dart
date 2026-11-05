import 'package:flutter/material.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_request_details_content.dart';

class BookingRequestDetailsScreen extends StatelessWidget {
  const BookingRequestDetailsScreen({required this.booking, super.key});

  final BookingRequestModel booking;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          title: const Text('تفاصيل طلب الحجز'),
          backgroundColor: const Color(0xFFF4F7FB),
          foregroundColor: const Color(0xFF1D3553),
          elevation: 0,
        ),
        body: BookingRequestDetailsContent(booking: booking),
      ),
    );
  }
}
