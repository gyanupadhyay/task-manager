# Task Manager

A Flutter task manager with Firebase Cloud Firestore as the remote data source and Hive as an offline-first local cache. Tasks are created/edited/deleted locally first (so the app is always usable, online or not) and synced to Firestore in the background whenever connectivity is available.

## Stack

- **State management:** flutter_bloc (Bloc/Cubit)
- **DI:** get_it, with a get_it *scope* for everything that depends on the signed-in user's uid — pushed on sign-in, popped on sign-out
- **Navigation:** go_router, auth-gated via a redirect driven by `AuthBloc`
- **Local storage:** Hive, with a hand-written `TypeAdapter` (no build_runner/codegen)
- **Remote:** Cloud Firestore (`users/{uid}/tasks/{taskId}`), Firebase Auth (Google Sign-In)
- **Connectivity:** connectivity_plus (interface-level changes) + internet_connection_checker_plus (actual reachability probe)
- **HTTP:** Dio, configured as a general-purpose client (not currently used — Firestore/Auth go through their own SDKs)

## Architecture

```
lib/
  core/        theme, centralized strings, DI setup, validators, Dio client
  models/      Task, Priority — fromJson/toJson, toFirestore/fromFirestore
  data/        LocalTaskSource (Hive), FirestoreTaskSource, SyncService, TaskRepository
  sync/        SyncCubit — drives the sync indicator off connectivity + Hive watch
  auth/        AuthRepository, AuthBloc, sign-in screen
  features/    task list/add-edit/detail screens + their blocs
  routing/     go_router config
```

The UI never talks to Firestore or Hive directly — everything goes through `TaskRepository`, which writes to Hive first and pushes to Firestore in the background. A local-only `syncStatus` field tracks what's still owed to Firestore; a last-write-wins merge (`RemoteSnapshotMerger`) reconciles local and remote state on every sync.

## Setup

1. Install dependencies:
   ```
   flutter pub get
   ```
2. This repo does **not** include Firebase config (it's project-specific and gitignored). Create your own Firebase project and generate it:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and the platform config files.
3. In the Firebase console for your project:
   - Enable **Cloud Firestore** (native mode).
   - Enable **Google** as an Authentication sign-in provider.
   - Deploy the included security rules: `firebase deploy --only firestore:rules`.
   - For Android, add your debug/release SHA-1 fingerprints to the Firebase project (required for Google Sign-In) and re-download `google-services.json`.
4. Run:
   ```
   flutter run
   ```

## Testing

```
flutter analyze
flutter test
```

Unit tests cover the `Task` model's JSON/Firestore round-trip and the offline-sync last-write-wins merge rules (`RemoteSnapshotMerger`).
