import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum Priority {
  low,
  medium,
  high;

  String get label => switch (this) {
        Priority.low => 'Low',
        Priority.medium => 'Medium',
        Priority.high => 'High',
      };

  Color get color => switch (this) {
        Priority.low => AppColors.success,
        Priority.medium => AppColors.warning,
        Priority.high => AppColors.danger,
      };

  static Priority fromName(String name) {
    return Priority.values.firstWhere(
      (p) => p.name == name,
      orElse: () => Priority.medium,
    );
  }
}
