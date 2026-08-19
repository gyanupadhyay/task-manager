import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/data/local/local_task_source.dart';
import 'package:task_manager/data/local/task_hive_adapter.dart';
import 'package:task_manager/data/sync/remote_snapshot_merger.dart';
import 'package:task_manager/models/priority.dart';
import 'package:task_manager/models/sync_status.dart';
import 'package:task_manager/models/task.dart';

/// Exercises RemoteSnapshotMerger's last-write-wins rules (the core of
/// SyncService) against a real, temp-directory Hive box — no
/// Firestore/network involved.
void main() {
  late Directory tempDir;
  late Box<Task> box;
  late LocalTaskSource local;
  late RemoteSnapshotMerger merger;

  Task makeTask(String id, {required DateTime updatedAt, SyncStatus syncStatus = SyncStatus.synced}) {
    return Task(
      id: id,
      title: 'Task $id',
      description: '',
      priority: Priority.medium,
      dueDate: DateTime(2026, 9, 1),
      isCompleted: false,
      createdAt: updatedAt,
      updatedAt: updatedAt,
      syncStatus: syncStatus,
    );
  }

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('task_manager_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskHiveAdapter());
    }
    box = await Hive.openBox<Task>('test_tasks');
    local = LocalTaskSource(box);
    merger = RemoteSnapshotMerger(local);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_tasks', path: tempDir.path);
    tempDir.deleteSync(recursive: true);
  });

  test('remote task not present locally is adopted as-is', () async {
    final remote = makeTask('a', updatedAt: DateTime(2026, 1, 1));

    await merger.merge([remote]);

    expect(local.getById('a'), remote);
  });

  test('newer remote update overwrites a synced local task', () async {
    await local.put(makeTask('a', updatedAt: DateTime(2026, 1, 1)));
    final newerRemote = makeTask('a', updatedAt: DateTime(2026, 1, 5));

    await merger.merge([newerRemote]);

    expect(local.getById('a')!.updatedAt, DateTime(2026, 1, 5));
  });

  test('local task with unpushed edits is not overwritten by remote', () async {
    final pendingLocal =
        makeTask('a', updatedAt: DateTime(2026, 1, 10), syncStatus: SyncStatus.pendingUpdate);
    await local.put(pendingLocal);
    final remote = makeTask('a', updatedAt: DateTime(2026, 1, 1));

    await merger.merge([remote]);

    expect(local.getById('a')!.syncStatus, SyncStatus.pendingUpdate);
    expect(local.getById('a')!.updatedAt, DateTime(2026, 1, 10));
  });

  test('a synced local task missing from the remote snapshot is deleted', () async {
    await local.put(makeTask('a', updatedAt: DateTime(2026, 1, 1)));

    await merger.merge([]);

    expect(local.getById('a'), isNull);
  });

  test('a pendingCreate local task missing remotely survives (not yet pushed)', () async {
    await local.put(makeTask('a', updatedAt: DateTime(2026, 1, 1), syncStatus: SyncStatus.pendingCreate));

    await merger.merge([]);

    expect(local.getById('a'), isNotNull);
  });
}
