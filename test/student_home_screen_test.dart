import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/repositories/amenities_repository.dart';
import 'package:skann_app/features/home/data/repositories/locations_repository.dart';
import 'package:skann_app/features/home/data/repositories/properties_repository.dart';
import 'package:skann_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:skann_app/features/home/presentation/cubit/home_state.dart';
import 'package:skann_app/features/home/presentation/views/student_home_screen.dart';

void main() {
  setUpAll(initializeDependencies);

  testWidgets('shows properties and dynamic filter options', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    sl.unregister<PropertiesRepository>();
    sl.unregister<LocationsRepository>();
    sl.unregister<AmenitiesRepository>();
    final propertiesRepository = _PropertiesRepository();
    sl.registerLazySingleton<PropertiesRepository>(() => propertiesRepository);
    sl.registerLazySingleton<LocationsRepository>(() => _LocationsRepository());
    sl.registerLazySingleton<AmenitiesRepository>(() => _AmenitiesRepository());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, child) =>
            const MaterialApp(home: StudentHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['حسابي', 'المفضلة', 'سكناتي', 'البحث', 'الرئيسية']) {
      expect(find.text(label), findsOneWidget);
    }

    final homeState =
        tester.element(find.text('سكن النخبة الجامعي')).read<HomeCubit>().state
            as HomeLoaded;
    expect(homeState.locations, hasLength(1));
    expect(homeState.amenities, hasLength(1));
    expect(find.text('سكن النخبة الجامعي'), findsOneWidget);
    expect(find.text('شبرا، القاهرة'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('ظبّط اختياراتك'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    expect(find.text('القاهرة'), findsOneWidget);
    await tester.tap(find.text('القاهرة').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    expect(find.text('مدينة نصر'), findsOneWidget);
    await tester.tap(find.text('مدينة نصر'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('واي فاي'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'واي فاي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض السكنات المناسبة'));
    await tester.pumpAndSettle();

    expect(propertiesRepository.lastFilters?.city, 'القاهرة');
    expect(propertiesRepository.lastFilters?.area, 'مدينة نصر');
    expect(propertiesRepository.lastFilters?.amenities, ['WiFi']);
  });
}

class _PropertiesRepository implements PropertiesRepository {
  PropertyFilters? lastFilters;

  @override
  Future<Either<Failure, PropertyPageModel>> fetchProperties({
    required int page,
    required int limit,
    required PropertyFilters filters,
    String? search,
  }) async {
    lastFilters = filters;
    return Right(
      PropertyPageModel(
        items: const [
          PropertyModel(
            id: 'property-1',
            title: 'سكن النخبة الجامعي',
            city: 'القاهرة',
            area: 'شبرا',
            startingPrice: 1500,
            currency: 'EGP',
            rating: 4.9,
            propertyType: 'STUDENT_HOUSING',
            genderPolicy: 'MALE',
            availableRooms: 1,
            amenities: ['WiFi'],
          ),
        ],
        pagination: PropertyPaginationModel(
          page: page,
          limit: limit,
          totalItems: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      ),
    );
  }
}

class _LocationsRepository implements LocationsRepository {
  @override
  Future<Either<Failure, List<LocationModel>>> getLocations() async {
    return const Right([
      LocationModel(
        id: 'cairo',
        nameAr: 'القاهرة',
        nameEn: 'Cairo',
        areas: [
          AreaModel(id: 'nasr-city', nameAr: 'مدينة نصر', nameEn: 'Nasr City'),
        ],
      ),
    ]);
  }
}

class _AmenitiesRepository implements AmenitiesRepository {
  @override
  Future<Either<Failure, List<AmenityModel>>> getAmenities() async {
    return const Right([
      AmenityModel(
        id: 'wifi-id',
        name: 'WiFi',
        icon: 'wifi',
        category: 'Connectivity',
      ),
    ]);
  }
}
