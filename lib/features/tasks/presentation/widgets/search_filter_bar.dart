import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../bloc/task_filter/task_filter_cubit.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: context.read<TaskFilterCubit>().searchChanged,
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: BlocBuilder<TaskFilterCubit, TaskFilterState>(
                    buildWhen: (previous, current) => previous.statusFilter != current.statusFilter,
                    builder: (context, state) {
                      return Row(
                        children: [
                          _FilterChip(
                            label: AppStrings.filterAll,
                            selected: state.statusFilter == TaskStatusFilter.all,
                            onSelected: () =>
                                context.read<TaskFilterCubit>().statusChanged(TaskStatusFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: AppStrings.filterPending,
                            selected: state.statusFilter == TaskStatusFilter.pending,
                            onSelected: () => context
                                .read<TaskFilterCubit>()
                                .statusChanged(TaskStatusFilter.pending),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: AppStrings.filterCompleted,
                            selected: state.statusFilter == TaskStatusFilter.completed,
                            onSelected: () => context
                                .read<TaskFilterCubit>()
                                .statusChanged(TaskStatusFilter.completed),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<TaskFilterCubit, TaskFilterState>(
                buildWhen: (previous, current) => previous.sortMode != current.sortMode,
                builder: (context, state) {
                  return PopupMenuButton<TaskSortMode>(
                    tooltip: AppStrings.sortLabel,
                    initialValue: state.sortMode,
                    onSelected: context.read<TaskFilterCubit>().sortChanged,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: TaskSortMode.dueDate, child: Text(AppStrings.sortByDueDate)),
                      PopupMenuItem(value: TaskSortMode.priority, child: Text(AppStrings.sortByPriority)),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.sort, size: 18),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
