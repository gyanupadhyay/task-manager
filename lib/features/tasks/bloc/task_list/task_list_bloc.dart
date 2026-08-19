import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/task_repository.dart';
import '../../../../models/task.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  TaskListBloc({required TaskRepository repository})
      : _repository = repository,
        super(const TaskListLoading()) {
    on<TaskListSubscriptionRequested>(_onSubscriptionRequested);
    on<TaskToggleRequested>(_onToggleRequested);
    on<TaskDeleteRequested>(_onDeleteRequested);
  }

  final TaskRepository _repository;

  Future<void> _onSubscriptionRequested(
    TaskListSubscriptionRequested event,
    Emitter<TaskListState> emit,
  ) async {
    await emit.forEach<List<Task>>(
      _repository.watchTasks(),
      onData: (tasks) => TaskListLoaded(tasks),
      onError: (error, stackTrace) => TaskListError(error.toString()),
    );
  }

  Future<void> _onToggleRequested(
    TaskToggleRequested event,
    Emitter<TaskListState> emit,
  ) {
    return _repository.toggleCompleted(event.task);
  }

  Future<void> _onDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskListState> emit,
  ) {
    return _repository.deleteTask(event.task);
  }
}
