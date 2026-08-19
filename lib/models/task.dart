import 'package:cloud_firestore/cloud_firestore.dart';

import 'priority.dart';
import 'sync_status.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Local-only: tracks what still needs to be pushed to Firestore.
  final SyncStatus syncStatus;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Generic JSON round-trip (id is part of the payload). Used by local
  /// serialization and tests; [dueDate]/[createdAt]/[updatedAt] are ISO-8601.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: Priority.fromName(json['priority'] as String? ?? 'medium'),
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == (json['syncStatus'] as String? ?? 'synced'),
        orElse: () => SyncStatus.synced,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus.name,
    };
  }

  /// Firestore document body — no [id] (it's the document key) and no
  /// [syncStatus] (local-only bookkeeping never written remotely).
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priority: Priority.fromName(data['priority'] as String? ?? 'medium'),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: SyncStatus.synced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          priority == other.priority &&
          dueDate == other.dueDate &&
          isCompleted == other.isCompleted &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus);

  @override
  int get hashCode => Object.hash(id, title, description, priority, dueDate,
      isCompleted, createdAt, updatedAt, syncStatus);
}
