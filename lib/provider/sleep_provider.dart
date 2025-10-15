import 'package:capstone/data/local/sleep_storage_service.dart';
import 'package:capstone/data/models/sleep_record.dart';
import 'package:flutter/material.dart';

class SleepProvider extends ChangeNotifier {
  final SleepStorageService _storageService = SleepStorageService.instance;

  TimeOfDay? _jamTidur;
  TimeOfDay? _jamBangun;
  int _stressLevel = 3;
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  double _weeklyAverageDuration = 0;
  bool _isLoading = false;

  TimeOfDay? get jamTidur => _jamTidur;
  TimeOfDay? get jamBangun => _jamBangun;
  int get stressLevel => _stressLevel;
  SleepRecord? get todayRecord => _todayRecord;
  List<SleepRecord> get weeklyRecords => _weeklyRecords;
  double get weeklyAverageDuration => _weeklyAverageDuration;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now();
      final record = await _storageService.readRecordByDate(today);
      _todayRecord = record;

      if (record != null) {
        final sleepParts = record.sleepTime.split(':');
        final wakeParts = record.wakeTime.split(':');
        _jamTidur = TimeOfDay(
            hour: int.parse(sleepParts[0]), minute: int.parse(sleepParts[1]));
        _jamBangun = TimeOfDay(
            hour: int.parse(wakeParts[0]), minute: int.parse(wakeParts[1]));
        _stressLevel = record.stressLevel;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setJamTidur(TimeOfDay time) {
    _jamTidur = time;
    if (_jamBangun != null) saveSleepRecord();
    notifyListeners();
  }

  void setJamBangun(TimeOfDay time) {
    _jamBangun = time;
    if (_jamTidur != null) saveSleepRecord();
    notifyListeners();
  }


  void setStressLevel(int level) {
    _stressLevel = level;
    if (_jamTidur != null && _jamBangun != null) saveSleepRecord();
    notifyListeners();
  }

  Duration? calculateDuration() {
    if (_jamTidur == null || _jamBangun == null) return null;
    final sleepDateTime =
    DateTime(2023, 1, 1, _jamTidur!.hour, _jamTidur!.minute);
    final wakeDateTime =
    DateTime(2023, 1, 1, _jamBangun!.hour, _jamBangun!.minute);

    if (wakeDateTime.isBefore(sleepDateTime)) {
      return wakeDateTime
          .add(const Duration(days: 1))
          .difference(sleepDateTime);
    }
    return wakeDateTime.difference(sleepDateTime);
  }

  double calculateQuality() {
    final duration = calculateDuration();
    if (duration == null) return 0.0;

    final hours = duration.inMinutes / 60;
    double quality;

    if (hours >= 7 && hours <= 9) {
      quality = 0.95;
    } else if (hours >= 6 && hours < 7) {
      quality = 0.75 + ((hours - 6) * 0.20);
    } else if (hours > 9 && hours <= 10) {
      quality = 0.95 - ((hours - 9) * 0.15);
    } else if (hours >= 5 && hours < 6) {
      quality = 0.60 + ((hours - 5) * 0.15);
    } else if (hours < 5) {
      quality = (0.30 > hours * 0.12) ? 0.30 : hours * 0.12;
    } else {
      quality = (0.50 > 0.80 - ((hours - 10) * 0.10))
          ? 0.50
          : 0.80 - ((hours - 10) * 0.10);
    }


    quality -= (_stressLevel - 3) * 0.05;
    return quality.clamp(0.0, 1.0);
  }

  Future<void> saveSleepRecord() async {
    if (_jamTidur == null || _jamBangun == null) return;

    final duration = calculateDuration();
    if (duration == null) return;

    final quality = calculateQuality();

    final record = SleepRecord(
      id: _todayRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sleepTime:
      '${_jamTidur!.hour.toString().padLeft(2, '0')}:${_jamTidur!.minute.toString().padLeft(2, '0')}',
      wakeTime:
      '${_jamBangun!.hour.toString().padLeft(2, '0')}:${_jamBangun!.minute.toString().padLeft(2, '0')}',
      durationMinutes: duration.inMinutes,
      quality: quality,
      stressLevel: _stressLevel,
      date: DateTime.now(),
    );

    await _storageService.save(record);
    _todayRecord = record;
    notifyListeners();
  }
}
