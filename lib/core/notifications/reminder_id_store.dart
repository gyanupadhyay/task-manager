import 'package:hive/hive.dart';

/// Maps a task id to the OneSignal message id scheduled for its due-date
/// reminder, so the reminder can be canceled or rescheduled later.
/// Local-only bookkeeping — never synced to Firestore.
class ReminderIdStore {
  ReminderIdStore(this._box);

  final Box<String> _box;

  Future<void> put(String taskId, String messageId) => _box.put(taskId, messageId);

  /// Removes and returns the stored id, if any.
  Future<String?> take(String taskId) async {
    final id = _box.get(taskId);
    if (id != null) await _box.delete(taskId);
    return id;
  }
}
