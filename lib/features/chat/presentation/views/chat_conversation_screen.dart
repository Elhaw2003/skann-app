import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_conversation_cubit.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_conversation_state.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:skann_app/features/chat/presentation/views/widgets/chat_conversation_widgets.dart';

class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatConversationCubit>()..open(conversationId),
      child: const _ChatConversationView(),
    );
  }
}

class _ChatConversationView extends StatefulWidget {
  const _ChatConversationView();

  @override
  State<_ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<_ChatConversationView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _composerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadOlderWhenNeeded);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadOlderWhenNeeded)
      ..dispose();
    _messageController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  void _loadOlderWhenNeeded() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter < 160 && position.maxScrollExtent > 0) {
      context.read<ChatConversationCubit>().loadOlderMessages();
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatConversationCubit>().sendMessage(text);
    _messageController.clear();
    _composerFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatConversationCubit, ChatConversationState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length ||
          previous.status != current.status ||
          (previous.isMarkingRead && !current.isMarkingRead),
      listener: (context, state) {
        if (state.status == ChatConversationStatus.loaded) {
          context.read<ChatUnreadCubit>().refresh();
        }
        if (state.messages.isNotEmpty &&
            _scrollController.hasClients &&
            _scrollController.position.pixels < 90) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F6FA),
          body: SafeArea(
            child: BlocBuilder<ChatConversationCubit, ChatConversationState>(
              builder: (context, state) {
                if (state.status == ChatConversationStatus.loading ||
                    state.status == ChatConversationStatus.initial) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B67C8)),
                  );
                }
                if (state.status == ChatConversationStatus.failure) {
                  return ChatConversationError(
                    message: state.errorMessage ?? 'تعذر تحميل المحادثة.',
                    onRetry: context.read<ChatConversationCubit>().retryLoading,
                  );
                }

                final cubit = context.read<ChatConversationCubit>();
                final conversation = state.conversation;
                final person = conversation?.otherParticipant(
                  cubit.currentUserId,
                );
                return Column(
                  children: [
                    ChatConversationHeader(
                      name: person?.displayName.trim().isNotEmpty == true
                          ? person!.displayName
                          : 'محادثة سكن',
                      imageUrl: person?.profileImage,
                      isOwner: person?.role?.toUpperCase() == 'OWNER',
                      onBack: () => context.pop(),
                    ),
                    if (conversation?.property != null)
                      ChatPropertyContextCard(
                        property: conversation!.property!,
                      ),
                    ChatReadStatusBanner(
                      isLoading: state.isMarkingRead,
                      errorMessage: state.markReadError,
                      onRetry: cubit.markIncomingMessagesRead,
                    ),
                    Expanded(
                      child: _MessagesList(
                        state: state,
                        cubit: cubit,
                        scrollController: _scrollController,
                      ),
                    ),
                    if (state.messageError != null)
                      ChatInlineMessageError(
                        message: state.messageError!,
                        onRetry: cubit.retryMessageLoading,
                      ),
                    ChatMessageComposer(
                      controller: _messageController,
                      focusNode: _composerFocusNode,
                      onSend: _sendMessage,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.state,
    required this.cubit,
    required this.scrollController,
  });

  final ChatConversationState state;
  final ChatConversationCubit cubit;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (state.messages.isEmpty && state.messageError != null) {
      return ChatConversationError(
        message: state.messageError!,
        onRetry: cubit.retryMessageLoading,
      );
    }
    if (state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(26.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE7F1FB),
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: const Color(0xFF0B67C8),
                  size: 34.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'أول رسالة بتبدأ حكاية',
                style: TextStyle(
                  color: const Color(0xFF203853),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'اسأل عن السكن أو عرّف نفسك بلطف.',
                style: TextStyle(
                  color: const Color(0xFF8393A5),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(15.w, 16.h, 15.w, 10.h),
      itemCount: state.messages.length + (state.isLoadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.isLoadingOlder && index == state.messages.length) {
          return Padding(
            padding: EdgeInsets.all(10.w),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0B67C8),
                ),
              ),
            ),
          );
        }
        final message = state.messages[state.messages.length - 1 - index];
        final isMine =
            cubit.currentUserId != null &&
            message.senderId == cubit.currentUserId;
        return ChatMessageBubble(
          key: ValueKey(message.id),
          message: message,
          isMine: isMine,
          onRetry: message.delivery == ChatMessageDelivery.failed
              ? () => cubit.retryMessage(message.id)
              : null,
          onDelete:
              isMine &&
                  message.delivery == ChatMessageDelivery.sent &&
                  !message.id.startsWith('local-')
              ? () => cubit.deleteMessage(message.id)
              : null,
          onRetryDelete: () => cubit.deleteMessage(message.id),
          isDeleting: state.deletingMessageIds.contains(message.id),
          deleteError: state.deleteErrors[message.id],
        );
      },
    );
  }
}
