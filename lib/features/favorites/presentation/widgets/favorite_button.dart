import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.property,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFFE44861),
    super.key,
  });

  final PropertyModel property;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final propertyId = property.id;
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) {
        if (propertyId == null) return false;
        return previous.isFavorite(property) != current.isFavorite(property) ||
            previous.pendingPropertyIds.contains(propertyId) !=
                current.pendingPropertyIds.contains(propertyId);
      },
      builder: (context, state) {
        final isFavorite = state.isFavorite(property);
        final isPending =
            propertyId != null && state.pendingPropertyIds.contains(propertyId);
        return Semantics(
          button: true,
          label: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
          child: Material(
            color: backgroundColor.withValues(alpha: 0.96),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isPending ? null : () => _toggle(context),
              child: SizedBox(
                width: 42.w,
                height: 42.w,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: isPending
                        ? SizedBox(
                            key: const ValueKey('favorite-loading'),
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: iconColor,
                            ),
                          )
                        : Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isFavorite),
                            color: iconColor,
                            size: 23.sp,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggle(BuildContext context) async {
    final message = await context.read<FavoritesCubit>().toggleFavorite(
      property,
    );
    if (message == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
