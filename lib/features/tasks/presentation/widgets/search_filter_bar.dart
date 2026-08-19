import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
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
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  final isActive = state.sortMode != TaskSortMode.dueDate;
                  return PopupMenuButton<TaskSortMode>(
                    tooltip: AppStrings.sortLabel,
                    initialValue: state.sortMode,
                    onSelected: context.read<TaskFilterCubit>().sortChanged,
                    color: theme.cardTheme.color,
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isDark ? AppColors.darkOutline : AppColors.lightOutline),
                    ),
                    offset: const Offset(0, 44),
                    itemBuilder: (context) => [
                      _SortMenuItem(
                        value: TaskSortMode.dueDate,
                        icon: Icons.event_outlined,
                        label: AppStrings.sortByDueDate,
                        selected: state.sortMode == TaskSortMode.dueDate,
                      ),
                      _SortMenuItem(
                        value: TaskSortMode.priority,
                        icon: Icons.flag_outlined,
                        label: AppStrings.sortByPriority,
                        selected: state.sortMode == TaskSortMode.priority,
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary.withValues(alpha: 0.12) : null,
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : (isDark ? AppColors.darkOutline : AppColors.lightOutline),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.sort_rounded,
                        size: 18,
                        color: isActive ? AppColors.primary : null,
                      ),
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

class _SortMenuItem extends PopupMenuItem<TaskSortMode> {
  _SortMenuItem({
    required TaskSortMode value,
    required IconData icon,
    required String label,
    required bool selected,
  }) : super(
          value: value,
          height: 44,
          child: Row(
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.primary : null),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : null,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (selected) const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
            ],
          ),
        );
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
