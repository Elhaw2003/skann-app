import 'package:flutter/material.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';

IconData amenityIcon(String? identifier) {
  return switch (identifier?.toLowerCase()) {
    'wifi' => Icons.wifi_rounded,
    'ac' => Icons.ac_unit_rounded,
    'balcony' => Icons.balcony_rounded,
    'kitchen' => Icons.kitchen_rounded,
    'washer' => Icons.local_laundry_service_rounded,
    'fridge' => Icons.kitchen_outlined,
    'bathroom' => Icons.bathtub_outlined,
    'security' => Icons.security_rounded,
    'study' => Icons.menu_book_rounded,
    'parking' => Icons.local_parking_rounded,
    'electricity' => Icons.electrical_services_rounded,
    'gas' => Icons.local_fire_department_outlined,
    'water' => Icons.water_drop_outlined,
    'elevator' => Icons.elevator_outlined,
    'desk' => Icons.desk_outlined,
    'microwave' => Icons.microwave_outlined,
    'tv' => Icons.tv_rounded,
    'wardrobe' => Icons.checkroom_rounded,
    _ => Icons.home_repair_service_outlined,
  };
}

String amenityArabicName(AmenityModel amenity) {
  return switch (amenity.icon?.toLowerCase()) {
    'wifi' => 'واي فاي',
    'ac' => 'تكييف',
    'balcony' => 'شرفة',
    'kitchen' => 'مطبخ',
    'washer' => 'غسالة',
    'fridge' => 'ثلاجة',
    'bathroom' => 'حمام خاص',
    'security' => 'أمن',
    'study' => 'منطقة مذاكرة',
    'parking' => 'موقف سيارات',
    'electricity' => 'كهرباء',
    'gas' => 'غاز',
    'water' => 'مياه',
    'elevator' => 'مصعد',
    'desk' => 'مكتب',
    'microwave' => 'ميكروويف',
    'tv' => 'تلفزيون',
    'wardrobe' => 'دولاب',
    _ => amenity.name,
  };
}

String amenityCategoryArabicName(String? category) {
  return switch (category?.toLowerCase()) {
    'connectivity' => 'الاتصال',
    'comfort' => 'الراحة',
    'general' => 'أساسيات',
    'appliances' => 'أجهزة',
    'safety' => 'الأمان',
    'facilities' => 'مرافق',
    'building' => 'المبنى',
    'utilities' => 'خدمات',
    'furniture' => 'أثاث',
    'entertainment' => 'ترفيه',
    _ => category ?? 'أخرى',
  };
}
