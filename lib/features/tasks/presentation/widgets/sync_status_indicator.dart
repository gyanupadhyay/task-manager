import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../sync/bloc/sync_cubit.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        final (icon, label, color) = _presentation(state);
        return Tooltip(
          message: label,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.phase == SyncPhase.syncing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: color),
                  )
                else
                  Icon(icon, size: 18, color: color),
                if (state.pendingCount > 0 && state.phase != SyncPhase.syncing) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${state.pendingCount}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  (IconData, String, Color) _presentation(SyncState state) {
    if (!state.isOnline) {
      return (Icons.cloud_off_outlined, AppStrings.offlineLabel, AppColors.lightTextSecondary);
    }
    if (state.phase == SyncPhase.syncing) {
      return (Icons.sync, AppStrings.syncingLabel, AppColors.primary);
    }
    if (state.phase == SyncPhase.error) {
      return (Icons.error_outline, AppStrings.syncErrorLabel, AppColors.danger);
    }
    if (state.pendingCount > 0) {
      return (Icons.cloud_upload_outlined,
          '${state.pendingCount} ${AppStrings.pendingSyncLabel}', AppColors.warning);
    }
    return (Icons.cloud_done_outlined, AppStrings.syncedLabel, AppColors.success);
  }
}
