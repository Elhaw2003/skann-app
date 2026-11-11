import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_unread_cubit.dart';

class ChatInboxHeader extends StatelessWidget {
  const ChatInboxHeader({
    required this.searchController,
    required this.onlyUnread,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onUnreadChanged,
    super.key,
  });

  final TextEditingController searchController;
  final bool onlyUnread;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<bool> onUnreadChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0B67C8), Color(0xFF19427E)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF174E92).withValues(alpha: 0.19),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مساحتك، على تواصل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'كل محادثات السكن في مكان واحد',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<ChatUnreadCubit, ChatUnreadState>(
                builder: (context, state) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mark_chat_unread_rounded,
                        color: const Color(0xFFFFD889),
                        size: 17.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${state.count} جديدة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 19.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن شخص أو سكن...',
                hintStyle: TextStyle(
                  color: const Color(0xFF9AA7B7),
                  fontSize: 12.sp,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8293A6),
                ),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _FilterChip(
                label: 'الكل',
                selected: !onlyUnread,
                onTap: () => onUnreadChanged(false),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                label: 'غير المقروءة',
                selected: onlyUnread,
                onTap: () => onUnreadChanged(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    super.key,
  });

  final ChatConversation conversation;
  final String? currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final person = conversation.otherParticipant(currentUserId);
    final displayName = person?.displayName.trim().isNotEmpty == true
        ? person!.displayName
        : 'محادثة جديدة';
    final hasUnread = conversation.unreadCount > 0;
    final property = conversation.property;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21.r),
        child: Padding(
          padding: EdgeInsets.all(13.w),
          child: Row(
            children: [
              _ConversationAvatar(
                imageUrl: person?.profileImage,
                hasUnread: hasUnread,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF203853),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          _relativeTime(conversation.lastMessageAt),
                          style: TextStyle(
                            color: hasUnread
                                ? const Color(0xFF0868C9)
                                : const Color(0xFF9AA7B7),
                            fontSize: 10.sp,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (property?.title != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 12.sp,
                            color: const Color(0xFF0B67C8),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              property!.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF6D8198),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessageText ??
                                'ابدأوا التعارف وناقشوا تفاصيل السكن',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? const Color(0xFF344A63)
                                  : const Color(0xFF8A99AA),
                              fontSize: 11.sp,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          SizedBox(width: 8.w),
                          Container(
                            constraints: BoxConstraints(
                              minWidth: 21.w,
                              minHeight: 21.w,
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0B67C8),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : '${conversation.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatInboxError extends StatelessWidget {
  const ChatInboxError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: Color(0xFF9AAFC5),
          ),
          SizedBox(height: 12.h),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 14.h),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}

class ChatInboxSyncError extends StatelessWidget {
  const ChatInboxSyncError({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3E9),
      borderRadius: BorderRadius.circular(13.r),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_rounded, size: 16, color: Color(0xFFAD672A)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'تعذر تحديث المحادثات. اعرض البيانات المحفوظة أو حاول مجددًا.',
            style: TextStyle(color: const Color(0xFF875421), fontSize: 9.sp),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('تحديث')),
      ],
    ),
  );
}

class ChatInboxEmpty extends StatelessWidget {
  const ChatInboxEmpty({required this.isSearching, super.key});

  final bool isSearching;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(30.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92.w,
            height: 92.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F1FC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.forum_outlined,
              color: const Color(0xFF2475C7),
              size: 40.sp,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            isSearching ? 'مفيش نتائج مطابقة' : 'لسه مفيش محادثات',
            style: TextStyle(
              color: const Color(0xFF213B5A),
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            isSearching
                ? 'جرّب كلمة تانية أو اعرض كل المحادثات.'
                : 'ابدأ من صفحة السكن وتواصل مع المقيمين أو المالك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8293A6),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13.r),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF15549B) : Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.imageUrl, required this.hasUnread});

  final String? imageUrl;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imageUrl ?? '');
    final validUri =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: hasUnread ? const Color(0xFF67A8EE) : const Color(0xFFE7EDF4),
          width: hasUnread ? 2 : 1,
        ),
      ),
      child: CircleAvatar(
        radius: 25.r,
        backgroundColor: const Color(0xFFEAF1F8),
        backgroundImage: validUri
            ? CachedNetworkImageProvider(uri.toString())
            : null,
        child: validUri
            ? null
            : Icon(
                Icons.person_rounded,
                color: const Color(0xFF7F94AA),
                size: 24.sp,
              ),
      ),
    );
  }
}

String _relativeTime(DateTime? date) {
  if (date == null) return '';
  final difference = DateTime.now().difference(date.toLocal());
  if (difference.isNegative || difference.inMinutes < 1) return 'الآن';
  if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} د';
  if (difference.inHours < 24) return 'منذ ${difference.inHours} س';
  if (difference.inDays < 7) return 'منذ ${difference.inDays} ي';
  return '${date.toLocal().day}/${date.toLocal().month}';
}
