/// Local-only bookkeeping for offline-first sync; never persisted to Firestore.
enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete;

  bool get isPending => this != SyncStatus.synced;
}
