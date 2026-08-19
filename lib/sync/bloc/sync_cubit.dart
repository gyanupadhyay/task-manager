import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../data/connectivity/connectivity_service.dart';
import '../../data/local/local_task_source.dart';
import '../../data/remote/firestore_task_source.dart';
import '../../data/sync/sync_service.dart';

part 'sync_state.dart';

/// Drives the sync indicator: watches connectivity, triggers [SyncService]
/// on reconnect, keeps a live Firestore listener while online, and tracks
/// how many local tasks are still unpushed.
class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required ConnectivityService connectivityService,
    required SyncService syncService,
    required LocalTaskSource localTaskSource,
    required FirestoreTaskSource firestoreTaskSource,
  })  : _connectivityService = connectivityService,
        _syncService = syncService,
        _localTaskSource = localTaskSource,
        _firestoreTaskSource = firestoreTaskSource,
        super(const SyncState.initial());

  final ConnectivityService _connectivityService;
  final SyncService _syncService;
  final LocalTaskSource _localTaskSource;
  final FirestoreTaskSource _firestoreTaskSource;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<BoxEvent>? _localWatchSub;
  StreamSubscription<List<dynamic>>? _remoteWatchSub;

  void start() {
    _recomputePendingCount();
    _localWatchSub = _localTaskSource.watch().listen((_) => _recomputePendingCount());
    _connectivitySub = _connectivityService.onlineStatusStream.listen(_onOnlineStatusChanged);
  }

  Future<void> _onOnlineStatusChanged(bool isOnline) async {
    emit(state.copyWith(isOnline: isOnline));
    if (isOnline) {
      await _syncNow();
      _remoteWatchSub ??= _firestoreTaskSource.watchAll().listen(
            (tasks) => _syncService.mergeRemoteSnapshot(tasks).catchError((_) {}),
            onError: (_) {},
          );
    } else {
      await _remoteWatchSub?.cancel();
      _remoteWatchSub = null;
    }
  }

  Future<void> _syncNow() async {
    emit(state.copyWith(phase: SyncPhase.syncing));
    try {
      await _syncService.syncNow();
      emit(state.copyWith(phase: SyncPhase.idle));
    } catch (_) {
      emit(state.copyWith(phase: SyncPhase.error));
    }
    _recomputePendingCount();
  }

  void _recomputePendingCount() {
    final pending = _localTaskSource.getAll().where((t) => t.syncStatus.isPending).length;
    emit(state.copyWith(pendingCount: pending));
  }

  @override
  Future<void> close() async {
    await _connectivitySub?.cancel();
    await _localWatchSub?.cancel();
    await _remoteWatchSub?.cancel();
    return super.close();
  }
}
