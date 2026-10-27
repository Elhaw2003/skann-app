import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/data/models/record_property_view_model.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_state.dart';

void main() {
  test('loads property details and records a new view independently', () async {
    final repository = _ControlledPropertyDetailsRepository();
    final cubit = PropertyDetailsCubit(repository: repository);
    cubit.open('property-1');

    repository.completeDetails('property-1', Right(_property('property-1')));
    repository.completeView(
      'property-1',
      const Right(
        RecordPropertyViewModel(
          propertyId: 'property-1',
          viewsCount: 0,
          isNewView: true,
        ),
      ),
    );
    await _flushMicrotasks();

    expect(cubit.state.status, PropertyDetailsStatus.loaded);
    expect(cubit.state.property?.id, 'property-1');
    expect(cubit.state.viewStatus, PropertyViewStatus.recordedNewView);
    await cubit.close();
  });

  test('a failed view request does not fail loaded property details', () async {
    final repository = _ControlledPropertyDetailsRepository();
    final cubit = PropertyDetailsCubit(repository: repository);
    cubit.open('property-1');

    repository.completeDetails('property-1', Right(_property('property-1')));
    repository.completeView(
      'property-1',
      const Left(NetworkFailure('offline')),
    );
    await _flushMicrotasks();

    expect(cubit.state.status, PropertyDetailsStatus.loaded);
    expect(cubit.state.property?.id, 'property-1');
    expect(cubit.state.viewStatus, PropertyViewStatus.failed);
    expect(cubit.state.viewFailure, isA<NetworkFailure>());
    await cubit.close();
  });

  test('refresh does not send another record-view request', () async {
    final repository = _ControlledPropertyDetailsRepository();
    final cubit = PropertyDetailsCubit(repository: repository);
    cubit.open('property-1');
    repository.completeDetails('property-1', Right(_property('property-1')));
    await _flushMicrotasks();

    final refresh = cubit.refresh();
    expect(repository.viewRequests, ['property-1']);
    repository.completeDetails(
      'property-1',
      Right(_property('property-1', title: 'Updated')),
      requestIndex: 1,
    );
    await refresh;

    expect(cubit.state.property?.title, 'Updated');
    expect(repository.viewRequests, ['property-1']);
    await cubit.close();
  });

  test(
    'responses from a previous property cannot replace current state',
    () async {
      final repository = _ControlledPropertyDetailsRepository();
      final cubit = PropertyDetailsCubit(repository: repository);
      cubit.open('property-a');
      cubit.open('property-b');

      repository.completeDetails('property-a', Right(_property('property-a')));
      repository.completeView(
        'property-a',
        const Right(
          RecordPropertyViewModel(
            propertyId: 'property-a',
            viewsCount: 1,
            isNewView: true,
          ),
        ),
      );
      await _flushMicrotasks();

      expect(cubit.state.propertyId, 'property-b');
      expect(cubit.state.property, isNull);
      expect(cubit.state.viewStatus, PropertyViewStatus.recording);

      repository.completeDetails('property-b', Right(_property('property-b')));
      repository.completeView(
        'property-b',
        const Right(
          RecordPropertyViewModel(
            propertyId: 'property-b',
            viewsCount: 0,
            isNewView: false,
          ),
        ),
      );
      await _flushMicrotasks();

      expect(cubit.state.property?.id, 'property-b');
      expect(cubit.state.viewStatus, PropertyViewStatus.alreadyRecorded);
      expect(repository.detailsRequests, ['property-a', 'property-b']);
      expect(repository.viewRequests, ['property-a', 'property-b']);
      await cubit.close();
    },
  );

  test(
    'reopening the current property does not duplicate its view request',
    () async {
      final repository = _ControlledPropertyDetailsRepository();
      final cubit = PropertyDetailsCubit(repository: repository);
      cubit.open('property-1');
      cubit.open('property-1');

      expect(repository.detailsRequests, ['property-1']);
      expect(repository.viewRequests, ['property-1']);
      await cubit.close();
    },
  );
}

PropertyModel _property(String id, {String title = 'سكن'}) =>
    PropertyModel(id: id, title: title);

Future<void> _flushMicrotasks() => Future<void>.delayed(Duration.zero);

class _ControlledPropertyDetailsRepository
    implements PropertyDetailsRepository {
  final List<String> detailsRequests = [];
  final List<String> viewRequests = [];
  final Map<String, List<Completer<Either<Failure, PropertyModel>>>> _details =
      {};
  final Map<String, Completer<Either<Failure, RecordPropertyViewModel>>>
  _views = {};

  @override
  Future<Either<Failure, PropertyModel>> getPropertyDetails(String propertyId) {
    detailsRequests.add(propertyId);
    final responses = _details.putIfAbsent(propertyId, () => []);
    final completer = Completer<Either<Failure, PropertyModel>>();
    responses.add(completer);
    return completer.future;
  }

  @override
  Future<Either<Failure, RecordPropertyViewModel>> recordPropertyView(
    String propertyId,
  ) {
    viewRequests.add(propertyId);
    final completer = Completer<Either<Failure, RecordPropertyViewModel>>();
    _views[propertyId] = completer;
    return completer.future;
  }

  void completeDetails(
    String propertyId,
    Either<Failure, PropertyModel> result, {
    int requestIndex = 0,
  }) {
    _details[propertyId]![requestIndex].complete(result);
  }

  void completeView(
    String propertyId,
    Either<Failure, RecordPropertyViewModel> result,
  ) {
    _views[propertyId]!.complete(result);
  }
}
