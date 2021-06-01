//import 'package:flutter/material.dart';
//import 'package:flutter_test/flutter_test.dart';
//import 'package:googleapis/drive/v3.dart';
//import 'package:mockito/mockito.dart';
//import 'package:web/app/models/storage_information.dart';
//import 'package:web/app/services/storage_service.dart';
//
//class MockDriveApi extends Mock implements DriveApi {}
//
//class MockAboutResourceApi extends Mock implements AboutResourceApi {}
//
//void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//
//  test(
//    'Given a getStorageInformation request '
//    'When limit is 100 and usage is 50 Then percent is 0.5',
//    () async {
//      final MockDriveApi mockDriveApi = MockDriveApi();
//      final MockAboutResourceApi mockAboutResourceApi = MockAboutResourceApi();
//
//      final About about = About();
//      about.storageQuota = AboutStorageQuota();
//      about.storageQuota.limit = '100';
//      about.storageQuota.usage = '50';
//
//      when(mockDriveApi.about).thenReturn(mockAboutResourceApi);
//      when(mockAboutResourceApi.get($fields: 'storageQuota'))
//          .thenAnswer((_) => Future<About>.value(about));
//
//      final StorageInformation storageInformation =
//          await GoogleStorageService.getStorageInformation(mockDriveApi);
//      expect(storageInformation.limit, '100 B');
//      expect(storageInformation.usage, '50 B');
//      expect(storageInformation.percent, 0.5);
//    },
//  );
//}
