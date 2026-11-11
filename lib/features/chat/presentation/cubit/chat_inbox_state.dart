import 'package:equatable/equatable.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';

enum ChatInboxStatus { initial, loading, loaded, failure }

class ChatInboxState extends Equatable {
  const ChatInboxState({
    this.status = ChatInboxStatus.initial,
    this.conversations = const [],
    this.page = 1,
    this.hasNextPage = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final ChatInboxStatus status;
  final List<ChatConversation> conversations;
  final int page;
  final bool hasNextPage;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;

  ChatInboxState copyWith({
    ChatInboxStatus? status,
    List<ChatConversation>? conversations,
    int? page,
    bool? hasNextPage,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) => ChatInboxState(
    status: status ?? this.status,
    conversations: conversations ?? this.conversations,
    page: page ?? this.page,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    loadMoreError: clearLoadMoreError
        ? null
        : loadMoreError ?? this.loadMoreError,
  );

  @override
  List<Object?> get props => [
    status,
    conversations,
    page,
    hasNextPage,
    isRefreshing,
    isLoadingMore,
    errorMessage,
    loadMoreError,
  ];
}
