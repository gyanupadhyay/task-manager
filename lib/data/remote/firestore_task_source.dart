import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/task.dart';

/// Talks to `users/{uid}/tasks`. Never touched directly by the UI —
/// only [TaskRepository]/[SyncService] use this.
class FirestoreTaskSource {
  FirestoreTaskSource(FirebaseFirestore firestore, String uid)
      : _collection = firestore.collection('users').doc(uid).collection('tasks');

  final CollectionReference<Map<String, dynamic>> _collection;

  /// Client-generated id; works fully offline (no network round-trip).
  String newId() => _collection.doc().id;

  Future<void> upsert(Task task) =>
      _collection.doc(task.id).set(task.toFirestore(), SetOptions(merge: true));

  Future<void> delete(String id) => _collection.doc(id).delete();

  Future<List<Task>> fetchAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((d) => Task.fromFirestore(d.id, d.data())).toList();
  }

  /// Live updates while online; merged into the local cache by [SyncService].
  Stream<List<Task>> watchAll() {
    return _collection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((d) => Task.fromFirestore(d.id, d.data())).toList(),
        );
  }
}
