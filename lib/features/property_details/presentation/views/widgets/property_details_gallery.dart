import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

class PropertyDetailsGallery extends StatefulWidget {
  const PropertyDetailsGallery({required this.images, super.key});

  final List<PropertyImageModel> images;

  @override
  State<PropertyDetailsGallery> createState() => _PropertyDetailsGalleryState();
}

class _PropertyDetailsGalleryState extends State<PropertyDetailsGallery> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return SizedBox(
      height: 300.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            const _GalleryPlaceholder()
          else
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final uri = _validImageUri(images[index].url);
                if (uri == null) return const _GalleryPlaceholder();
                return CachedNetworkImage(
                  imageUrl: uri.toString(),
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const _GalleryPlaceholder(),
                  progressIndicatorBuilder: (context, url, progress) =>
                      const _GalleryPlaceholder(showProgress: true),
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
                    '${_currentPage + 1} / ${images.length}',
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

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder({this.showProgress = false});

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
                Icons.home_work_outlined,
                size: 56.sp,
                color: const Color(0xFF9AAFC5),
              ),
      ),
    );
  }
}

Uri? _validImageUri(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !uri.hasAuthority ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return null;
  }
  return uri;
}
