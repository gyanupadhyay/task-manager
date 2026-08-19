import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Two-tier connectivity check: [connectivity_plus] gives a fast, cheap
/// signal whenever the network interface changes (wifi/cellular/none);
/// [InternetConnection] then probes actual reachability, since a live
/// interface doesn't guarantee the internet is actually reachable
/// (captive portals, router with no uplink, etc.).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity, InternetConnection? internetConnection})
      : _connectivity = connectivity ?? Connectivity(),
        _internetConnection = internetConnection ?? InternetConnection();

  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  /// One-shot reachability probe.
  Future<bool> get hasInternetAccess => _internetConnection.hasInternetAccess;

  /// Emits the up-to-date online/offline status: an immediate value, then a
  /// re-probed value every time the network interface changes.
  Stream<bool> get onlineStatusStream async* {
    yield await hasInternetAccess;
    await for (final results in _connectivity.onConnectivityChanged) {
      final hasInterface = results.any((r) => r != ConnectivityResult.none);
      yield hasInterface ? await hasInternetAccess : false;
    }
  }
}
