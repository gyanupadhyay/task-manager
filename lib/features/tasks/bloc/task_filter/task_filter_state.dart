part of 'task_filter_cubit.dart';

enum TaskStatusFilter { all, completed, pending }

enum TaskSortMode { dueDate, priority }

class TaskFilterState extends Equatable {
  const TaskFilterState({
    this.searchQuery = '',
    this.statusFilter = TaskStatusFilter.all,
    this.sortMode = TaskSortMode.dueDate,
  });

  final String searchQuery;
  final TaskStatusFilter statusFilter;
  final TaskSortMode sortMode;

  TaskFilterState copyWith({
    String? searchQuery,
    TaskStatusFilter? statusFilter,
    TaskSortMode? sortMode,
  }) {
    return TaskFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      sortMode: sortMode ?? this.sortMode,
    );
  }

  @override
  List<Object?> get props => [searchQuery, statusFilter, sortMode];
}
