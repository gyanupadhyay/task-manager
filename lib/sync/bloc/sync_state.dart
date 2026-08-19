part of 'sync_cubit.dart';

enum SyncPhase { idle, syncing, error }

class SyncState extends Equatable {
  const SyncState({
    required this.isOnline,
    required this.phase,
    required this.pendingCount,
  });

  const SyncState.initial()
      : isOnline = false,
        phase = SyncPhase.idle,
        pendingCount = 0;

  final bool isOnline;
  final SyncPhase phase;
  final int pendingCount;

  SyncState copyWith({bool? isOnline, SyncPhase? phase, int? pendingCount}) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      phase: phase ?? this.phase,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [isOnline, phase, pendingCount];
}
