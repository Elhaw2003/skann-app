import 'package:equatable/equatable.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

class BookingRequestModel extends Equatable {
  const BookingRequestModel({
    this.id,
    this.studentId,
    this.propertyId,
    this.roomId,
    this.status,
    this.message,
    this.rejectionReason,
    this.reviewedById,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
    this.property,
    this.room,
  });

  final String? id;
  final String? studentId;
  final String? propertyId;
  final String? roomId;
  final String? status;
  final String? message;
  final String? rejectionReason;
  final String? reviewedById;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PropertyModel? property;
  final PropertyRoomModel? room;

  BookingRequestModel copyWith({String? status}) => BookingRequestModel(
    id: id,
    studentId: studentId,
    propertyId: propertyId,
    roomId: roomId,
    status: status ?? this.status,
    message: message,
    rejectionReason: rejectionReason,
    reviewedById: reviewedById,
    reviewedAt: reviewedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    property: property,
    room: room,
  );

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: _stringValue(json['id']),
      studentId: _stringValue(json['studentId']),
      propertyId: _stringValue(json['propertyId']),
      roomId: _stringValue(json['roomId']),
      status: _stringValue(json['status']),
      message: _stringValue(json['message']),
      rejectionReason: _stringValue(json['rejectionReason']),
      reviewedById: _stringValue(json['reviewedById']),
      reviewedAt: _dateTimeValue(json['reviewedAt']),
      createdAt: _dateTimeValue(json['createdAt']),
      updatedAt: _dateTimeValue(json['updatedAt']),
      property: _optionalObject(json['property'], PropertyModel.fromJson),
      room: _optionalObject(json['room'], PropertyRoomModel.fromJson),
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    propertyId,
    roomId,
    status,
    message,
    rejectionReason,
    reviewedById,
    reviewedAt,
    createdAt,
    updatedAt,
    property,
    room,
  ];
}

T? _optionalObject<T>(Object? value, T Function(Map<String, dynamic>) parser) {
  if (value is! Map) return null;
  return parser(Map<String, dynamic>.from(value));
}

String? _stringValue(Object? value) => value is String ? value : null;

DateTime? _dateTimeValue(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
