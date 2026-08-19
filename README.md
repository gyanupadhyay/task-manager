# Task Manager

An offline-first Flutter task manager backed by Cloud Firestore, with Hive as the local cache. Every create/edit/delete/complete lands in Hive first — the app is fully usable with no network — and syncs to Firestore in the background whenever connectivity is available, with automatic last-write-wins reconciliation on reconnect.

## Features

- **Tasks:** create, edit, delete, mark complete/pending, view details. Each task has an id, title, description, priority (low/medium/high), due date, completion status, and created date.
- **Search & filter:** search by title, filter by All/Pending/Completed, sort by due date or priority — all computed locally, no Firestore reads on every keystroke.
- **Offline-first sync:** local-write-first data flow, a pending-sync queue, and a live sync indicator (offline / syncing / N pending / synced).
- **Auth:** Google Sign-In via Firebase Auth, scoping each user's tasks to `users/{uid}/tasks` with matching Firestore security rules.
- **Dark mode:** full light/dark theming, following the system setting.
- **Tests:** unit tests for the `Task` model's JSON/Firestore round-trip and the offline-sync merge rules.

## Stack

- **State management:** flutter_bloc (Bloc/Cubit) — business logic lives in blocs/cubits/repository, not widgets
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
4. This repo also does not include OneSignal config (project-specific and gitignored, for the same reason). Copy the template and fill in your own values:
   ```
   cp lib/core/notifications/onesignal_config.example.dart lib/core/notifications/onesignal_config.dart
   ```
   - Create a free app at [onesignal.com](https://onesignal.com), platform **Google Android (FCM)**.
   - In the Firebase console for the same project: Project settings > Service accounts > **Generate new private key**, and upload that JSON to OneSignal when it asks for Android/Firebase credentials.
   - Copy the **App ID** and **REST API Key** from OneSignal's Settings > Keys & IDs into `onesignal_config.dart`.
5. Run:
   ```
   flutter run
   ```

Android is the actively developed/tested target. iOS needs `flutterfire configure` rerun from macOS (it wires up Xcode-side config that isn't available cross-platform).

## Testing

```
flutter analyze
flutter test
```

Unit tests cover the `Task` model's JSON/Firestore round-trip and the offline-sync last-write-wins merge rules (`RemoteSnapshotMerger`).

## Status

Core spec: complete. Bonus: Firebase Auth, dark mode, and unit tests are done; advanced offline sync (LWW merge + pending queue) is in place.

**Due-date reminders: OneSignal, scheduled directly from the client.** Creating or editing a task with a due date calls OneSignal's REST API to schedule a push 30 minutes before it's due, targeted at the signed-in user's Firebase uid (`OneSignal.login`); completing, deleting, or rescheduling a task cancels/replaces it (`ReminderService`, `ReminderIdStore`). There's no backend — OneSignal itself holds and delivers the notification server-side at the scheduled time, which is what makes this reliable where the earlier approach wasn't: an on-device scheduled-alarm implementation was tried first and dropped, since several Android OEM skins (ColorOS, MIUI, etc.) kill background alarm receivers before they can post the notification, regardless of permissions granted. The tradeoff is that the OneSignal REST API key is embedded client-side (no server to hold it server-side instead), so it's extractable from the built APK; rotate it in the OneSignal dashboard if that's ever abused.
