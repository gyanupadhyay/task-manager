import 'dart:async' show unawaited;

import '../models/priority.dart';
import '../models/sync_status.dart';
import '../models/task.dart';
import 'local/local_task_source.dart';
import 'remote/firestore_task_source.dart';
import 'sync/sync_service.dart';

/// Single API the UI layer uses for task data. Reads/writes always go to
/// Hive first (so the app works offline); pushing to Firestore is delegated
/// to [SyncService] and never blocks the caller.
class TaskRepository {
  TaskRepository({
    required LocalTaskSource local,
    required FirestoreTaskSource remote,
    required SyncService syncService,
  })  : _local = local,
        _remote = remote,
        _syncService = syncService;

  final LocalTaskSource _local;
  final FirestoreTaskSource _remote;
  final SyncService _syncService;

  List<Task> getAllTasks() => _local.getAll();

  Task? getTask(String id) => _local.getById(id);

  /// Reactive task list, driven purely by the local Hive box.
  Stream<List<Task>> watchTasks() async* {
    yield _local.getAll();
    await for (final _ in _local.watch()) {
      yield _local.getAll();
    }
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required Priority priority,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _remote.newId(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pendingCreate,
    );
    await _local.put(task);
    _pushInBackground();
    return task;
  }

  Future<Task> updateTask(
    Task task, {
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) async {
    final updated = task.copyWith(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpdate,
    );
    await _local.put(updated);
    _pushInBackground();
    return updated;
  }

  Future<void> toggleCompleted(Task task) => updateTask(task, isCompleted: !task.isCompleted);

  Future<void> deleteTask(Task task) async {
    if (task.syncStatus == SyncStatus.pendingCreate) {
      // Never left Firestore in the first place; safe to drop locally.
      await _local.delete(task.id);
      return;
    }
    await _local.put(task.copyWith(syncStatus: SyncStatus.pendingDelete));
    _pushInBackground();
  }

  void _pushInBackground() {
    // Fire-and-forget: local write already happened, so the UI isn't
    // blocked on network. SyncService swallows/retries its own failures.
    unawaited(_syncService.syncNow());
  }
}
