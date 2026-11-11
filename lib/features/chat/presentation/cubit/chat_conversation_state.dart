import 'package:equatable/equatable.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';

enum ChatConversationStatus { initial, loading, loaded, failure }

class ChatConversationState extends Equatable {
  const ChatConversationState({
    this.status = ChatConversationStatus.initial,
    this.conversation,
    this.messages = const [],
    this.page = 1,
    this.hasOlderMessages = false,
    this.isLoadingOlder = false,
    this.isRefreshing = false,
    this.isMarkingRead = false,
    this.deletingMessageIds = const {},
    this.deleteErrors = const {},
    this.errorMessage,
    this.messageError,
    this.markReadError,
  });

  final ChatConversationStatus status;
  final ChatConversation? conversation;
  final List<ChatMessage> messages;
  final int page;
  final bool hasOlderMessages;
  final bool isLoadingOlder;
  final bool isRefreshing;
  final bool isMarkingRead;
  final Set<String> deletingMessageIds;
  final Map<String, String> deleteErrors;
  final String? errorMessage;
  final String? messageError;
  final String? markReadError;

  ChatConversationState copyWith({
    ChatConversationStatus? status,
    ChatConversation? conversation,
    List<ChatMessage>? messages,
    int? page,
    bool? hasOlderMessages,
    bool? isLoadingOlder,
    bool? isRefreshing,
    bool? isMarkingRead,
    Set<String>? deletingMessageIds,
    Map<String, String>? deleteErrors,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? messageError,
    bool clearMessageError = false,
    String? markReadError,
    bool clearMarkReadError = false,
  }) => ChatConversationState(
    status: status ?? this.status,
    conversation: conversation ?? this.conversation,
    messages: messages ?? this.messages,
    page: page ?? this.page,
    hasOlderMessages: hasOlderMessages ?? this.hasOlderMessages,
    isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isMarkingRead: isMarkingRead ?? this.isMarkingRead,
    deletingMessageIds: deletingMessageIds ?? this.deletingMessageIds,
    deleteErrors: deleteErrors ?? this.deleteErrors,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    messageError: clearMessageError ? null : messageError ?? this.messageError,
    markReadError: clearMarkReadError
        ? null
        : markReadError ?? this.markReadError,
  );

  @override
  List<Object?> get props => [
    status,
    conversation,
    messages,
    page,
    hasOlderMessages,
    isLoadingOlder,
    isRefreshing,
    isMarkingRead,
    deletingMessageIds,
    deleteErrors,
    errorMessage,
    messageError,
    markReadError,
  ];
}
