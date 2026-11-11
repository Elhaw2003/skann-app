import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_inbox_state.dart';

class ChatInboxCubit extends Cubit<ChatInboxState> with WidgetsBindingObserver {
  ChatInboxCubit({required this.repository, required this.secureStorageHelper})
    : super(const ChatInboxState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const pageSize = 20;
  static const pollingInterval = Duration(seconds: 15);

  final ChatRepository repository;
  final SecureStorageHelper secureStorageHelper;
  Timer? _pollingTimer;
  bool _isForeground = true;
  bool _isRequestInFlight = false;
  String? currentUserId;

  void start() {
    if (isClosed || _pollingTimer != null) return;
    unawaited(_start());
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      if (_isForeground) unawaited(refreshLatest());
    });
  }

  Future<void> _start() async {
    currentUserId = await secureStorageHelper.getUserId();
    if (!isClosed) await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    if (isClosed || _isRequestInFlight) return;
    _isRequestInFlight = true;
    emit(
      state.copyWith(
        status: state.conversations.isEmpty
            ? ChatInboxStatus.loading
            : ChatInboxStatus.loaded,
        isRefreshing: state.conversations.isNotEmpty,
        clearErrorMessage: true,
        clearLoadMoreError: true,
      ),
    );
    final result = await repository.getConversations(page: 1, limit: pageSize);
    if (isClosed) return;
    _isRequestInFlight = false;
    result.fold(
      (failure) => _emitLoadFailure(failure),
      (page) => emit(
        state.copyWith(
          status: ChatInboxStatus.loaded,
          conversations: _sortConversations(page.items),
          page: page.page,
          hasNextPage: page.hasNextPage,
          isRefreshing: false,
          clearErrorMessage: true,
          clearLoadMoreError: true,
        ),
      ),
    );
  }

  Future<void> refreshLatest() async {
    if (isClosed || _isRequestInFlight) return;
    _isRequestInFlight = true;
    final result = await repository.getConversations(page: 1, limit: pageSize);
    if (isClosed) return;
    _isRequestInFlight = false;
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: _messageFor(failure), isRefreshing: false),
      ),
      (page) {
        final latest = {for (final item in page.items) item.id: item};
        for (final item in state.conversations) {
          latest.putIfAbsent(item.id, () => item);
        }
        emit(
          state.copyWith(
            status: ChatInboxStatus.loaded,
            conversations: _sortConversations(latest.values),
            page: page.page,
            hasNextPage: page.hasNextPage || state.page > 1,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> loadNextPage() async {
    if (isClosed ||
        _isRequestInFlight ||
        !state.hasNextPage ||
        state.isLoadingMore) {
      return;
    }
    _isRequestInFlight = true;
    emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await repository.getConversations(
      page: state.page + 1,
      limit: pageSize,
    );
    if (isClosed) return;
    _isRequestInFlight = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          loadMoreError: _messageFor(failure),
        ),
      ),
      (page) {
        final conversations = {
          for (final item in state.conversations) item.id: item,
        }..addEntries(page.items.map((item) => MapEntry(item.id, item)));
        emit(
          state.copyWith(
            conversations: _sortConversations(conversations.values),
            page: page.page,
            hasNextPage: page.hasNextPage,
            isLoadingMore: false,
            clearLoadMoreError: true,
          ),
        );
      },
    );
  }

  void _emitLoadFailure(Failure failure) {
    final message = _messageFor(failure);
    emit(
      state.copyWith(
        status: state.conversations.isEmpty
            ? ChatInboxStatus.failure
            : ChatInboxStatus.loaded,
        errorMessage: message,
        isRefreshing: false,
      ),
    );
  }

  List<ChatConversation> _sortConversations(
    Iterable<ChatConversation> conversations,
  ) {
    final sorted = conversations.toList()
      ..sort((first, second) {
        final firstDate = first.lastMessageAt;
        final secondDate = second.lastMessageAt;
        if (firstDate == null) return secondDate == null ? 0 : 1;
        if (secondDate == null) return -1;
        return secondDate.compareTo(firstDate);
      });
    return List.unmodifiable(sorted);
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    return 'لم نتمكن من تحميل المحادثات حاليًا. حاول مرة أخرى.';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) unawaited(refreshLatest());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
