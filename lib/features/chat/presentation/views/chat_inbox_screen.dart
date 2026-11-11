import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_inbox_cubit.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_inbox_state.dart';
import 'package:skann_app/features/chat/presentation/views/widgets/chat_inbox_widgets.dart';
import 'package:skann_app/features/home/presentation/views/widgets/student_bottom_navigation_bar.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatInboxCubit>()..start(),
      child: const _ChatInboxView(),
    );
  }
}

class _ChatInboxView extends StatefulWidget {
  const _ChatInboxView();

  @override
  State<_ChatInboxView> createState() => _ChatInboxViewState();
}

class _ChatInboxViewState extends State<_ChatInboxView> {
  final _searchController = TextEditingController();
  bool _onlyUnread = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        bottomNavigationBar: StudentBottomNavigationBar(
          selectedIndex: 4,
          onDestinationSelected: (index) {
            if (index == 0) context.go(AppRoutes.studentHome);
            if (index == 1) context.go(AppRoutes.favorites);
            if (index == 2) context.go(AppRoutes.profile);
            if (index == 3) context.go(AppRoutes.myBookings);
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChatInboxHeader(
                searchController: _searchController,
                onlyUnread: _onlyUnread,
                onSearchChanged: (_) => setState(() {}),
                onClearSearch: () => setState(_searchController.clear),
                onUnreadChanged: (value) => setState(() {
                  _onlyUnread = value;
                }),
              ),
              Expanded(
                child: BlocBuilder<ChatInboxCubit, ChatInboxState>(
                  builder: (context, state) {
                    if (state.status == ChatInboxStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0B67C8),
                        ),
                      );
                    }
                    if (state.status == ChatInboxStatus.failure) {
                      return ChatInboxError(
                        message: state.errorMessage ?? 'تعذر تحميل المحادثات.',
                        onRetry: context.read<ChatInboxCubit>().loadFirstPage,
                      );
                    }

                    final cubit = context.read<ChatInboxCubit>();
                    final query = _searchController.text.trim().toLowerCase();
                    final conversations = state.conversations
                        .where((item) {
                          if (_onlyUnread && item.unreadCount == 0) {
                            return false;
                          }
                          final person = item.otherParticipant(
                            cubit.currentUserId,
                          );
                          final searchableText = [
                            person?.displayName,
                            item.property?.title,
                            item.lastMessageText,
                          ].whereType<String>().join(' ').toLowerCase();
                          return query.isEmpty ||
                              searchableText.contains(query);
                        })
                        .toList(growable: false);

                    if (conversations.isEmpty && state.errorMessage != null) {
                      return ChatInboxError(
                        message: state.errorMessage!,
                        onRetry: cubit.refreshLatest,
                      );
                    }
                    if (conversations.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: cubit.refreshLatest,
                        color: const Color(0xFF0B67C8),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: ChatInboxEmpty(
                                isSearching: query.isNotEmpty || _onlyUnread,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (state.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 9.h, 16.w, 0),
                            child: ChatInboxSyncError(
                              onRetry: cubit.refreshLatest,
                            ),
                          ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: cubit.refreshLatest,
                            color: const Color(0xFF0B67C8),
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification.metrics.extentAfter < 260 &&
                                    !state.isLoadingMore &&
                                    state.hasNextPage) {
                                  cubit.loadNextPage();
                                }
                                return false;
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  12.h,
                                  16.w,
                                  24.h,
                                ),
                                itemCount:
                                    conversations.length +
                                    (state.isLoadingMore ||
                                            state.loadMoreError != null
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index == conversations.length) {
                                    if (state.isLoadingMore) {
                                      return Padding(
                                        padding: EdgeInsets.all(18.w),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF0B67C8),
                                          ),
                                        ),
                                      );
                                    }
                                    return TextButton(
                                      onPressed: cubit.loadNextPage,
                                      child: const Text(
                                        'تعذر تحميل المزيد — حاول مرة أخرى',
                                      ),
                                    );
                                  }
                                  final conversation = conversations[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 11.h),
                                    child: ChatConversationTile(
                                      conversation: conversation,
                                      currentUserId: cubit.currentUserId,
                                      onTap: () => context.push(
                                        AppRoutes.conversation.replaceFirst(
                                          ':conversationId',
                                          Uri.encodeComponent(conversation.id),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
