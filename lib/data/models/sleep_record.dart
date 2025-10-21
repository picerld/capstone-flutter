class SleepRecord {
  final String id;
  final String sleepTime; // Format: "HH:mm"
  final String wakeTime; // Format: "HH:mm"
  final int durationMinutes;
  final double quality; // 0-10 scale
  final int stressLevel; // 1-5
  final int qualitySleep; // 1-5
  final DateTime date;
  final double? prediction; // 0-10 scale

  SleepRecord({
    required this.id,
    required this.sleepTime,
    required this.wakeTime,
    required this.durationMinutes,
    required this.quality,
    required this.stressLevel,
    required this.qualitySleep,
    required this.date,
    this.prediction,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'durationMinutes': durationMinutes,
      'quality': quality,
      'stressLevel': stressLevel,
      'qualitySleep': qualitySleep,
      'date': date.toIso8601String(),
      'prediction': prediction,
    };
  }

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      id: json['id'],
      sleepTime: json['sleepTime'],
      wakeTime: json['wakeTime'],
      durationMinutes: json['durationMinutes'],
      quality: (json['quality'] as num).toDouble(),
      stressLevel: json['stressLevel'] ?? 3,
      qualitySleep: json['qualitySleep'] ?? 3,
      date: DateTime.parse(json['date']),
      prediction: json['prediction'] != null
          ? (json['prediction'] as num).toDouble()
          : null,
    );
  }

  SleepRecord copyWith({
    String? id,
    String? sleepTime,
    String? wakeTime,
    int? durationMinutes,
    double? quality,
    int? stressLevel,
    int? qualitySleep,
    DateTime? date,
    double? prediction,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      quality: quality ?? this.quality,
      stressLevel: stressLevel ?? this.stressLevel,
      qualitySleep: qualitySleep ?? this.qualitySleep,
      date: date ?? this.date,
      prediction: prediction ?? this.prediction,
    );
  }
}
