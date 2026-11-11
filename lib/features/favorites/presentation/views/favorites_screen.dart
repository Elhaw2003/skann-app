import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:skann_app/features/favorites/presentation/widgets/favorites_content.dart';
import 'package:skann_app/features/favorites/presentation/widgets/favorites_state_views.dart';
import 'package:skann_app/features/home/presentation/views/widgets/student_bottom_navigation_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: sl<FavoritesCubit>(),
    child: const _FavoritesView(),
  );
}

class _FavoritesView extends StatefulWidget {
  const _FavoritesView();

  @override
  State<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<_FavoritesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesCubit>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        bottomNavigationBar: StudentBottomNavigationBar(
          selectedIndex: 1,
          onDestinationSelected: (index) {
            if (index == 0) context.go(AppRoutes.studentHome);
            if (index == 2) context.go(AppRoutes.profile);
            if (index == 3) context.go(AppRoutes.myBookings);
            if (index == 4) context.go(AppRoutes.chats);
          },
        ),
        body: SafeArea(
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              if (state.isLoading && state.properties.isEmpty) {
                return const FavoritesLoadingView();
              }
              if (state case FavoritesFailure(
                hasLoaded: false,
                errorMessage: final message?,
              )) {
                return FavoritesFailureView(
                  message: message,
                  onRetry: context.read<FavoritesCubit>().loadFavorites,
                );
              }
              return FavoritesContent(state: state);
            },
          ),
        ),
      ),
    );
  }
}
