import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_conversation_cubit.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_people_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'conversation chooses the participant other than the signed-in user',
    () {
      final conversation = ChatConversation.fromJson({
        'id': 'conversation-id',
        'participantIds': ['current-user', 'other-user'],
        'participants': [
          {'id': 'current-user', 'fullName': 'Current'},
          {'id': 'other-user', 'fullName': 'Other'},
        ],
        'recipient': {'id': 'current-user', 'fullName': 'Current'},
      });

      expect(conversation.otherParticipant('current-user')?.id, 'other-user');
      expect(
        conversation.otherParticipant('current-user')?.displayName,
        'Other',
      );
    },
  );

  test(
    'message pages are ordered chronologically regardless of API ordering',
    () async {
      final apiConsumer = _FakeApiConsumer(
        getResponse: {
          'success': true,
          'data': {
            'items': [
              _message('newer', '2026-11-11T13:53:28.109Z'),
              _message('older', '2026-11-11T13:42:28.109Z'),
            ],
            'pagination': {
              'page': 1,
              'limit': 30,
              'hasNextPage': true,
              'hasPreviousPage': false,
            },
          },
        },
      );
      final repository = ChatRepositoryImpl(apiConsumer: apiConsumer);

      final result = await repository.getMessages(
        conversationId: 'conversation-id',
        page: 1,
        limit: 30,
      );

      final page = result.fold(
        (failure) => fail(failure.message),
        (value) => value,
      );
      expect(apiConsumer.getPath, 'conversations/conversation-id/messages');
      expect(apiConsumer.queryParameters, {'page': 1, 'limit': 30});
      expect(page.hasNextPage, isTrue);
      expect(page.items.map((message) => message.id), ['older', 'newer']);
    },
  );

  test('starting a conversation posts both contact and property IDs', () async {
    final apiConsumer = _FakeApiConsumer(
      postResponse: {
        'success': true,
        'data': {'id': 'conversation-id'},
      },
    );
    final repository = ChatRepositoryImpl(apiConsumer: apiConsumer);

    final result = await repository.startConversation(
      targetUserId: 'target-user',
      propertyId: 'property-id',
    );

    expect(result.isRight(), isTrue);
    expect(apiConsumer.postPath, 'conversations');
    expect(apiConsumer.requestBody, {
      'targetUserId': 'target-user',
      'propertyId': 'property-id',
    });
  });

  test('marks messages read and validates the endpoint response', () async {
    final apiConsumer = _FakeApiConsumer(
      patchResponse: {
        'success': true,
        'data': {'success': true, 'markedCount': 1},
      },
    );
    final repository = ChatRepositoryImpl(apiConsumer: apiConsumer);

    final result = await repository.markConversationRead('conversation-id');

    expect(apiConsumer.patchPath, 'conversations/conversation-id/read');
    expect(result, const Right<Failure, int>(1));
  });

  test('deletes a message and validates the deleted message ID', () async {
    final apiConsumer = _FakeApiConsumer(
      deleteResponse: {
        'success': true,
        'data': {'success': true, 'deletedMessageId': 'message-id'},
      },
    );
    final repository = ChatRepositoryImpl(apiConsumer: apiConsumer);

    final result = await repository.deleteMessage(
      conversationId: 'conversation-id',
      messageId: 'message-id',
    );

    expect(
      apiConsumer.deletePath,
      'conversations/conversation-id/messages/message-id',
    );
    expect(result.isRight(), isTrue);
  });

  test('message send is optimistic, retryable, and deduplicated', () async {
    final repository = _FakeChatRepository();
    final cubit = ChatConversationCubit(
      repository: repository,
      secureStorageHelper: _FakeSecureStorageHelper(),
    );
    await cubit.open('conversation-id');

    final sendResponse = Completer<Either<Failure, ChatMessage>>();
    repository.sendResponse = () => sendResponse.future;
    final send = cubit.sendMessage('  مرحبًا  ');
    final optimistic = cubit.state.messages.single;

    expect(optimistic.text, 'مرحبًا');
    expect(optimistic.senderId, 'current-user');
    expect(optimistic.delivery, ChatMessageDelivery.sending);

    sendResponse.complete(const Left(NetworkFailure('offline')));
    await send;
    expect(cubit.state.messages.single.delivery, ChatMessageDelivery.failed);

    final serverMessage = ChatMessage(
      id: 'server-message',
      conversationId: 'conversation-id',
      senderId: 'current-user',
      text: 'مرحبًا',
      createdAt: DateTime.utc(2026, 11, 11),
    );
    repository.sendResponse = () async => Right(serverMessage);
    await cubit.retryMessage(optimistic.id);

    expect(cubit.state.messages, [serverMessage]);
    await cubit.close();
  });

  test(
    'marks incoming messages read and exposes retryable read errors',
    () async {
      final repository = _FakeChatRepository()
        ..initialMessages = [
          _chatMessage(id: 'incoming', senderId: 'other-user', isRead: false),
        ];
      final readResponse = Completer<Either<Failure, int>>();
      repository.markReadResponse = () => readResponse.future;
      final cubit = ChatConversationCubit(
        repository: repository,
        secureStorageHelper: _FakeSecureStorageHelper(),
      );

      await cubit.open('conversation-id');
      expect(cubit.state.isMarkingRead, isTrue);
      readResponse.complete(const Left(NetworkFailure('offline')));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.markReadError, isNotNull);
      expect(cubit.state.messages.single.isRead, isFalse);

      repository.markReadResponse = () async => const Right(1);
      await cubit.markIncomingMessagesRead();

      expect(cubit.state.markReadError, isNull);
      expect(cubit.state.messages.single.isRead, isTrue);
      expect(repository.markReadCallCount, 2);
      await cubit.close();
    },
  );

  test('delete failure preserves message and success removes it', () async {
    final repository = _FakeChatRepository()
      ..initialMessages = [
        _chatMessage(id: 'own-message', senderId: 'current-user'),
      ];
    final deleteResponse = Completer<Either<Failure, Unit>>();
    repository.deleteResponse = () => deleteResponse.future;
    final cubit = ChatConversationCubit(
      repository: repository,
      secureStorageHelper: _FakeSecureStorageHelper(),
    );
    await cubit.open('conversation-id');

    final delete = cubit.deleteMessage('own-message');
    expect(cubit.state.deletingMessageIds, contains('own-message'));
    deleteResponse.complete(const Left(NetworkFailure('offline')));
    await delete;
    expect(cubit.state.messages, hasLength(1));
    expect(cubit.state.deleteErrors['own-message'], isNotNull);

    repository.deleteResponse = () async => const Right(unit);
    await cubit.deleteMessage('own-message');
    expect(cubit.state.messages, isEmpty);
    expect(cubit.state.deleteErrors, isEmpty);
    await cubit.close();
  });

  testWidgets('only selected property contact shows chat loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: PropertyResidentsSection(
              residents: const [
                PropertyResidentModel(id: 'resident-1', fullName: 'First'),
                PropertyResidentModel(id: 'resident-2', fullName: 'Second'),
              ],
              onStartChat: (_) {},
              startingChatTargetUserId: 'resident-2',
            ),
          ),
        ),
      ),
    );

    expect(find.text('مراسلة'), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

Map<String, dynamic> _message(String id, String createdAt) => {
  'id': id,
  'conversationId': 'conversation-id',
  'senderId': 'user-id',
  'text': id,
  'isRead': false,
  'readAt': null,
  'createdAt': createdAt,
};

ChatMessage _chatMessage({
  required String id,
  required String senderId,
  bool isRead = true,
}) => ChatMessage(
  id: id,
  conversationId: 'conversation-id',
  senderId: senderId,
  text: 'Message $id',
  createdAt: DateTime.utc(2026, 11, 11),
  isRead: isRead,
);

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer({
    this.getResponse,
    this.postResponse,
    this.patchResponse,
    this.deleteResponse,
  });

  final Object? getResponse;
  final Object? postResponse;
  final Object? patchResponse;
  final Object? deleteResponse;
  String? getPath;
  String? postPath;
  String? patchPath;
  String? deletePath;
  Object? requestBody;
  Map<String, dynamic>? queryParameters;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    getPath = path;
    this.queryParameters = queryParameters;
    return getResponse;
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    postPath = path;
    requestBody = data;
    return postResponse;
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    patchPath = path;
    return patchResponse;
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    deletePath = path;
    return deleteResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChatRepository implements ChatRepository {
  Future<Either<Failure, ChatMessage>> Function()? sendResponse;
  Future<Either<Failure, int>> Function()? markReadResponse;
  Future<Either<Failure, Unit>> Function()? deleteResponse;
  List<ChatMessage> initialMessages = const [];
  int markReadCallCount = 0;

  @override
  Future<Either<Failure, ChatConversation>> getConversation(String id) async =>
      const Right(ChatConversation(id: 'conversation-id'));

  @override
  Future<Either<Failure, ChatPage<ChatMessage>>> getMessages({
    required String conversationId,
    required int page,
    required int limit,
  }) async =>
      Right(ChatPage(items: initialMessages, page: page, hasNextPage: false));

  @override
  Future<Either<Failure, int>> markConversationRead(String conversationId) {
    markReadCallCount++;
    return markReadResponse?.call() ?? Future.value(const Right(0));
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({
    required String conversationId,
    required String messageId,
  }) => deleteResponse?.call() ?? Future.value(const Right(unit));

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required String text,
  }) =>
      sendResponse?.call() ??
      Future.value(const Left(UnexpectedFailure('No send response.')));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSecureStorageHelper extends SecureStorageHelper {
  _FakeSecureStorageHelper() : super.internal();

  @override
  Future<String?> getUserId() async => 'current-user';
}
