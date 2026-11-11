import 'package:equatable/equatable.dart';

enum ChatMessageDelivery { sent, sending, failed }

class ChatPage<T> {
  const ChatPage({
    required this.items,
    required this.page,
    required this.hasNextPage,
  });

  final List<T> items;
  final int page;
  final bool hasNextPage;
}

class ChatParticipant extends Equatable {
  const ChatParticipant({
    required this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.role,
    this.university,
    this.faculty,
    this.major,
  });

  final String id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? role;
  final String? university;
  final String? faculty;
  final String? major;

  String get displayName {
    final name = _clean(fullName);
    if (name != null) return name;
    return [_clean(firstName), _clean(lastName)].whereType<String>().join(' ');
  }

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      ChatParticipant(
        id: _requiredString(json, 'id'),
        fullName: _string(json['fullName']),
        firstName: _string(json['firstName']),
        lastName: _string(json['lastName']),
        profileImage: _string(json['profileImage']),
        role: _string(json['role']),
        university: _string(json['university']),
        faculty: _string(json['faculty']),
        major: _string(json['major']),
      );

  @override
  List<Object?> get props => [
    id,
    fullName,
    firstName,
    lastName,
    profileImage,
    role,
    university,
    faculty,
    major,
  ];
}

class ChatProperty extends Equatable {
  const ChatProperty({
    required this.id,
    this.title,
    this.city,
    this.area,
    this.address,
    this.imageUrl,
  });

  final String id;
  final String? title;
  final String? city;
  final String? area;
  final String? address;
  final String? imageUrl;

  String get location =>
      [area, city].map(_clean).whereType<String>().join('، ');

  factory ChatProperty.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    String? imageUrl;
    if (rawImages is List && rawImages.isNotEmpty && rawImages.first is Map) {
      imageUrl = _string(rawImages.first['url']);
    }

    return ChatProperty(
      id: _requiredString(json, 'id'),
      title: _string(json['title']),
      city: _string(json['city']),
      area: _string(json['area']),
      address: _string(json['address']),
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, city, area, address, imageUrl];
}

class ChatConversation extends Equatable {
  const ChatConversation({
    required this.id,
    this.type,
    this.property,
    this.participantIds = const [],
    this.participants = const [],
    this.recipient,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  final String id;
  final String? type;
  final ChatProperty? property;
  final List<String> participantIds;
  final List<ChatParticipant> participants;
  final ChatParticipant? recipient;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadCount;

  ChatParticipant? otherParticipant(String? currentUserId) {
    if (recipient != null &&
        recipient!.id.isNotEmpty &&
        recipient!.id != currentUserId) {
      return recipient;
    }
    for (final participant in participants) {
      if (participant.id.isNotEmpty && participant.id != currentUserId) {
        return participant;
      }
    }
    return recipient;
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'];
    final rawParticipantIds = json['participantIds'];
    final rawRecipient = json['recipient'];
    final rawProperty = json['property'];

    return ChatConversation(
      id: _requiredString(json, 'id'),
      type: _string(json['type']),
      property: rawProperty is Map
          ? ChatProperty.fromJson(Map<String, dynamic>.from(rawProperty))
          : null,
      participantIds: rawParticipantIds is List
          ? rawParticipantIds.whereType<String>().toList(growable: false)
          : const [],
      participants: rawParticipants is List
          ? rawParticipants
                .whereType<Map>()
                .map(
                  (participant) => ChatParticipant.fromJson(
                    Map<String, dynamic>.from(participant),
                  ),
                )
                .toList(growable: false)
          : const [],
      recipient: rawRecipient is Map
          ? ChatParticipant.fromJson(Map<String, dynamic>.from(rawRecipient))
          : null,
      lastMessageText: _string(json['lastMessageText']),
      lastMessageAt: _dateTime(json['lastMessageAt']),
      lastMessageSenderId: _string(json['lastMessageSenderId']),
      unreadCount: _integer(json['unreadCount']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    property,
    participantIds,
    participants,
    recipient,
    lastMessageText,
    lastMessageAt,
    lastMessageSenderId,
    unreadCount,
  ];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.sender,
    this.delivery = ChatMessageDelivery.sent,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final ChatParticipant? sender;
  final ChatMessageDelivery delivery;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    ChatParticipant? sender,
    ChatMessageDelivery? delivery,
  }) => ChatMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    text: text ?? this.text,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
    readAt: readAt ?? this.readAt,
    sender: sender ?? this.sender,
    delivery: delivery ?? this.delivery,
  );

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawSender = json['sender'];
    return ChatMessage(
      id: _requiredString(json, 'id'),
      conversationId: _requiredString(json, 'conversationId'),
      senderId: _requiredString(json, 'senderId'),
      text: _requiredString(json, 'text'),
      createdAt: _requiredDateTime(json, 'createdAt'),
      isRead: json['isRead'] is bool ? json['isRead'] as bool : false,
      readAt: _dateTime(json['readAt']),
      sender: rawSender is Map
          ? ChatParticipant.fromJson(Map<String, dynamic>.from(rawSender))
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    text,
    createdAt,
    isRead,
    readAt,
    sender,
    delivery,
  ];
}

String? _string(Object? value) {
  if (value is! String) return null;
  return _clean(value);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _string(json[key]);
  if (value == null) {
    throw FormatException('Required string "$key" is missing or invalid.');
  }
  return value;
}

DateTime _requiredDateTime(Map<String, dynamic> json, String key) {
  final value = _dateTime(json[key]);
  if (value == null) {
    throw FormatException('Required date "$key" is missing or invalid.');
  }
  return value;
}

String? _clean(String? value) {
  final cleaned = value?.trim();
  return cleaned == null || cleaned.isEmpty || cleaned.toLowerCase() == 'null'
      ? null
      : cleaned;
}

DateTime? _dateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

int? _integer(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
