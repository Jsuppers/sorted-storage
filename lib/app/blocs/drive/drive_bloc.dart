import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;
import 'package:web/app/models/http_client.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/blocs/drive/drive_event.dart';

class DriveBloc extends Bloc<DriveEvent, DriveApi> {
  DriveBloc() : super(null) {
    this.add(InitialDriveEvent());
  }

  @override
  Stream<DriveApi> mapEventToState(DriveEvent event) async* {
    if (event is InitialDriveEvent) {
      yield _initialize(event.user);
    }
  }

  DriveApi _initialize(usr.User user) {
    http.Client client;
    if (user != null) {
      client = ClientWithAuthHeaders(user.headers);
    } else {
      client = ClientWithGoogleDriveKey();
    }
    return DriveApi(client);
  }
}
