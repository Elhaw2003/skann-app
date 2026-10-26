import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/network/connectivity_guard.dart';
import 'package:skann_app/core/network/dio_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/data/repositories/auth_repository.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper.instance,
  );

  sl.registerLazySingleton<Dio>(() => Dio());

  // ── Core ──────────────────────────────────────────────────────────────────

  sl.registerLazySingleton<ConnectivityGuard>(() => ConnectivityGuard());
  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiConsumer: sl(), secureStorageHelper: sl()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(authRepository: sl()));
}
