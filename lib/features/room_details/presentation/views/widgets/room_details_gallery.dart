import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_common_widgets.dart';

class RoomDetailsGallery extends StatefulWidget {
  const RoomDetailsGallery({required this.images, super.key});

  final List<PropertyImageModel> images;

  @override
  State<RoomDetailsGallery> createState() => _RoomDetailsGalleryState();
}

class _RoomDetailsGalleryState extends State<RoomDetailsGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return SizedBox(
      height: 300.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            const _ImagePlaceholder()
          else
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final uri = validPropertyImageUri(images[index].url);
                if (uri == null) return const _ImagePlaceholder();
                return CachedNetworkImage(
                  imageUrl: uri.toString(),
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) =>
                      const _ImagePlaceholder(showProgress: true),
                  errorWidget: (context, url, error) =>
                      const _ImagePlaceholder(),
                );
              },
            ),
          PositionedDirectional(
            top: 12.h,
            start: 14.w,
            child: Material(
              color: Colors.white.withValues(alpha: 0.94),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'رجوع',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF213B5A),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            PositionedDirectional(
              bottom: 14.h,
              start: 0,
              end: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xB8000000),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEAF1F8),
      child: Center(
        child: showProgress
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0B67C8),
              )
            : Icon(
                Icons.bedroom_parent_outlined,
                size: 56.sp,
                color: const Color(0xFF9AAFC5),
              ),
      ),
    );
  }
}
