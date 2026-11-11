import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/network/connectivity_guard.dart';
import 'package:skann_app/core/network/dio_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/data/repositories/auth_repository.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skann_app/features/home/data/repositories/amenities_repository.dart';
import 'package:skann_app/features/home/data/repositories/locations_repository.dart';
import 'package:skann_app/features/home/data/repositories/properties_repository.dart';
import 'package:skann_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:skann_app/features/profile/data/repositories/profile_repository.dart';
import 'package:skann_app/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_cubit.dart';
import 'package:skann_app/features/matching_roommates/data/repositories/matching_roommates_repository.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_cubit.dart';
import 'package:skann_app/features/booking_requests/data/repositories/booking_requests_repo.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/favorites/data/repositories/favorites_repository.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_conversation_cubit.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_inbox_cubit.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_launcher_cubit.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_unread_cubit.dart';

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
  sl.registerLazySingleton<PropertiesRepository>(
    () => PropertiesRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<LocationsRepository>(
    () => LocationsRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<AmenitiesRepository>(
    () => AmenitiesRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      propertiesRepository: sl(),
      locationsRepository: sl(),
      amenitiesRepository: sl(),
    ),
  );
  sl.registerLazySingleton<PropertyDetailsRepository>(
    () => PropertyDetailsRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerFactory<PropertyDetailsCubit>(
    () => PropertyDetailsCubit(repository: sl()),
  );
  sl.registerFactory<RoomDetailsCubit>(
    () => RoomDetailsCubit(repository: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(repository: sl(), secureStorageHelper: sl()),
  );
  sl.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(repository: sl()),
  );
  sl.registerLazySingleton<MatchingRoommatesRepository>(
    () => MatchingRoommatesRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerFactory<MatchingRoommatesCubit>(
    () => MatchingRoommatesCubit(repository: sl()),
  );
  sl.registerFactory<RoommatesDirectoryCubit>(
    () => RoommatesDirectoryCubit(repository: sl()),
  );
  sl.registerLazySingleton<BookingRequestsRepo>(
    () => BookingRequestsRepoImpl(apiConsumer: sl()),
  );
  sl.registerFactory<BookingRequestsCubit>(
    () => BookingRequestsCubit(repository: sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(repository: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(apiConsumer: sl()),
  );
  sl.registerFactory<ChatInboxCubit>(
    () => ChatInboxCubit(repository: sl(), secureStorageHelper: sl()),
  );
  sl.registerFactory<ChatConversationCubit>(
    () => ChatConversationCubit(repository: sl(), secureStorageHelper: sl()),
  );
  sl.registerFactory<ChatLauncherCubit>(
    () => ChatLauncherCubit(repository: sl()),
  );
  sl.registerFactory<ChatUnreadCubit>(
    () => ChatUnreadCubit(repository: sl(), secureStorageHelper: sl()),
  );
}
