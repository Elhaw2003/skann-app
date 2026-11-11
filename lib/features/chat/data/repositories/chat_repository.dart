import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatConversation>> startConversation({
    required String targetUserId,
    required String propertyId,
  });

  Future<Either<Failure, ChatPage<ChatConversation>>> getConversations({
    required int page,
    required int limit,
  });

  Future<Either<Failure, int>> getUnreadTotal();

  Future<Either<Failure, ChatConversation>> getConversation(String id);

  Future<Either<Failure, ChatPage<ChatMessage>>> getMessages({
    required String conversationId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required String text,
  });

  Future<Either<Failure, int>> markConversationRead(String conversationId);

  Future<Either<Failure, Unit>> deleteMessage({
    required String conversationId,
    required String messageId,
  });
}

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, ChatConversation>> startConversation({
    required String targetUserId,
    required String propertyId,
  }) async {
    if (targetUserId.trim().isEmpty || propertyId.trim().isEmpty) {
      return const Left(ValidationFailure('Chat contact is unavailable.'));
    }

    try {
      final response = await apiConsumer.post(
        EndPoint.conversations,
        data: {
          'targetUserId': targetUserId.trim(),
          'propertyId': propertyId.trim(),
        },
      );
      return Right(
        ChatConversation.fromJson(_responseData(response, 'Conversation')),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The conversation response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The conversation response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatPage<ChatConversation>>> getConversations({
    required int page,
    required int limit,
  }) async {
    if (page < 1 || limit < 1) {
      return const Left(ValidationFailure('Invalid conversation page.'));
    }
    try {
      final response = await apiConsumer.get(
        EndPoint.conversations,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = _responseData(response, 'Conversations');
      return Right(
        _pageFromData(
          data,
          label: 'Conversations',
          parseItem: ChatConversation.fromJson,
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The conversations response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The conversations response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadTotal() async {
    try {
      final data = _responseData(
        await apiConsumer.get(EndPoint.conversationsUnreadTotal),
        'Unread messages',
      );
      final unreadTotal = _integer(data['unreadTotal']);
      if (unreadTotal == null || unreadTotal < 0) {
        throw const FormatException('Unread total is invalid.');
      }
      return Right(unreadTotal);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The unread messages response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The unread messages response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> getConversation(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Invalid conversation ID.'));
    }
    try {
      final response = await apiConsumer.get(
        '${EndPoint.conversations}/${Uri.encodeComponent(id.trim())}',
      );
      return Right(
        ChatConversation.fromJson(_responseData(response, 'Conversation')),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The conversation response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The conversation response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatPage<ChatMessage>>> getMessages({
    required String conversationId,
    required int page,
    required int limit,
  }) async {
    if (conversationId.trim().isEmpty || page < 1 || limit < 1) {
      return const Left(ValidationFailure('Invalid message page.'));
    }
    try {
      final response = await apiConsumer.get(
        '${EndPoint.conversations}/${Uri.encodeComponent(conversationId.trim())}/messages',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = _responseData(response, 'Messages');
      final chatPage = _pageFromData(
        data,
        label: 'Messages',
        parseItem: ChatMessage.fromJson,
      );
      final orderedMessages = [...chatPage.items]
        ..sort((first, second) => first.createdAt.compareTo(second.createdAt));
      return Right(
        ChatPage(
          items: List.unmodifiable(orderedMessages),
          page: chatPage.page,
          hasNextPage: chatPage.hasNextPage,
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The messages response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The messages response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    if (conversationId.trim().isEmpty || text.trim().isEmpty) {
      return const Left(ValidationFailure('A message cannot be empty.'));
    }
    try {
      final response = await apiConsumer.post(
        '${EndPoint.conversations}/${Uri.encodeComponent(conversationId.trim())}/messages',
        data: {'text': text.trim()},
      );
      return Right(ChatMessage.fromJson(_responseData(response, 'Message')));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The sent message response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The sent message response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> markConversationRead(
    String conversationId,
  ) async {
    if (conversationId.trim().isEmpty) {
      return const Left(ValidationFailure('Invalid conversation ID.'));
    }

    try {
      final response = await apiConsumer.patch(
        EndPoint.conversationRead(conversationId.trim()),
      );
      final data = _responseData(response, 'Mark messages as read');
      if (data['success'] != true) {
        throw const FormatException(
          'Mark messages as read response was unsuccessful.',
        );
      }
      final markedCount = _integer(data['markedCount']);
      if (markedCount == null || markedCount < 0) {
        throw const FormatException('Marked message count is invalid.');
      }
      return Right(markedCount);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The read messages response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The read messages response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    if (conversationId.trim().isEmpty || messageId.trim().isEmpty) {
      return const Left(ValidationFailure('Invalid message selection.'));
    }

    try {
      final response = await apiConsumer.delete(
        EndPoint.conversationMessage(
          conversationId: conversationId.trim(),
          messageId: messageId.trim(),
        ),
      );
      final data = _responseData(response, 'Delete message');
      if (data['success'] != true ||
          data['deletedMessageId'] != messageId.trim()) {
        throw const FormatException('The message was not deleted.');
      }
      return const Right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The delete message response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The delete message response was invalid.'),
      );
    }
  }

  Map<String, dynamic> _responseData(Object? response, String label) {
    if (response is! Map) {
      throw FormatException('$label response is not an object.');
    }
    final json = Map<String, dynamic>.from(response);
    if (json['success'] == false) {
      throw FormatException('$label request was unsuccessful.');
    }
    final rawData = json['data'];
    if (rawData is! Map) {
      throw FormatException('$label response data is missing.');
    }
    return Map<String, dynamic>.from(rawData);
  }

  ChatPage<T> _pageFromData<T>(
    Map<String, dynamic> data, {
    required String label,
    required T Function(Map<String, dynamic>) parseItem,
  }) {
    final rawItems = data['items'];
    final rawPagination = data['pagination'];
    if (rawItems is! List || rawPagination is! Map) {
      throw FormatException('$label page is missing its items or pagination.');
    }
    final pagination = Map<String, dynamic>.from(rawPagination);
    final page = _integer(pagination['page']);
    final hasNextPage = pagination['hasNextPage'];
    if (page == null || page < 1 || hasNextPage is! bool) {
      throw FormatException('$label pagination is invalid.');
    }
    final items = rawItems
        .map((item) {
          if (item is! Map) {
            throw FormatException('$label contains an invalid entry.');
          }
          final parsed = parseItem(Map<String, dynamic>.from(item));
          if (parsed is ChatConversation && parsed.id.isEmpty) {
            throw FormatException(
              '$label contains a conversation without an ID.',
            );
          }
          if (parsed is ChatMessage &&
              (parsed.id.isEmpty || parsed.conversationId.isEmpty)) {
            throw FormatException('$label contains a message without an ID.');
          }
          return parsed;
        })
        .toList(growable: false);
    return ChatPage(
      items: List.unmodifiable(items),
      page: page,
      hasNextPage: hasNextPage,
    );
  }

  int? _integer(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
