import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/chat/data/models/chat_models.dart';

class ChatConversationHeader extends StatelessWidget {
  const ChatConversationHeader({
    required this.name,
    required this.imageUrl,
    required this.isOwner,
    required this.onBack,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final bool isOwner;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 13.w, 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(23.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163657).withValues(alpha: 0.06),
            blurRadius: 16.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'رجوع',
            icon: const Icon(Icons.arrow_forward_rounded),
            color: const Color(0xFF25405E),
          ),
          ChatPersonAvatar(imageUrl: imageUrl, radius: 21.r),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1E3855),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  isOwner ? 'مالك السكن' : 'تواصل حول السكن',
                  style: TextStyle(
                    color: const Color(0xFF8494A7),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go(AppRoutes.chats),
            tooltip: 'كل المحادثات',
            icon: const Icon(Icons.forum_outlined),
            color: const Color(0xFF0B67C8),
          ),
        ],
      ),
    );
  }
}

class ChatPropertyContextCard extends StatelessWidget {
  const ChatPropertyContextCard({required this.property, super.key});

  final ChatProperty property;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(property.imageUrl ?? '');
    final validUri =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 3.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: const Color(0xFFDCE8F5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: SizedBox(
              width: 48.w,
              height: 48.w,
              child: validUri
                  ? CachedNetworkImage(
                      imageUrl: uri.toString(),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          _propertyPlaceholder(),
                    )
                  : _propertyPlaceholder(),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السكن المرتبط بالمحادثة',
                  style: TextStyle(
                    color: const Color(0xFF73869D),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  property.title ?? 'تفاصيل السكن',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF253F5B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (property.location.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    property.location,
                    style: TextStyle(
                      color: const Color(0xFF7E90A5),
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: const Color(0xFF3B91E7),
            size: 18.sp,
          ),
        ],
      ),
    );
  }

  Widget _propertyPlaceholder() => Container(
    color: const Color(0xFFD7E6F5),
    child: const Icon(Icons.home_work_outlined, color: Color(0xFF6D88A5)),
  );
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMine,
    required this.onRetry,
    required this.onDelete,
    required this.onRetryDelete,
    required this.isDeleting,
    required this.deleteError,
    super.key,
  });

  final ChatMessage message;
  final bool isMine;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;
  final VoidCallback? onRetryDelete;
  final bool isDeleting;
  final String? deleteError;

  @override
  Widget build(BuildContext context) {
    final background = isMine ? const Color(0xFF0B67C8) : Colors.white;
    final foreground = isMine ? Colors.white : const Color(0xFF29435F);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 9.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 0.78.sw),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(19.r),
                          topRight: Radius.circular(19.r),
                          bottomLeft: Radius.circular(isMine ? 5.r : 19.r),
                          bottomRight: Radius.circular(isMine ? 19.r : 5.r),
                        ),
                        boxShadow: [
                          if (!isMine)
                            BoxShadow(
                              color: const Color(
                                0xFF173858,
                              ).withValues(alpha: 0.05),
                              blurRadius: 9.r,
                              offset: Offset(0, 3.h),
                            ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(13.w, 10.h, 13.w, 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: foreground,
                                fontSize: 13.sp,
                                height: 1.45,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _messageTime(message.createdAt),
                                  style: TextStyle(
                                    color: isMine
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : const Color(0xFF9AA7B7),
                                    fontSize: 9.sp,
                                  ),
                                ),
                                if (isMine) ...[
                                  SizedBox(width: 4.w),
                                  if (isDeleting)
                                    SizedBox(
                                      width: 11.w,
                                      height: 11.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    Icon(
                                      message.delivery ==
                                              ChatMessageDelivery.sending
                                          ? Icons.schedule_rounded
                                          : message.isRead
                                          ? Icons.done_all_rounded
                                          : Icons.done_rounded,
                                      color:
                                          message.delivery ==
                                              ChatMessageDelivery.failed
                                          ? const Color(0xFFFFD889)
                                          : Colors.white.withValues(
                                              alpha: 0.82,
                                            ),
                                      size: 13.sp,
                                    ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (message.delivery == ChatMessageDelivery.failed)
                    TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('فشل الإرسال · أعد المحاولة'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFC64F54),
                        textStyle: TextStyle(fontSize: 9.sp),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  else if (deleteError != null)
                    TextButton.icon(
                      onPressed: onRetryDelete,
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('تعذر الحذف · أعد المحاولة'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFC64F54),
                        textStyle: TextStyle(fontSize: 9.sp),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            if (onDelete != null)
              PopupMenuButton<String>(
                enabled: !isDeleting,
                tooltip: 'خيارات الرسالة',
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18.sp,
                  color: const Color(0xFF8494A7),
                ),
                onSelected: (value) async {
                  if (value != 'delete') return;
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف الرسالة؟'),
                      content: const Text('سيتم حذف هذه الرسالة من المحادثة.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFC64F54),
                          ),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete == true) onDelete?.call();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFC64F54),
                        ),
                        SizedBox(width: 9),
                        Text('حذف الرسالة'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ChatReadStatusBanner extends StatelessWidget {
  const ChatReadStatusBanner({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    super.key,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && errorMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15.w, 8.h, 15.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: errorMessage == null
            ? const Color(0xFFEAF2FB)
            : const Color(0xFFFFF3E9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 13.w,
              height: 13.w,
              child: const CircularProgressIndicator(strokeWidth: 1.8),
            )
          else
            const Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: Color(0xFFAD672A),
            ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              errorMessage ?? 'جارٍ تحديث حالة القراءة...',
              style: TextStyle(
                color: errorMessage == null
                    ? const Color(0xFF426384)
                    : const Color(0xFF875421),
                fontSize: 10.sp,
              ),
            ),
          ),
          if (!isLoading)
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class ChatMessageComposer extends StatelessWidget {
  const ChatMessageComposer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 9.h, 13.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE7EDF4), width: 1.h),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 110.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F9),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF9AA7B7),
                      fontSize: 12.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 17.w,
                      vertical: 12.h,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: const Color(0xFF29435F),
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 9.w),
            Material(
              color: const Color(0xFF0B67C8),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 46.w,
                  height: 46.w,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPersonAvatar extends StatelessWidget {
  const ChatPersonAvatar({
    required this.imageUrl,
    required this.radius,
    super.key,
  });

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imageUrl ?? '');
    final validUri =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8F1FA),
      backgroundImage: validUri
          ? CachedNetworkImageProvider(uri.toString())
          : null,
      child: validUri
          ? null
          : Icon(
              Icons.person_rounded,
              color: const Color(0xFF7F94AA),
              size: 22.sp,
            ),
    );
  }
}

class ChatConversationError extends StatelessWidget {
  const ChatConversationError({
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
            Icons.mark_chat_unread_outlined,
            size: 46,
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

class ChatInlineMessageError extends StatelessWidget {
  const ChatInlineMessageError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(13.w, 5.h, 13.w, 0),
    padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3E9),
      borderRadius: BorderRadius.circular(11.r),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: const Color(0xFF9A5A24), fontSize: 9.sp),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('حاول مرة أخرى')),
      ],
    ),
  );
}

String _messageTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'م' : 'ص';
  return '$hour:$minute $period';
}
