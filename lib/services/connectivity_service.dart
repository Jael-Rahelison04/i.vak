import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Future<bool> checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi);
  }

  static Future<bool> checkNetworkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<List<ConnectivityResult>> checkInitialConnectivity() async {
    return await Connectivity().checkConnectivity();
  }

  static bool handleConnectivityChange(List<ConnectivityResult> results) {
    return results.any(
      (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
    );
  }

  static Future<void> refreshConnection({
    required Function(bool) setRefreshing,
    required Function(bool) setOnline,
    required Function() checkConnection,
  }) async {
    setRefreshing(true);
    await Future.delayed(const Duration(seconds: 1));
    await checkConnection();
    setRefreshing(false);
  }

  static void updateConnectionStatus(
    ConnectivityResult result,
    Function(bool) setOnline,
  ) {
    setOnline(
      result == ConnectivityResult.mobile || result == ConnectivityResult.wifi,
    );
  }
}
