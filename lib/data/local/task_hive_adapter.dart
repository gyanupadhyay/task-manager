import 'package:hive/hive.dart';

import '../../models/priority.dart';
import '../../models/sync_status.dart';
import '../../models/task.dart';

/// Hand-written TypeAdapter (no build_runner) so the Hive schema is explicit
/// and doesn't depend on codegen tooling.
class TaskHiveAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      priority: Priority.values[fields[3] as int],
      dueDate: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      isCompleted: fields[5] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      syncStatus: SyncStatus.values[fields[8] as int],
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priority.index)
      ..writeByte(4)
      ..write(obj.dueDate.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.updatedAt.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.syncStatus.index);
  }
}
