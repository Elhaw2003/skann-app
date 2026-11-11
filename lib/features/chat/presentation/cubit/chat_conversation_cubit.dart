import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_conversation_state.dart';

class ChatConversationCubit extends Cubit<ChatConversationState>
    with WidgetsBindingObserver {
  ChatConversationCubit({
    required this.repository,
    required this.secureStorageHelper,
  }) : super(const ChatConversationState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const pageSize = 30;
  static const pollingInterval = Duration(seconds: 15);

  final ChatRepository repository;
  final SecureStorageHelper secureStorageHelper;
  Timer? _pollingTimer;
  String? _conversationId;
  String? currentUserId;
  bool _isForeground = true;
  bool _isMessagesRequestInFlight = false;
  bool _isMarkReadRequestInFlight = false;
  int _localMessageSequence = 0;

  Future<void> open(String conversationId) async {
    if (isClosed || conversationId.trim().isEmpty) return;
    if (_conversationId == conversationId &&
        state.status != ChatConversationStatus.initial) {
      return;
    }

    _pollingTimer?.cancel();
    _conversationId = conversationId;
    _isMessagesRequestInFlight = false;
    currentUserId = await secureStorageHelper.getUserId();
    if (isClosed) return;
    emit(const ChatConversationState(status: ChatConversationStatus.loading));

    final conversationResult = await repository.getConversation(conversationId);
    if (isClosed || _conversationId != conversationId) return;
    final conversation = conversationResult.fold((failure) {
      emit(
        ChatConversationState(
          status: ChatConversationStatus.failure,
          errorMessage: _messageFor(failure),
        ),
      );
      return null;
    }, (value) => value);
    if (conversation == null) return;

    final messagesResult = await repository.getMessages(
      conversationId: conversationId,
      page: 1,
      limit: pageSize,
    );
    if (isClosed || _conversationId != conversationId) return;
    messagesResult.fold(
      (failure) => emit(
        ChatConversationState(
          status: ChatConversationStatus.loaded,
          conversation: conversation,
          messageError: _messageFor(failure),
        ),
      ),
      (page) => emit(
        ChatConversationState(
          status: ChatConversationStatus.loaded,
          conversation: conversation,
          messages: page.items,
          page: page.page,
          hasOlderMessages: page.hasNextPage,
        ),
      ),
    );
    _startPolling();
    if (messagesResult.isRight()) {
      unawaited(markIncomingMessagesRead());
    }
  }

  Future<void> retryLoading() async {
    final conversationId = _conversationId;
    if (conversationId != null) {
      _conversationId = null;
      await open(conversationId);
    }
  }

  Future<void> loadOlderMessages() async {
    final conversationId = _conversationId;
    if (isClosed ||
        conversationId == null ||
        !state.hasOlderMessages ||
        state.isLoadingOlder ||
        _isMessagesRequestInFlight) {
      return;
    }

    _isMessagesRequestInFlight = true;
    emit(state.copyWith(isLoadingOlder: true, clearMessageError: true));
    final requestedConversationId = conversationId;
    final result = await repository.getMessages(
      conversationId: conversationId,
      page: state.page + 1,
      limit: pageSize,
    );
    if (isClosed || _conversationId != requestedConversationId) return;
    _isMessagesRequestInFlight = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingOlder: false,
          messageError: _messageFor(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          messages: _mergeMessages(state.messages, page.items),
          page: page.page,
          hasOlderMessages: page.hasNextPage,
          isLoadingOlder: false,
          clearMessageError: true,
        ),
      ),
    );
    if (result.isRight()) {
      unawaited(markIncomingMessagesRead());
    }
  }

  Future<void> markIncomingMessagesRead() async {
    final conversationId = _conversationId;
    if (isClosed ||
        conversationId == null ||
        state.status != ChatConversationStatus.loaded ||
        _isMarkReadRequestInFlight ||
        !state.messages.any(
          (message) =>
              !message.isRead &&
              message.senderId != currentUserId &&
              message.delivery == ChatMessageDelivery.sent,
        )) {
      return;
    }

    _isMarkReadRequestInFlight = true;
    emit(state.copyWith(isMarkingRead: true, clearMarkReadError: true));
    final result = await repository.markConversationRead(conversationId);
    if (isClosed || _conversationId != conversationId) return;
    _isMarkReadRequestInFlight = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isMarkingRead: false,
          markReadError: _messageForReadFailure(failure),
        ),
      ),
      (_) {
        final readAt = DateTime.now();
        emit(
          state.copyWith(
            isMarkingRead: false,
            messages: _sortMessages(
              state.messages.map((message) {
                if (message.senderId == currentUserId || message.isRead) {
                  return message;
                }
                return message.copyWith(isRead: true, readAt: readAt);
              }),
            ),
            clearMarkReadError: true,
          ),
        );
      },
    );
  }

  Future<void> refreshLatestMessages() async {
    final conversationId = _conversationId;
    if (isClosed ||
        conversationId == null ||
        state.status != ChatConversationStatus.loaded ||
        _isMessagesRequestInFlight) {
      return;
    }

    _isMessagesRequestInFlight = true;
    final requestedConversationId = conversationId;
    final result = await repository.getMessages(
      conversationId: conversationId,
      page: 1,
      limit: pageSize,
    );
    if (isClosed || _conversationId != requestedConversationId) return;
    _isMessagesRequestInFlight = false;
    result.fold(
      (failure) => emit(state.copyWith(messageError: _messageFor(failure))),
      (page) => emit(
        state.copyWith(
          messages: _mergeMessages(state.messages, page.items),
          hasOlderMessages: page.hasNextPage || state.page > 1,
          clearMessageError: true,
        ),
      ),
    );
    if (result.isRight()) {
      unawaited(markIncomingMessagesRead());
    }
  }

  Future<void> sendMessage(String text) async {
    final conversationId = _conversationId;
    final messageText = text.trim();
    if (isClosed ||
        conversationId == null ||
        messageText.isEmpty ||
        state.status != ChatConversationStatus.loaded) {
      return;
    }
    final localId =
        'local-${DateTime.now().microsecondsSinceEpoch}-${_localMessageSequence++}';
    final optimisticMessage = ChatMessage(
      id: localId,
      conversationId: conversationId,
      senderId: currentUserId ?? '',
      text: messageText,
      createdAt: DateTime.now(),
      delivery: ChatMessageDelivery.sending,
    );
    emit(
      state.copyWith(
        messages: _mergeMessages(state.messages, [optimisticMessage]),
        clearMessageError: true,
      ),
    );
    await _sendMessage(localId, messageText, conversationId);
  }

  Future<void> retryMessage(String localId) async {
    final message = state.messages
        .where((item) => item.id == localId)
        .firstOrNull;
    final conversationId = _conversationId;
    if (message == null ||
        conversationId == null ||
        message.delivery != ChatMessageDelivery.failed) {
      return;
    }
    _updateMessage(
      localId,
      message.copyWith(delivery: ChatMessageDelivery.sending),
    );
    await _sendMessage(localId, message.text, conversationId);
  }

  Future<void> _sendMessage(
    String localId,
    String text,
    String conversationId,
  ) async {
    final result = await repository.sendMessage(
      conversationId: conversationId,
      text: text,
    );
    if (isClosed || _conversationId != conversationId) return;
    result.fold(
      (_) {
        final message = state.messages
            .where((item) => item.id == localId)
            .firstOrNull;
        if (message != null) {
          _updateMessage(
            localId,
            message.copyWith(delivery: ChatMessageDelivery.failed),
          );
        }
      },
      (sentMessage) {
        emit(
          state.copyWith(
            messages: _mergeMessages(
              state.messages.where((item) => item.id != localId),
              [sentMessage],
            ),
          ),
        );
      },
    );
  }

  Future<void> retryMessageLoading() async {
    if (_isMessagesRequestInFlight) return;
    await refreshLatestMessages();
  }

  Future<void> deleteMessage(String messageId) async {
    final conversationId = _conversationId;
    final message = state.messages
        .where((item) => item.id == messageId)
        .firstOrNull;
    if (isClosed ||
        conversationId == null ||
        message == null ||
        message.senderId != currentUserId ||
        state.deletingMessageIds.contains(messageId)) {
      return;
    }

    final deletingIds = {...state.deletingMessageIds, messageId};
    final deleteErrors = {...state.deleteErrors}..remove(messageId);
    emit(
      state.copyWith(
        deletingMessageIds: Set.unmodifiable(deletingIds),
        deleteErrors: Map.unmodifiable(deleteErrors),
      ),
    );
    final result = await repository.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
    if (isClosed || _conversationId != conversationId) return;

    final remainingDeletingIds = {...state.deletingMessageIds}
      ..remove(messageId);
    result.fold(
      (failure) {
        final errors = {...state.deleteErrors}
          ..[messageId] = _messageForDeleteFailure(failure);
        emit(
          state.copyWith(
            deletingMessageIds: Set.unmodifiable(remainingDeletingIds),
            deleteErrors: Map.unmodifiable(errors),
          ),
        );
      },
      (_) {
        final errors = {...state.deleteErrors}..remove(messageId);
        emit(
          state.copyWith(
            messages: List.unmodifiable(
              state.messages.where((item) => item.id != messageId),
            ),
            deletingMessageIds: Set.unmodifiable(remainingDeletingIds),
            deleteErrors: Map.unmodifiable(errors),
          ),
        );
      },
    );
  }

  void _updateMessage(String id, ChatMessage updated) {
    emit(
      state.copyWith(
        messages: _sortMessages([
          for (final message in state.messages)
            if (message.id == id) updated else message,
        ]),
      ),
    );
  }

  List<ChatMessage> _mergeMessages(
    Iterable<ChatMessage> existing,
    Iterable<ChatMessage> updates,
  ) {
    final messages = {for (final message in existing) message.id: message};
    for (final message in updates) {
      messages[message.id] = message;
    }
    return _sortMessages(messages.values);
  }

  List<ChatMessage> _sortMessages(Iterable<ChatMessage> messages) {
    final sorted = messages.toList()
      ..sort((first, second) {
        final byTime = first.createdAt.compareTo(second.createdAt);
        return byTime != 0 ? byTime : first.id.compareTo(second.id);
      });
    return List.unmodifiable(sorted);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      if (_isForeground) unawaited(refreshLatestMessages());
    });
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    return 'لم نتمكن من تحميل المحادثة حاليًا. حاول مرة أخرى.';
  }

  String _messageForReadFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر تحديث حالة القراءة. تحقق من اتصالك وحاول مرة أخرى.';
    }
    return 'لم نتمكن من تحديد الرسائل كمقروءة. حاول مرة أخرى.';
  }

  String _messageForDeleteFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر حذف الرسالة بسبب الاتصال. حاول مرة أخرى.';
    }
    return 'لم نتمكن من حذف الرسالة. حاول مرة أخرى.';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) unawaited(refreshLatestMessages());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
