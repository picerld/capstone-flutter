// lib/provider/sleep_provider.dart

import 'package:flutter/material.dart';
import 'package:capstone/data/local/sleep_storage_service.dart';
import 'package:capstone/data/models/sleep_record.dart';

class SleepProvider extends ChangeNotifier {
  final SleepStorageService _storageService = SleepStorageService.instance;

  TimeOfDay? _jamTidur;
  TimeOfDay? _jamBangun;
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  double _weeklyAverageDuration = 0; // in minutes
  bool _isLoading = false;

  TimeOfDay? get jamTidur => _jamTidur;
  TimeOfDay? get jamBangun => _jamBangun;
  SleepRecord? get todayRecord => _todayRecord;
  List<SleepRecord> get weeklyRecords => List.unmodifiable(_weeklyRecords);
  double get weeklyAverageDuration => _weeklyAverageDuration;
  bool get isLoading => _isLoading;

  SleepProvider() {
    // Optionally: load data on provider creation
    // loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now();
      final record = await _storageService.readRecordByDate(today);
      final weekly = await _storageService.readWeeklyRecords();
      final avgDuration = await _storageService.getWeeklyAverageDuration();

      _todayRecord = record;
      _weeklyRecords = weekly;
      _weeklyAverageDuration = avgDuration;

      // If there's a saved record for today, parse its times into TimeOfDay
      if (_todayRecord != null) {
        final partsSleep = _todayRecord!.sleepTime.split(':');
        final partsWake = _todayRecord!.wakeTime.split(':');

        try {
          _jamTidur = TimeOfDay(
            hour: int.parse(partsSleep[0]),
            minute: int.parse(partsSleep[1]),
          );
          _jamBangun = TimeOfDay(
            hour: int.parse(partsWake[0]),
            minute: int.parse(partsWake[1]),
          );
        } catch (e) {
          // If parsing fails, just null them out
          _jamTidur = null;
          _jamBangun = null;
        }
      } else {
        // No saved record for today, keep jamTidur/jamBangun as-is
        // (they might be set in-memory by UI)
      }
    } catch (e) {
      debugPrint('SleepProvider.loadData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setJamTidur(TimeOfDay time) async {
    _jamTidur = time;
    notifyListeners();

    // If both times present, persist record
    if (_jamBangun != null) {
      await _saveOrUpdateTodayRecord();
    }
  }

  Future<void> setJamBangun(TimeOfDay time) async {
    _jamBangun = time;
    notifyListeners();

    // If both times present, persist record
    if (_jamTidur != null) {
      await _saveOrUpdateTodayRecord();
    }
  }

  /// Calculates sleep duration (Duration) using current jamTidur and jamBangun.
  /// Returns null if either time is missing.
  Duration? calculateDuration() {
    if (_jamTidur == null || _jamBangun == null) return null;

    final sleepMinutes =
        (_jamBangun!.hour * 60 + _jamBangun!.minute) -
        (_jamTidur!.hour * 60 + _jamTidur!.minute);

    final minutes = sleepMinutes >= 0 ? sleepMinutes : sleepMinutes + 24 * 60;
    return Duration(minutes: minutes);
  }

  /// Returns [0.0 .. 1.0] quality score based on duration heuristics.
  /// Uses the same logic you had earlier.
  double calculateQuality() {
    final duration = calculateDuration();
    if (duration == null) return 0.0;

    final hours = duration.inMinutes / 60.0;

    if (hours >= 7 && hours <= 9) {
      return 0.95;
    } else if (hours >= 6 && hours < 7) {
      return 0.75 + ((hours - 6) * 0.20);
    } else if (hours > 9 && hours <= 10) {
      return 0.95 - ((hours - 9) * 0.15);
    } else if (hours >= 5 && hours < 6) {
      return 0.60 + ((hours - 5) * 0.15);
    } else if (hours < 5) {
      // floor at 0.30 or scaled
      return (0.30 > hours * 0.12) ? 0.30 : hours * 0.12;
    } else {
      // hours > 10
      return (0.50 > 0.80 - ((hours - 10) * 0.10))
          ? 0.50
          : 0.80 - ((hours - 10) * 0.10);
    }
  }

  /// Internal helper to create and persist today's SleepRecord, or update existing one.
  Future<bool> _saveOrUpdateTodayRecord() async {
    if (_jamTidur == null || _jamBangun == null) return false;

    final duration = calculateDuration();
    if (duration == null) return false;

    final quality = calculateQuality();

    // Turn TimeOfDay into "HH:mm" strings
    final sleepStr =
        '${_jamTidur!.hour.toString().padLeft(2, '0')}:${_jamTidur!.minute.toString().padLeft(2, '0')}';
    final wakeStr =
        '${_jamBangun!.hour.toString().padLeft(2, '0')}:${_jamBangun!.minute.toString().padLeft(2, '0')}';

    final newRecord = SleepRecord(
      id: _todayRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sleepTime: sleepStr,
      wakeTime: wakeStr,
      durationMinutes: duration.inMinutes,
      quality: quality,
      date: DateTime.now(),
    );

    try {
      await _storageService.save(newRecord);

      // reload data from storage to keep weeklyRecords/averages consistent
      await loadData();

      return true;
    } catch (e) {
      debugPrint('Error saving today record: $e');
      return false;
    }
  }

  /// Delete a record by id (returns true on success)
  Future<bool> deleteRecord(String id) async {
    try {
      final result = await _storageService.delete(id);
      if (result) {
        await loadData();
      }
      return result;
    } catch (e) {
      debugPrint('Error deleting record: $e');
      return false;
    }
  }

  /// Clear all stored sleep data
  Future<bool> clearAllData() async {
    try {
      final result = await _storageService.deleteAll();
      if (result) {
        _jamTidur = null;
        _jamBangun = null;
        _todayRecord = null;
        _weeklyRecords = [];
        _weeklyAverageDuration = 0;
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }

  /// Convenience method: force refresh from storage (alias)
  Future<void> refresh() async {
    await loadData();
  }

  /// Get a human-readable duration string for UI (e.g. "7h 15m")
  static String formatDurationHuman(Duration? dur) {
    if (dur == null) return '--';
    final h = dur.inHours;
    final m = dur.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  /// Get TimeOfDay formatted like "HH:mm" for display
  static String formatTimeOfDay(TimeOfDay? t) {
    if (t == null) return '--:--';
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
