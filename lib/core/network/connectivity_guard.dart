import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class ConnectivityGuard {
  static Future<bool> hasNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Returns true only when there's real internet reachability (not just WiFi).
  static Future<bool> hasInternet({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final results = await Connectivity().checkConnectivity();

    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(timeout);

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
