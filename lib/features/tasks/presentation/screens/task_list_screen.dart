import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../bloc/task_filter/task_filter_cubit.dart';
import '../../bloc/task_list/task_list_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tasksTitle),
        actions: [
          const SyncStatusIndicator(),
          IconButton(
            tooltip: AppStrings.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          Expanded(
            child: BlocBuilder<TaskListBloc, TaskListState>(
              builder: (context, listState) {
                if (listState is TaskListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (listState is TaskListError) {
                  return ErrorState(
                    message: listState.message,
                    onRetry: () => context
                        .read<TaskListBloc>()
                        .add(const TaskListSubscriptionRequested()),
                  );
                }

                final tasks = (listState as TaskListLoaded).tasks;
                return BlocBuilder<TaskFilterCubit, TaskFilterState>(
                  builder: (context, filterState) {
                    final filterCubit = context.read<TaskFilterCubit>();
                    final visibleTasks = filterCubit.apply(tasks);

                    if (tasks.isEmpty) {
                      return const EmptyState(
                        icon: Icons.checklist_rounded,
                        title: AppStrings.emptyTitle,
                        subtitle: AppStrings.emptySubtitle,
                      );
                    }
                    if (visibleTasks.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: AppStrings.emptyFilteredTitle,
                        subtitle: AppStrings.emptyFilteredSubtitle,
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: visibleTasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = visibleTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => context.push('/tasks/${task.id}'),
                          onToggle: () =>
                              context.read<TaskListBloc>().add(TaskToggleRequested(task)),
                          onDismissed: () =>
                              context.read<TaskListBloc>().add(TaskDeleteRequested(task)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
