import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../../data/task_repository.dart';
import '../../../../models/priority.dart';
import '../../../../models/task.dart';

part 'task_form_state.dart';

/// Title/description stay in the screen's own TextEditingControllers (to
/// avoid rebuild/cursor fights); this cubit owns priority, due date,
/// validation, and submission — the pieces that are actual business logic.
class TaskFormCubit extends Cubit<TaskFormState> {
  TaskFormCubit({required TaskRepository repository, Task? initial})
      : _repository = repository,
        _editingTask = initial,
        super(TaskFormState(
          priority: initial?.priority ?? Priority.medium,
          dueDate: initial?.dueDate,
        ));

  final TaskRepository _repository;
  final Task? _editingTask;

  bool get isEditing => _editingTask != null;

  void priorityChanged(Priority value) => emit(state.copyWith(priority: value));

  void dueDateChanged(DateTime value) => emit(state.copyWith(dueDate: value, dueDateError: null));

  Future<void> submit({required String title, required String description}) async {
    final titleError = Validators.title(title);
    final descriptionError = Validators.description(description);
    final dueDateError = Validators.dueDate(state.dueDate);
    if (titleError != null || descriptionError != null || dueDateError != null) {
      emit(state.copyWith(
        titleError: titleError,
        descriptionError: descriptionError,
        dueDateError: dueDateError,
      ));
      return;
    }

    emit(state.copyWith(status: TaskFormStatus.submitting));
    try {
      final Task result;
      final editingTask = _editingTask;
      if (editingTask != null) {
        result = await _repository.updateTask(
          editingTask,
          title: title.trim(),
          description: description.trim(),
          priority: state.priority,
          dueDate: state.dueDate,
        );
      } else {
        result = await _repository.createTask(
          title: title.trim(),
          description: description.trim(),
          priority: state.priority,
          dueDate: state.dueDate!,
        );
      }
      emit(state.copyWith(status: TaskFormStatus.success, result: result));
    } catch (_) {
      emit(state.copyWith(status: TaskFormStatus.failure));
    }
  }
}
