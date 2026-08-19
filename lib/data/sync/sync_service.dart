import '../../models/sync_status.dart';
import '../../models/task.dart';
import '../local/local_task_source.dart';
import '../remote/firestore_task_source.dart';
import 'remote_snapshot_merger.dart';

/// Push/pull/merge logic. Plain Dart, no Bloc/UI dependency — [SyncCubit]
/// drives when this runs.
class SyncService {
  SyncService({required LocalTaskSource local, required FirestoreTaskSource remote})
      : _local = local,
        _remote = remote,
        _merger = RemoteSnapshotMerger(local);

  final LocalTaskSource _local;
  final FirestoreTaskSource _remote;
  final RemoteSnapshotMerger _merger;

  /// Pushes pending local changes, then pulls a fresh remote snapshot.
  /// Safe to call repeatedly (e.g. on every reconnect).
  Future<void> syncNow() async {
    await _push();
    try {
      final remoteTasks = await _remote.fetchAll();
      await mergeRemoteSnapshot(remoteTasks);
    } catch (_) {
      // Offline or transient failure: local cache stays authoritative.
    }
  }

  Future<void> _push() async {
    final pending = _local.getAll().where((t) => t.syncStatus.isPending);
    for (final task in pending) {
      try {
        if (task.syncStatus == SyncStatus.pendingDelete) {
          await _remote.delete(task.id);
          await _local.delete(task.id);
        } else {
          await _remote.upsert(task);
          await _local.put(task.copyWith(syncStatus: SyncStatus.synced));
        }
      } catch (_) {
        // Leave as pending; retried on the next sync cycle.
      }
    }
  }

  /// Reused by both the one-shot pull above and the live Firestore listener
  /// in [SyncCubit].
  Future<void> mergeRemoteSnapshot(List<Task> remoteTasks) => _merger.merge(remoteTasks);
}
