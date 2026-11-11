import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';

class ChatUnreadState {
  const ChatUnreadState({this.count = 0, this.errorMessage});

  final int count;
  final String? errorMessage;

  ChatUnreadState copyWith({int? count, String? errorMessage}) =>
      ChatUnreadState(count: count ?? this.count, errorMessage: errorMessage);
}

class ChatUnreadCubit extends Cubit<ChatUnreadState>
    with WidgetsBindingObserver {
  ChatUnreadCubit({required this.repository, required this.secureStorageHelper})
    : super(const ChatUnreadState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const pollingInterval = Duration(seconds: 15);

  final ChatRepository repository;
  final SecureStorageHelper secureStorageHelper;
  Timer? _pollingTimer;
  bool _isRefreshing = false;
  bool _isForeground = true;

  void startPolling() {
    if (isClosed || _pollingTimer != null) return;
    unawaited(refresh());
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      if (_isForeground) unawaited(refresh());
    });
  }

  Future<void> refresh() async {
    if (isClosed || _isRefreshing) return;
    _isRefreshing = true;
    try {
      final token = await secureStorageHelper.getAccessToken();
      if (isClosed) return;
      if (token == null || token.isEmpty) {
        emit(const ChatUnreadState());
        return;
      }

      final result = await repository.getUnreadTotal();
      if (isClosed) return;
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (count) => emit(ChatUnreadState(count: count)),
      );
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) unawaited(refresh());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
