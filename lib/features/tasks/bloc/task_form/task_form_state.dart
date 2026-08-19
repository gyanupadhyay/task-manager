part of 'task_form_cubit.dart';

enum TaskFormStatus { initial, submitting, success, failure }

const _unset = Object();

class TaskFormState extends Equatable {
  const TaskFormState({
    required this.priority,
    required this.dueDate,
    this.titleError,
    this.descriptionError,
    this.dueDateError,
    this.status = TaskFormStatus.initial,
    this.result,
  });

  final Priority priority;
  final DateTime? dueDate;
  final String? titleError;
  final String? descriptionError;
  final String? dueDateError;
  final TaskFormStatus status;
  final Task? result;

  TaskFormState copyWith({
    Priority? priority,
    Object? dueDate = _unset,
    Object? titleError = _unset,
    Object? descriptionError = _unset,
    Object? dueDateError = _unset,
    TaskFormStatus? status,
    Object? result = _unset,
  }) {
    return TaskFormState(
      priority: priority ?? this.priority,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      titleError: identical(titleError, _unset) ? this.titleError : titleError as String?,
      descriptionError:
          identical(descriptionError, _unset) ? this.descriptionError : descriptionError as String?,
      dueDateError: identical(dueDateError, _unset) ? this.dueDateError : dueDateError as String?,
      status: status ?? this.status,
      result: identical(result, _unset) ? this.result : result as Task?,
    );
  }

  @override
  List<Object?> get props =>
      [priority, dueDate, titleError, descriptionError, dueDateError, status, result];
}
