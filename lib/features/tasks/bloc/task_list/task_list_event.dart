part of 'task_list_bloc.dart';

sealed class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

final class TaskListSubscriptionRequested extends TaskListEvent {
  const TaskListSubscriptionRequested();
}

final class TaskToggleRequested extends TaskListEvent {
  const TaskToggleRequested(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskDeleteRequested extends TaskListEvent {
  const TaskDeleteRequested(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}
