import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../data/task_repository.dart';
import '../../../../models/priority.dart';
import '../../../../models/task.dart';
import '../../bloc/task_form/task_form_cubit.dart';
import '../widgets/priority_badge.dart';

class AddEditTaskScreen extends StatelessWidget {
  const AddEditTaskScreen({super.key, this.initial});

  final Task? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskFormCubit(repository: getIt<TaskRepository>(), initial: initial),
      child: _AddEditTaskView(initial: initial),
    );
  }
}

class _AddEditTaskView extends StatefulWidget {
  const _AddEditTaskView({this.initial});

  final Task? initial;

  @override
  State<_AddEditTaskView> createState() => _AddEditTaskViewState();
}

class _AddEditTaskViewState extends State<_AddEditTaskView> {
  late final _titleController = TextEditingController(text: widget.initial?.title ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.initial?.description ?? '');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTaskTitle : AppStrings.addTaskTitle),
      ),
      body: BlocListener<TaskFormCubit, TaskFormState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == TaskFormStatus.success) {
            Navigator.of(context).pop(state.result);
          } else if (state.status == TaskFormStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text(AppStrings.errorTitle)));
          }
        },
        child: BlocBuilder<TaskFormCubit, TaskFormState>(
          builder: (context, state) {
            final cubit = context.read<TaskFormCubit>();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldTitle,
                    errorText: state.titleError,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldDescription,
                    errorText: state.descriptionError,
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 20),
                Text(AppStrings.fieldPriority, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: Priority.values.map((priority) {
                    final selected = state.priority == priority;
                    return GestureDetector(
                      onTap: () => cubit.priorityChanged(priority),
                      child: Opacity(
                        opacity: selected ? 1 : 0.45,
                        child: PriorityBadge(priority: priority),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(AppStrings.fieldDueDate, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.dueDate ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null) cubit.dueDateChanged(picked);
                  },
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    state.dueDate == null ? AppStrings.fieldDueDate : DateFormatting.date(state.dueDate!),
                  ),
                ),
                if (state.dueDateError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.dueDateError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: state.status == TaskFormStatus.submitting
                      ? null
                      : () => cubit.submit(
                            title: _titleController.text,
                            description: _descriptionController.text,
                          ),
                  child: state.status == TaskFormStatus.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.save),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
