//import 'package:bloc_test/bloc_test.dart';
//import 'package:flutter_test/flutter_test.dart';
//import 'package:googleapis/drive/v3.dart';
//import 'package:mockito/mockito.dart';
//import 'package:web/app/blocs/sharing/sharing_bloc.dart';
//import 'package:web/app/blocs/sharing/sharing_event.dart';
//import 'package:web/app/blocs/sharing/sharing_state.dart';
//import 'package:web/app/services/google_drive.dart';
//
//class MockGoogleDrive extends Mock implements GoogleDrive {}
//
//class MockPermissionList extends Mock implements PermissionList {}
//
//main() {
//  group(
//    'SharingBloc',
//    () {
//      String mockFolderID = "mockFolderID";
//      String mockCommentsID = "mockCommentsID";
//      MockGoogleDrive mockGoogleDrive;
//
//      PermissionList folderPermissionList = PermissionList();
//      Permission folderPermission = Permission();
//      folderPermission.role = "reader";
//      folderPermission.type = "anyone";
//      folderPermission.id = "folderID";
//      folderPermissionList.permissions = [folderPermission];
//
//      Permission commentPermission = Permission();
//      commentPermission.role = "writer";
//      commentPermission.type = "anyone";
//      commentPermission.id = "commentID";
//
//
//      blocTest(
//        'Given a the comment and folder is already shared when the bloc is created then return a SharingSharedState',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [commentPermission];
//
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        verify: (SharingBloc bloc) {
//          expect(bloc.state, isA<SharingSharedState>());
//          expect(bloc.state.errorMessage, null);
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//        },
//      );
//
//      blocTest(
//        'Given no permissions for the comment file when the bloc is created then return a SharingNotSharedState',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [];
//
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        verify: (SharingBloc bloc) {
//          expect(bloc.state, isA<SharingNotSharedState>());
//          expect(bloc.state.errorMessage, null);
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//        },
//      );
//
//      blocTest(
//        'Given no comments ID when the bloc is created then call uploadCommentsFile',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [];
//
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, null, mockGoogleDrive);
//        },
//        verify: (SharingBloc bloc) {
//          expect(bloc.state, isA<SharingNotSharedState>());
//          expect(bloc.state.errorMessage, 'cannot retrieve permissions');
//          verify(mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//        },
//      );
//
//      blocTest(
//        'Given a stop sharing event when delete permissions throws an error then return SharingSharedState',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [commentPermission];
//
//          when(mockGoogleDrive.deletePermission(mockFolderID, "folderID"))
//              .thenThrow(Exception("cannot connect"));
//
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        act: (bloc) => bloc.add(StopSharingEvent()),
//        verify: (SharingBloc bloc) {
//          verify(mockGoogleDrive.deletePermission(mockFolderID, "folderID"));
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//          expect(bloc.state, isA<SharingSharedState>());
//          expect(bloc.state.errorMessage,
//              'error while stopping sharing, please try again');
//        },
//      );
//
//      blocTest(
//        'Given a stop sharing event when delete is successful then return SharingNotSharedState',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [commentPermission];
//
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        act: (bloc) => bloc.add(StopSharingEvent()),
//        verify: (SharingBloc bloc) {
//          verify(mockGoogleDrive.deletePermission(mockFolderID, "folderID"));
//          verify(mockGoogleDrive.deletePermission(mockCommentsID, "commentID"));
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//          expect(bloc.state, isA<SharingNotSharedState>());
//          expect(bloc.state.errorMessage, null);
//        },
//      );
//
//      blocTest(
//        'Given a start sharing event when create permission throws error then return error message',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [];
//
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        act: (bloc) => bloc.add(StartSharingEvent()),
//        verify: (SharingBloc bloc) {
//          verify(mockGoogleDrive.createPermission(any, any));
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//          expect(bloc.state, isA<SharingNotSharedState>());
//          expect(bloc.state.errorMessage, 'error while sharing folder, please try again');
//        },
//      );
//
//
//      blocTest(
//        'Given a StartSharingEvent when create permission is successful then return SharingSharedState',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          commentsPermissionList.permissions = [];
//
//          when(mockGoogleDrive.createPermission(mockCommentsID, any))
//              .thenAnswer((_) => Future.value(commentPermission));
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        act: (bloc) => bloc.add(StartSharingEvent()),
//        verify: (SharingBloc bloc) {
//          verify(mockGoogleDrive.createPermission(any, any));
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//          expect(bloc.state, isA<SharingSharedState>());
//          expect(bloc.state.errorMessage, null);
//        },
//      );
//
//      blocTest(
//        'Given a StartSharingEvent when create permission returns null is successful then return SharingSharedState',
//        build: () {
//          mockGoogleDrive = MockGoogleDrive();
//          PermissionList commentsPermissionList = PermissionList();
//          Permission nullPermission = Permission();
//          commentsPermissionList.permissions = [];
//
//          when(mockGoogleDrive.createPermission(mockCommentsID, any))
//              .thenAnswer((_) => Future.value(nullPermission));
//          when(mockGoogleDrive.listPermissions(mockFolderID))
//              .thenAnswer((_) => Future.value(folderPermissionList));
//          when(mockGoogleDrive.listPermissions(mockCommentsID))
//              .thenAnswer((_) => Future.value(commentsPermissionList));
//
//          return SharingBloc(mockFolderID, mockCommentsID, mockGoogleDrive);
//        },
//        act: (bloc) => bloc.add(StartSharingEvent()),
//        verify: (SharingBloc bloc) {
//          verifyNever(
//              mockGoogleDrive.uploadCommentsFile(folderID: mockFolderID));
//          expect(bloc.state, isA<SharingNotSharedState>());
//          expect(bloc.state.errorMessage, null);
//        },
//      );
//    },
//  );
//}
