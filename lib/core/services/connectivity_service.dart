import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Stream for listening to changes (e.g., user toggles WiFi)
  Stream<List<ConnectivityResult>> get onStatusChanged =>
      _connectivity.onConnectivityChanged;

  // NEW: Helper to check current status instantly
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // If the list contains 'none', we are offline. Otherwise, we have some connection.
    return !result.contains(ConnectivityResult.none);
  }
}
