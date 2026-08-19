import '../constants/app_strings.dart';

abstract final class Validators {
  static String? title(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.titleRequired;
    if (trimmed.length > 120) return AppStrings.titleTooLong;
    return null;
  }

  static String? description(String? value) {
    if ((value ?? '').length > 2000) return AppStrings.descriptionTooLong;
    return null;
  }

  static String? dueDate(DateTime? value) {
    if (value == null) return AppStrings.dueDateRequired;
    return null;
  }
}
