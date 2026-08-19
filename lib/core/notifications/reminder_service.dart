import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/task.dart';
import 'onesignal_config.dart';
import 'reminder_id_store.dart';

/// Schedules/cancels a due-date reminder by calling OneSignal's REST API
/// directly from the client — there's no backend to hold the schedule.
/// OneSignal holds and delivers the notification server-side at the
/// requested time, so delivery doesn't depend on the device's own alarm
/// scheduler (which is what made the previous on-device reminders
/// unreliable on OEM Android skins that kill background alarms).
class ReminderService {
  ReminderService({required Dio dio, required ReminderIdStore idStore})
      : _dio = dio,
        _idStore = idStore;

  final Dio _dio;
  final ReminderIdStore _idStore;

  static const _remindBefore = Duration(minutes: 30);
  static const _baseUrl = 'https://api.onesignal.com/notifications';

  /// Cancels any existing reminder for [task] and schedules a new one
  /// [_remindBefore] its due date, targeted at [uid] via OneSignal's
  /// externalId. No-ops if that time has already passed.
  Future<void> scheduleForTask(Task task, {required String uid}) async {
    await cancelForTask(task.id);

    final sendAt = task.dueDate.subtract(_remindBefore);
    if (sendAt.isBefore(DateTime.now())) return;

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(headers: {
          'Authorization': 'Key ${OneSignalConfig.restApiKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          'app_id': OneSignalConfig.appId,
          'target_channel': 'push',
          'include_aliases': {
            'external_id': [uid],
          },
          'send_after': sendAt.toUtc().toIso8601String(),
          'headings': {'en': 'Task due soon'},
          'contents': {'en': task.title},
        },
      );
      final id = response.data['id'] as String?;
      if (id != null) await _idStore.put(task.id, id);
    } catch (e) {
      // Best-effort: a failed reminder shouldn't block saving the task.
      debugPrint('ReminderService: failed to schedule reminder: $e');
    }
  }

  Future<void> cancelForTask(String taskId) async {
    final id = await _idStore.take(taskId);
    if (id == null) return;
    try {
      await _dio.delete(
        '$_baseUrl/$id',
        queryParameters: {'app_id': OneSignalConfig.appId},
        options: Options(headers: {'Authorization': 'Key ${OneSignalConfig.restApiKey}'}),
      );
    } catch (e) {
      debugPrint('ReminderService: failed to cancel reminder: $e');
    }
  }
}
