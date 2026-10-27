import 'package:flutter/material.dart';
import 'package:skann_app/features/home/presentation/views/widgets/amenity_icon_mapping.dart';

String propertyTypeLabel(String type) => switch (type) {
  'STUDENT_HOUSING' => 'سكن طلاب',
  'SHARED_APARTMENT' => 'شقة مشتركة',
  _ => type.replaceAll('_', ' '),
};

String genderPolicyLabel(String policy) => switch (policy) {
  'MALE' => 'طلاب',
  'FEMALE' => 'طالبات',
  _ => policy,
};

String propertyCurrencyLabel(String? currency) =>
    currency == null || currency == 'EGP' ? 'ج.م' : currency;

String propertyPriceText(num price) =>
    price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);

IconData propertyAmenityIcon(String amenity) {
  final normalized = amenity.toLowerCase();
  if (normalized.contains('wifi')) return amenityIcon('wifi');
  if (normalized.contains('air conditioning')) return amenityIcon('ac');
  if (normalized.contains('kitchen')) return amenityIcon('kitchen');
  if (normalized.contains('washing machine')) return amenityIcon('washer');
  if (normalized.contains('refrigerator')) return amenityIcon('fridge');
  return amenityIcon(null);
}
