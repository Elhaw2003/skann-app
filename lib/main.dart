import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/routing_generation_config.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_unread_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) => sl<ChatUnreadCubit>()..startPolling(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Skann App',
            routerConfig: RoutingGenerationConfig.routerGeneratorConfig,
          ),
        );
      },
    );
  }
}
