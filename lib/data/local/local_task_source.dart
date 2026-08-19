import 'package:hive/hive.dart';

import '../../models/task.dart';

/// Thin wrapper around a per-user Hive [Box]; the single source of truth
/// the UI reads from. All reads/writes are local and synchronous-ish.
class LocalTaskSource {
  LocalTaskSource(this._box);

  final Box<Task> _box;

  List<Task> getAll() => _box.values.toList();

  Task? getById(String id) => _box.get(id);

  Future<void> put(Task task) => _box.put(task.id, task);

  Future<void> putAll(Iterable<Task> tasks) =>
      _box.putAll({for (final t in tasks) t.id: t});

  Future<void> delete(String id) => _box.delete(id);

  /// Fires on every put/delete so the UI can stay reactive off Hive alone.
  Stream<BoxEvent> watch() => _box.watch();

  Future<void> close() => _box.close();
}
