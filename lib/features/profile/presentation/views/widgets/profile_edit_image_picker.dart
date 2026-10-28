import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditImagePicker extends StatefulWidget {
  const ProfileEditImagePicker({
    required this.imageUrl,
    required this.onImageSelected,
    super.key,
  });

  final String? imageUrl;
  final void Function(XFile? image) onImageSelected;

  @override
  State<ProfileEditImagePicker> createState() => _ProfileEditImagePickerState();
}

class _ProfileEditImagePickerState extends State<ProfileEditImagePicker> {
  XFile? _pickedImage;
  bool _isPickingImage = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82.w,
                height: 82.w,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F1FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDCE8F7)),
                ),
                child: ClipOval(child: _buildAvatar()),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 29.w,
                  height: 29.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF075BC5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الصورة الشخصية',
                  style: TextStyle(
                    color: const Color(0xFF20344F),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _pickedImage == null
                      ? 'أضف صورة واضحة لملفك الشخصي'
                      : 'تم اختيار صورة جديدة',
                  style: TextStyle(
                    color: const Color(0xFF718096),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 9.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 7.h,
                  children: [
                    _imageAction(
                      label: 'الكاميرا',
                      icon: Icons.photo_camera_outlined,
                      source: ImageSource.camera,
                    ),
                    _imageAction(
                      label: 'المعرض',
                      icon: Icons.photo_library_outlined,
                      source: ImageSource.gallery,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = widget.imageUrl;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _avatarPlaceholder(),
        errorWidget: (context, url, error) => _avatarPlaceholder(),
      );
    }
    return _avatarPlaceholder();
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: const Color(0xFFEAF2FC),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 38.sp,
        color: const Color(0xFF7C91AB),
      ),
    );
  }

  Widget _imageAction({
    required String label,
    required IconData icon,
    required ImageSource source,
  }) {
    return OutlinedButton.icon(
      onPressed: _isPickingImage ? null : () => _pickImage(source),
      icon: Icon(icon, size: 15.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF075BC5),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        visualDensity: VisualDensity.compact,
        side: const BorderSide(color: Color(0xFFD8E5F5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.r),
        ),
        textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
      );
      if (image == null) return;

      if (!mounted) return;
      setState(() {
        _pickedImage = image;
      });
      widget.onImageSelected(image);
    } on MissingPluginException {
      if (!mounted) return;
      _showError(
        'ميزة الصور لم تُحمّل بعد. أغلق التطبيق وافتحه من جديد، أو أعد تشغيله بالكامل من Flutter.',
      );
    } on PlatformException catch (exception) {
      if (!mounted) return;
      _showError(_imagePickerErrorMessage(exception, source));
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  String _imagePickerErrorMessage(
    PlatformException exception,
    ImageSource source,
  ) {
    return switch (exception.code) {
      'camera_access_denied' ||
      'camera_access_denied_without_prompt' ||
      'camera_access_restricted' =>
        'تم رفض إذن الكاميرا. فعّل إذن الكاميرا للتطبيق من إعدادات الجهاز.',
      'photo_access_denied' || 'photo_access_denied_without_prompt' =>
        'تم رفض إذن الصور. فعّل إذن الصور للتطبيق من إعدادات الجهاز.',
      'no_available_camera' => 'لا توجد كاميرا متاحة على هذا الجهاز.',
      _ =>
        'تعذر فتح ${source == ImageSource.camera ? 'الكاميرا' : 'المعرض'} (رمز الخطأ: ${exception.code}). أغلق التطبيق وافتحه من جديد، وإذا استمرت المشكلة أرسل الرمز للدعم.',
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
