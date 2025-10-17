class SleepRecord {
  final String id;
  final String sleepTime; // Format: "HH:mm"
  final String wakeTime; // Format: "HH:mm"
  final int durationMinutes;
  final double quality;
  final int stressLevel;
  final DateTime date;

  SleepRecord({
    required this.id,
    required this.sleepTime,
    required this.wakeTime,
    required this.durationMinutes,
    required this.quality,
    required this.stressLevel,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'durationMinutes': durationMinutes,
      'quality': quality,
      'stressLevel': stressLevel,
      'date': date.toIso8601String(),
    };
  }

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      id: json['id'],
      sleepTime: json['sleepTime'],
      wakeTime: json['wakeTime'],
      durationMinutes: json['durationMinutes'],
      quality: json['quality'],
      stressLevel: json['stressLevel'] ?? 3,
      date: DateTime.parse(json['date']),
    );
  }

  SleepRecord copyWith({
    String? id,
    String? sleepTime,
    String? wakeTime,
    int? durationMinutes,
    double? quality,
    int? stressLevel,
    DateTime? date,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      quality: quality ?? this.quality,
      stressLevel: stressLevel ?? this.stressLevel,
      date: date ?? this.date,
    );
  }
}
