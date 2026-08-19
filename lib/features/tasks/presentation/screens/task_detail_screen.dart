import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../models/task.dart';
import '../../bloc/task_list/task_list_bloc.dart';
import '../widgets/priority_badge.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.detailTitle)),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          final tasks = state is TaskListLoaded ? state.tasks : const <Task>[];
          Task? task;
          for (final t in tasks) {
            if (t.id == taskId) {
              task = t;
              break;
            }
          }
          if (task == null) {
            return const SizedBox.shrink();
          }
          return _TaskDetailBody(task: task);
        },
      ),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            PriorityBadge(priority: task.priority),
          ],
        ),
        const SizedBox(height: 16),
        if (task.description.isNotEmpty) ...[
          Text(task.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
        ],
        _DetailRow(label: AppStrings.status, value: task.isCompleted ? AppStrings.statusCompleted : AppStrings.statusPending),
        _DetailRow(label: AppStrings.due, value: DateFormatting.date(task.dueDate)),
        _DetailRow(label: AppStrings.created, value: DateFormatting.dateTime(task.createdAt)),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context
              .read<TaskListBloc>()
              .add(TaskToggleRequested(task)),
          icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
          label: Text(task.isCompleted ? AppStrings.markPending : AppStrings.markComplete),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/tasks/${task.id}/edit', extra: task),
          icon: const Icon(Icons.edit_outlined),
          label: const Text(AppStrings.edit),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _confirmDelete(context),
          style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
          icon: const Icon(Icons.delete_outline),
          label: const Text(AppStrings.delete),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTaskTitle),
        content: const Text(AppStrings.deleteTaskBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<TaskListBloc>().add(TaskDeleteRequested(task));
      context.pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: theme.textTheme.bodySmall)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
