import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/priority.dart';
import 'package:task_manager/models/sync_status.dart';
import 'package:task_manager/models/task.dart';

void main() {
  final task = Task(
    id: 'task-1',
    title: 'Write report',
    description: 'Quarterly summary',
    priority: Priority.high,
    dueDate: DateTime(2026, 9, 1),
    isCompleted: false,
    createdAt: DateTime(2026, 8, 1, 10, 30),
    updatedAt: DateTime(2026, 8, 2, 9),
    syncStatus: SyncStatus.pendingUpdate,
  );

  test('toJson/fromJson round-trips every field', () {
    final restored = Task.fromJson(task.toJson());
    expect(restored, task);
  });

  test('toFirestore omits id and syncStatus', () {
    final data = task.toFirestore();
    expect(data.containsKey('id'), isFalse);
    expect(data.containsKey('syncStatus'), isFalse);
    expect(data['title'], task.title);
  });

  test('fromFirestore defaults syncStatus to synced', () {
    final restored = Task.fromFirestore(task.id, task.toFirestore());
    expect(restored.syncStatus, SyncStatus.synced);
    expect(restored.title, task.title);
    expect(restored.dueDate, task.dueDate);
  });

  test('copyWith only changes provided fields', () {
    final updated = task.copyWith(isCompleted: true);
    expect(updated.isCompleted, isTrue);
    expect(updated.title, task.title);
    expect(updated.id, task.id);
  });
}
