part of 'task_list_bloc.dart';

sealed class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

final class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

final class TaskListLoaded extends TaskListState {
  const TaskListLoaded(this.tasks);

  final List<Task> tasks;

  @override
  List<Object?> get props => [tasks];
}

final class TaskListError extends TaskListState {
  const TaskListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
