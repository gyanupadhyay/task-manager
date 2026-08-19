import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/task.dart';

part 'task_filter_state.dart';

/// Purely local search/filter/sort — never triggers a Firestore request.
class TaskFilterCubit extends Cubit<TaskFilterState> {
  TaskFilterCubit() : super(const TaskFilterState());

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  void statusChanged(TaskStatusFilter filter) => emit(state.copyWith(statusFilter: filter));

  void sortChanged(TaskSortMode mode) => emit(state.copyWith(sortMode: mode));

  List<Task> apply(List<Task> tasks) {
    final query = state.searchQuery.trim().toLowerCase();
    final filtered = tasks.where((task) {
      final matchesQuery = query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesStatus = switch (state.statusFilter) {
        TaskStatusFilter.all => true,
        TaskStatusFilter.completed => task.isCompleted,
        TaskStatusFilter.pending => !task.isCompleted,
      };
      return matchesQuery && matchesStatus;
    }).toList();

    filtered.sort((a, b) => switch (state.sortMode) {
          TaskSortMode.dueDate => a.dueDate.compareTo(b.dueDate),
          TaskSortMode.priority => b.priority.index.compareTo(a.priority.index),
        });
    return filtered;
  }
}
