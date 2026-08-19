import '../../models/sync_status.dart';
import '../../models/task.dart';
import '../local/local_task_source.dart';

/// Last-write-wins merge of a remote Firestore snapshot into the local
/// cache. Pulled out of [SyncService] as its own unit (no remote/network
/// dependency) so the merge rules are directly unit-testable.
class RemoteSnapshotMerger {
  const RemoteSnapshotMerger(this._local);

  final LocalTaskSource _local;

  Future<void> merge(List<Task> remoteTasks) async {
    final remoteById = {for (final t in remoteTasks) t.id: t};
    final localTasks = _local.getAll();

    for (final remote in remoteTasks) {
      final local = _local.getById(remote.id);
      if (local == null) {
        await _local.put(remote);
      } else if (!local.syncStatus.isPending && remote.updatedAt.isAfter(local.updatedAt)) {
        await _local.put(remote);
      }
      // Otherwise local has unpushed edits (or is already newer) -> local wins until pushed.
    }

    for (final local in localTasks) {
      if (local.syncStatus == SyncStatus.synced && !remoteById.containsKey(local.id)) {
        await _local.delete(local.id);
      }
    }
  }
}
