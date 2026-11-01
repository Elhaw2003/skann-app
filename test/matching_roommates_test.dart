import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/matching_roommates/data/models/matching_roommates_page_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommates_directory_filters.dart';
import 'package:skann_app/features/matching_roommates/data/repositories/matching_roommates_repository.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_state.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_state.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/matching_roommates_screen.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/roommates_screen.dart';

void main() {
  group('Roommate models and repository', () {
    test('parses roommate fields and pagination metadata', () {
      final page = MatchingRoommatesPageModel.fromJson(
        _response(),
        fallbackPage: 1,
        fallbackLimit: 10,
      );
      final roommate = page.items.single;

      expect(roommate.id, 'roommate-1');
      expect(roommate.fullName, 'مريم أحمد');
      expect(roommate.profileImage, isNull);
      expect(roommate.bio, isNull);
      expect(roommate.major, isNull);
      expect(roommate.interests, isEmpty);
      expect(page.pagination.page, 1);
      expect(page.pagination.totalItems, 1);
      expect(page.pagination.hasNextPage, isTrue);
    });

    test('handles missing and null optional roommate fields safely', () {
      final roommate = RoommateModel.fromJson({
        'id': 'roommate-2',
        'fullName': 'طالب',
        'profileImage': null,
        'bio': null,
        'major': null,
        'interests': null,
      });

      expect(roommate.profileImage, isNull);
      expect(roommate.bio, isNull);
      expect(roommate.major, isNull);
      expect(roommate.phone, isNull);
      expect(roommate.interests, isEmpty);
    });

    test(
      'requests the authenticated roommate endpoint with matching enabled',
      () async {
        final api = _FakeApiConsumer(_response());
        final repository = MatchingRoommatesRepositoryImpl(apiConsumer: api);

        final result = await repository.getMatchingRoommates(
          page: 2,
          limit: 10,
        );

        expect(api.getPath, 'users/roommates');
        expect(api.queryParameters, {
          'matchMyProfile': true,
          'page': 2,
          'limit': 10,
        });
        expect(result.isRight(), isTrue);
      },
    );

    test('returns failure for an unsuccessful API response', () async {
      final repository = MatchingRoommatesRepositoryImpl(
        apiConsumer: _FakeApiConsumer({
          'success': false,
          'code': 'ROOMMATES_FAILED',
          'message': 'Could not load roommates.',
        }),
      );

      final result = await repository.getMatchingRoommates(page: 1, limit: 10);

      expect(result.isLeft(), isTrue);
    });

    test(
      'requests the directory without matching and omits blank filters',
      () async {
        final api = _FakeApiConsumer(_response());
        final repository = MatchingRoommatesRepositoryImpl(apiConsumer: api);

        final result = await repository.getRoommatesDirectory(
          page: 1,
          limit: 10,
          governorate: ' الغربية ',
          university: ' جامعة القاهرة ',
          faculty: 'كلية الهندسة',
        );

        expect(api.getPath, 'users/roommates');
        expect(api.queryParameters, {
          'page': 1,
          'limit': 10,
          'governorate': 'الغربية',
          'university': 'جامعة القاهرة',
          'faculty': 'كلية الهندسة',
        });
        expect(api.queryParameters, isNot(contains('matchMyProfile')));
        expect(result.isRight(), isTrue);
      },
    );

    test('omits empty and null Directory filters', () async {
      final api = _FakeApiConsumer(_response());
      final repository = MatchingRoommatesRepositoryImpl(apiConsumer: api);

      await repository.getRoommatesDirectory(
        page: 1,
        limit: 10,
        governorate: ' ',
        university: null,
        faculty: '',
      );

      expect(api.queryParameters, {'page': 1, 'limit': 10});
    });
  });

  group('MatchingRoommatesCubit', () {
    test(
      'loads page one and appends unique roommates from the next page',
      () async {
        final repository = _FakeRoommatesRepository([
          _success(
            _page(
              items: [_roommate('one'), _roommate('two')],
              page: 1,
              totalPages: 2,
              hasNextPage: true,
            ),
          ),
          _success(
            _page(
              items: [_roommate('two'), _roommate('three')],
              page: 2,
              totalPages: 2,
              hasNextPage: false,
            ),
          ),
        ]);
        final cubit = MatchingRoommatesCubit(repository: repository);
        addTearDown(cubit.close);

        await cubit.load();
        await cubit.loadNextPage();

        final state = cubit.state as MatchingRoommatesLoaded;
        expect(repository.requestedPages, [1, 2]);
        expect(state.roommates.map((roommate) => roommate.id), [
          'one',
          'two',
          'three',
        ]);
        expect(state.pagination.hasNextPage, isFalse);
      },
    );

    test('preserves roommates after a next-page failure', () async {
      final repository = _FakeRoommatesRepository([
        _success(
          _page(
            items: [_roommate('one')],
            page: 1,
            totalPages: 2,
            hasNextPage: true,
          ),
        ),
        _failure(const NetworkFailure('offline')),
      ]);
      final cubit = MatchingRoommatesCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.loadNextPage();

      final state = cubit.state as MatchingRoommatesLoaded;
      expect(state.roommates.map((roommate) => roommate.id), ['one']);
      expect(state.loadMoreError, isNotNull);
      expect(state.isLoadingMore, isFalse);
    });

    test(
      'refresh requests page one and preserves data on refresh failure',
      () async {
        final repository = _FakeRoommatesRepository([
          _success(
            _page(
              items: [_roommate('one')],
              page: 1,
              totalPages: 2,
              hasNextPage: true,
            ),
          ),
          _failure(const NetworkFailure('offline')),
        ]);
        final cubit = MatchingRoommatesCubit(repository: repository);
        addTearDown(cubit.close);

        await cubit.load();
        await cubit.refresh();

        final state = cubit.state as MatchingRoommatesLoaded;
        expect(repository.requestedPages, [1, 1]);
        expect(state.roommates.single.id, 'one');
        expect(state.refreshError, isNotNull);
        expect(state.isRefreshing, isFalse);
      },
    );

    test('prevents concurrent pagination requests', () async {
      final nextPage = Completer<Either<Failure, MatchingRoommatesPageModel>>();
      final repository = _FakeRoommatesRepository([
        _success(
          _page(
            items: [_roommate('one')],
            page: 1,
            totalPages: 2,
            hasNextPage: true,
          ),
        ),
        () => nextPage.future,
      ]);
      final cubit = MatchingRoommatesCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();
      final firstRequest = cubit.loadNextPage();
      await cubit.loadNextPage();

      expect(repository.requestedPages, [1, 2]);
      nextPage.complete(
        Right(
          _page(
            items: [_roommate('two')],
            page: 2,
            totalPages: 2,
            hasNextPage: false,
          ),
        ),
      );
      await firstRequest;
    });
  });

  group('RoommatesDirectoryCubit', () {
    test(
      'emits an empty loaded state when the directory has no results',
      () async {
        final repository = _FakeRoommatesRepository([
          _success(
            _page(items: const [], page: 1, totalPages: 0, hasNextPage: false),
          ),
        ]);
        final cubit = RoommatesDirectoryCubit(repository: repository);
        addTearDown(cubit.close);

        await cubit.load();

        final state = cubit.state as RoommatesDirectoryLoaded;
        expect(state.roommates, isEmpty);
        expect(state.visibleRoommates, isEmpty);
      },
    );

    test('exposes an initial load failure and can retry', () async {
      final repository = _FakeRoommatesRepository([
        _failure(const NetworkFailure('offline')),
        _success(
          _page(
            items: [_roommate('one')],
            page: 1,
            totalPages: 1,
            hasNextPage: false,
          ),
        ),
      ]);
      final cubit = RoommatesDirectoryCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state, isA<RoommatesDirectoryFailure>());

      await cubit.load();
      expect(cubit.state, isA<RoommatesDirectoryLoaded>());
    });

    test(
      'loads directory, applies filters from page one, and filters locally',
      () async {
        final repository = _FakeRoommatesRepository([
          _success(
            _page(
              items: [_roommate('one'), _roommate('two')],
              page: 1,
              totalPages: 2,
              hasNextPage: true,
            ),
          ),
          _success(
            _page(
              items: [_roommate('three')],
              page: 2,
              totalPages: 2,
              hasNextPage: false,
            ),
          ),
          _success(
            _page(
              items: [_roommate('filtered')],
              page: 1,
              totalPages: 1,
              hasNextPage: false,
            ),
          ),
        ]);
        final cubit = RoommatesDirectoryCubit(repository: repository);
        addTearDown(cubit.close);

        await cubit.load();
        await cubit.loadNextPage();
        await cubit.applyFilters(
          const RoommatesDirectoryFilters(governorate: 'الغربية'),
        );
        cubit.updateSearch('filtered');

        final state = cubit.state as RoommatesDirectoryLoaded;
        expect(repository.directoryRequestedPages, [1, 2, 1]);
        expect(repository.directoryRequestedFilters.last, {
          'governorate': 'الغربية',
        });
        expect(state.pagination.page, 1);
        expect(state.roommates.single.id, 'filtered');
        expect(state.visibleRoommates.single.id, 'filtered');
        expect(repository.directoryRequestedPages, hasLength(3));
      },
    );

    test('preserves directory data when loading the next page fails', () async {
      final repository = _FakeRoommatesRepository([
        _success(
          _page(
            items: [_roommate('one')],
            page: 1,
            totalPages: 2,
            hasNextPage: true,
          ),
        ),
        _failure(const NetworkFailure('offline')),
      ]);
      final cubit = RoommatesDirectoryCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.loadNextPage();

      final state = cubit.state as RoommatesDirectoryLoaded;
      expect(state.roommates.single.id, 'one');
      expect(state.loadMoreError, isNotNull);
    });

    test('ignores a stale page response after applying new filters', () async {
      final oldPage = Completer<Either<Failure, MatchingRoommatesPageModel>>();
      final filteredPage =
          Completer<Either<Failure, MatchingRoommatesPageModel>>();
      final repository = _FakeRoommatesRepository([
        _success(
          _page(
            items: [_roommate('one')],
            page: 1,
            totalPages: 2,
            hasNextPage: true,
          ),
        ),
        () => oldPage.future,
        () => filteredPage.future,
      ]);
      final cubit = RoommatesDirectoryCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.load();
      final oldPageRequest = cubit.loadNextPage();
      final filterRequest = cubit.applyFilters(
        const RoommatesDirectoryFilters(university: 'جامعة القاهرة'),
      );
      filteredPage.complete(
        Right(
          _page(
            items: [_roommate('filtered')],
            page: 1,
            totalPages: 1,
            hasNextPage: false,
          ),
        ),
      );
      await filterRequest;
      oldPage.complete(
        Right(
          _page(
            items: [_roommate('stale')],
            page: 2,
            totalPages: 2,
            hasNextPage: false,
          ),
        ),
      );
      await oldPageRequest;

      final state = cubit.state as RoommatesDirectoryLoaded;
      expect(state.roommates.single.id, 'filtered');
      expect(state.filters.university, 'جامعة القاهرة');
      expect(state.pagination.page, 1);
    });
  });

  testWidgets(
    'renders roommate details and hides unavailable optional fields',
    (tester) async {
      final cubit = MatchingRoommatesCubit(
        repository: _FakeRoommatesRepository([
          _success(
            _page(
              items: [
                RoommateModel(
                  id: 'one',
                  fullName: 'مريم أحمد',
                  university: 'جامعة القاهرة',
                  profileImage: null,
                  bio: null,
                  major: null,
                  phone: null,
                ),
              ],
              page: 1,
              totalPages: 1,
              hasNextPage: false,
            ),
          ),
        ]),
      );
      await cubit.load();
      addTearDown(cubit.close);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 884),
          builder: (context, child) => MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const MatchingRoommatesView(),
            ),
          ),
        ),
      );

      expect(find.text('مريم أحمد'), findsOneWidget);
      expect(find.text('جامعة القاهرة'), findsOneWidget);
      expect(find.text('null'), findsNothing);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    },
  );

  testWidgets('keeps matching results while switching between roommate tabs', (
    tester,
  ) async {
    final repository = _FakeRoommatesRepository([
      _success(
        _page(
          items: [_roommate('suggested')],
          page: 1,
          totalPages: 1,
          hasNextPage: false,
        ),
      ),
      _success(
        _page(
          items: [_roommate('directory')],
          page: 1,
          totalPages: 1,
          hasNextPage: false,
        ),
      ),
      _success(
        _page(
          items: [_roommate('filtered-directory')],
          page: 1,
          totalPages: 1,
          hasNextPage: false,
        ),
      ),
    ]);
    final matchingCubit = MatchingRoommatesCubit(repository: repository);
    final directoryCubit = RoommatesDirectoryCubit(repository: repository);
    await matchingCubit.load();
    addTearDown(matchingCubit.close);
    addTearDown(directoryCubit.close);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: matchingCubit),
            BlocProvider.value(value: directoryCubit),
          ],
          child: const MaterialApp(home: RoommatesView()),
        ),
      ),
    );

    expect(find.text('Student suggested'), findsOneWidget);
    await tester.tap(find.text('استكشف الطلاب'));
    await tester.pumpAndSettle();
    expect(find.text('Student directory'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('تصفية زملاء السكن'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الغربية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تطبيق الفلاتر'));
    await tester.pumpAndSettle();
    expect(repository.directoryRequestedFilters.last, {
      'governorate': 'الغربية',
    });
    expect(find.text('Student filtered-directory'), findsOneWidget);
    await tester.tap(find.text('مقترحون ليك'));
    await tester.pumpAndSettle();

    expect(find.text('Student suggested'), findsOneWidget);
    expect(repository.requestedPages, [1, 1, 1]);
  });
}

Map<String, dynamic> _response() => {
  'success': true,
  'code': 'ROOMMATES_RETRIEVED',
  'message': 'تم جلب قائمة زملاء السكن بنجاح',
  'data': {
    'items': [
      {
        'id': 'roommate-1',
        'fullName': 'مريم أحمد',
        'profileImage': null,
        'gender': 'FEMALE',
        'university': 'جامعة القاهرة',
        'faculty': 'الهندسة',
        'major': null,
        'academicYear': 'السنة الثالثة',
        'governorate': 'الجيزة',
        'housingStatus': 'يبحث عن شريك سكن',
        'bio': null,
        'interests': [],
        'phone': '01011112222',
      },
    ],
    'pagination': {
      'page': 1,
      'limit': 10,
      'totalItems': 1,
      'totalPages': 2,
      'hasNextPage': true,
      'hasPreviousPage': false,
    },
  },
};

RoommateModel _roommate(String id) =>
    RoommateModel(id: id, fullName: 'Student $id');

Future<Either<Failure, MatchingRoommatesPageModel>> Function() _success(
  MatchingRoommatesPageModel page,
) {
  return () async => Right<Failure, MatchingRoommatesPageModel>(page);
}

Future<Either<Failure, MatchingRoommatesPageModel>> Function() _failure(
  Failure failure,
) {
  return () async => Left<Failure, MatchingRoommatesPageModel>(failure);
}

MatchingRoommatesPageModel _page({
  required List<RoommateModel> items,
  required int page,
  required int totalPages,
  required bool hasNextPage,
}) {
  return MatchingRoommatesPageModel(
    items: items,
    pagination: RoommatePaginationModel(
      page: page,
      limit: 10,
      totalItems: items.length,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPreviousPage: page > 1,
    ),
  );
}

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object? response;
  String? getPath;
  Map<String, dynamic>? queryParameters;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    getPath = path;
    this.queryParameters = queryParameters;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRoommatesRepository implements MatchingRoommatesRepository {
  _FakeRoommatesRepository(this._responses);

  final List<Future<Either<Failure, MatchingRoommatesPageModel>> Function()>
  _responses;
  final List<int> requestedPages = [];
  final List<int> directoryRequestedPages = [];
  final List<Map<String, String>> directoryRequestedFilters = [];

  @override
  Future<Either<Failure, MatchingRoommatesPageModel>> getMatchingRoommates({
    required int page,
    required int limit,
  }) {
    requestedPages.add(page);
    return _responses.removeAt(0)();
  }

  @override
  Future<Either<Failure, MatchingRoommatesPageModel>> getRoommatesDirectory({
    required int page,
    required int limit,
    String? governorate,
    String? university,
    String? faculty,
  }) {
    directoryRequestedPages.add(page);
    final filters = <String, String>{};
    if (governorate != null) filters['governorate'] = governorate;
    if (university != null) filters['university'] = university;
    if (faculty != null) filters['faculty'] = faculty;
    directoryRequestedFilters.add(filters);
    requestedPages.add(page);
    return _responses.removeAt(0)();
  }
}
