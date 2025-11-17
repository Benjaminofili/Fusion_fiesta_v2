import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onStatusChanged =>
      _connectivity.onConnectivityChanged;
}
