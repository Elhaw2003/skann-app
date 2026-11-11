import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';

enum ChatLauncherStatus { initial, loading, success, failure }

class ChatLauncherState {
  const ChatLauncherState({
    this.status = ChatLauncherStatus.initial,
    this.targetUserId,
    this.conversation,
    this.errorMessage,
  });

  final ChatLauncherStatus status;
  final String? targetUserId;
  final ChatConversation? conversation;
  final String? errorMessage;
}

class ChatLauncherCubit extends Cubit<ChatLauncherState> {
  ChatLauncherCubit({required this.repository})
    : super(const ChatLauncherState());

  final ChatRepository repository;

  Future<void> startConversation({
    required String targetUserId,
    required String propertyId,
  }) async {
    if (isClosed || state.status == ChatLauncherStatus.loading) return;
    emit(
      ChatLauncherState(
        status: ChatLauncherStatus.loading,
        targetUserId: targetUserId,
      ),
    );
    final result = await repository.startConversation(
      targetUserId: targetUserId,
      propertyId: propertyId,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        ChatLauncherState(
          status: ChatLauncherStatus.failure,
          errorMessage: _messageFor(failure),
        ),
      ),
      (conversation) => emit(
        ChatLauncherState(
          status: ChatLauncherStatus.success,
          conversation: conversation,
        ),
      ),
    );
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. حاول بدء المحادثة مرة أخرى.';
    }
    return 'لم نتمكن من بدء المحادثة. حاول مرة أخرى.';
  }
}
