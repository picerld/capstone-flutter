import 'package:flutter/material.dart';
import 'package:capstone/data/local/sleep_api_service.dart';
import 'package:capstone/data/local/sleep_storage_service.dart';
import 'package:capstone/data/models/sleep_record.dart';

class SleepProvider extends ChangeNotifier {
  final SleepStorageService _storageService = SleepStorageService.instance;
  final SleepApiService _apiService = SleepApiService.instance;

  TimeOfDay? _jamTidur;
  TimeOfDay? _jamBangun;
  int _stressLevel = 5; // Default 5 for 1-10 scale
  int _qualitySleep = 5; // Default 5 for 1-10 scale
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  double _weeklyAverageDuration = 0;
  bool _isLoading = false;
  bool _isSaving = false;

  TimeOfDay? get jamTidur => _jamTidur;
  TimeOfDay? get jamBangun => _jamBangun;
  int get stressLevel => _stressLevel;
  int get qualitySleep => _qualitySleep;
  SleepRecord? get todayRecord => _todayRecord;
  List<SleepRecord> get weeklyRecords => List.unmodifiable(_weeklyRecords);
  double get weeklyAverageDuration => _weeklyAverageDuration;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  SleepProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final today = DateTime.now();
      _todayRecord = await _storageService.readRecordByDate(today);
      _weeklyRecords = await _storageService.readWeeklyRecords();
      _weeklyAverageDuration = await _storageService.getWeeklyAverageDuration();

      if (_todayRecord != null) {
        final partsSleep = _todayRecord!.sleepTime.split(':');
        final partsWake = _todayRecord!.wakeTime.split(':');
        _jamTidur = TimeOfDay(
          hour: int.parse(partsSleep[0]),
          minute: int.parse(partsSleep[1]),
        );
        _jamBangun = TimeOfDay(
          hour: int.parse(partsWake[0]),
          minute: int.parse(partsWake[1]),
        );
        _stressLevel = _todayRecord!.stressLevel;
        _qualitySleep = _todayRecord!.qualitySleep;
      } else {
        _stressLevel = 5;
        _qualitySleep = 5;
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
  }

  Future<void> setJamBangun(TimeOfDay time) async {
    _jamBangun = time;
    notifyListeners();
  }

  void setStressLevel(int level) {
    if (level < 1 || level > 10) return; // Changed to 1-10
    _stressLevel = level;
    notifyListeners();
  }

  void setQualitySleep(int level) {
    if (level < 1 || level > 10) return; // Changed to 1-10
    _qualitySleep = level;
    notifyListeners();
  }

  Duration? calculateDuration() {
    if (_jamTidur == null || _jamBangun == null) return null;
    final minutes =
        (_jamBangun!.hour * 60 + _jamBangun!.minute) -
        (_jamTidur!.hour * 60 + _jamTidur!.minute);
    return Duration(minutes: minutes >= 0 ? minutes : minutes + 24 * 60);
  }

  Future<double> calculateQuality() async {
    final duration = calculateDuration();
    if (duration == null) return 0.0;

    final score = await _apiService.calculateSleepScore(
      durationMinutes: duration.inMinutes,
      stressLevel: _stressLevel,
      qualitySleep: _qualitySleep,
    );

    return score.clamp(0, 100);
  }

  Future<double?> submitSleepData() async {
    if (_jamTidur == null || _jamBangun == null) return null;

    _isSaving = true;
    notifyListeners();

    try {
      final duration = calculateDuration();
      if (duration == null) return null;

      final sleepStr =
          '${_jamTidur!.hour.toString().padLeft(2, '0')}:${_jamTidur!.minute.toString().padLeft(2, '0')}';
      final wakeStr =
          '${_jamBangun!.hour.toString().padLeft(2, '0')}:${_jamBangun!.minute.toString().padLeft(2, '0')}';

      // Calculate score from API
      final apiScore = await calculateQuality();

      final newRecord = SleepRecord(
        id:
            _todayRecord?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        sleepTime: sleepStr,
        wakeTime: wakeStr,
        durationMinutes: duration.inMinutes,
        quality: apiScore,
        stressLevel: _stressLevel,
        qualitySleep: _qualitySleep,
        date: DateTime.now(),
        prediction: apiScore,
      );

      await _storageService.save(newRecord);
      await loadData();

      // Return the calculated score
      return apiScore;
    } catch (e) {
      debugPrint('Error submitting sleep data: $e');
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(String id) async {
    final result = await _storageService.delete(id);
    if (result) await loadData();
    return result;
  }

  Future<bool> clearAllData() async {
    final result = await _storageService.deleteAll();
    if (result) {
      _jamTidur = null;
      _jamBangun = null;
      _stressLevel = 5;
      _qualitySleep = 5;
      _todayRecord = null;
      _weeklyRecords = [];
      _weeklyAverageDuration = 0;
      notifyListeners();
    }
    return result;
  }

  static String formatDurationHuman(Duration? dur) {
    if (dur == null) return '--';
    return '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
  }

  static String formatTimeOfDay(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
