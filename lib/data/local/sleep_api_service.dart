import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;

class SleepApiService {
  static final SleepApiService instance = SleepApiService._init();
  static const String _baseUrl =
      'https://model-to-api-production.up.railway.app';

  SleepApiService._init();

  Future<double> calculateSleepScore({
    required int durationMinutes,
    required int qualitySleep, // 1-10 scale
    required int stressLevel, // 1-10 scale
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/predict');

      final durationHours = durationMinutes / 60.0;

      debugPrint('🌐 Calling API: $url');
      debugPrint(
        '📊 Payload: duration=$durationHours jam, quality=$qualitySleep, stress=$stressLevel',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'sleep_duration': durationHours,
              'sleep_quality': qualitySleep,
              'stress_level': stressLevel,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('API request timeout'),
          );

      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['prediction'] != null) {
          double apiScore = (data['prediction'] as num).toDouble();

          double percentageScore = (apiScore / 5.8 * 100).clamp(0, 100);

          debugPrint(
            '🎯 API Score: $apiScore/100 → ${percentageScore.toStringAsFixed(1)}%',
          );

          return percentageScore;
        } else {
          throw Exception('Prediction field not found in response: $data');
        }
      } else {
        throw Exception(
          'API returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
      debugPrint('Falling back to local calculation');

      return calculateLocalScore(
        durationMinutes: durationMinutes,
        stressLevel: stressLevel,
        qualitySleep: qualitySleep,
      );
    }
  }

  double calculateLocalScore({
    required int durationMinutes,
    required int stressLevel, // 1-10
    required int qualitySleep, // 1-10
  }) {
    final hours = durationMinutes / 60.0;

    double baseQuality;
    if (hours >= 7 && hours <= 9) {
      baseQuality = 9.5;
    } else if (hours >= 6 && hours < 7) {
      baseQuality = 7.5 + ((hours - 6) * 2);
    } else if (hours > 9 && hours <= 10) {
      baseQuality = 9.5 - ((hours - 9) * 1.5);
    } else if (hours >= 5 && hours < 6) {
      baseQuality = 6 + ((hours - 5) * 1.5);
    } else if (hours < 5) {
      baseQuality = hours * 1.2;
    } else {
      baseQuality = 8 - ((hours - 10) * 1);
    }

    final stressPenalty = (stressLevel - 1) * 0.25;

    final qualityBonus = (qualitySleep - 5.5) * 0.3;

    final finalScore = (baseQuality - stressPenalty + qualityBonus).clamp(
      0,
      10,
    );

    final percentageScore = (finalScore * 10).clamp(0.0, 100.0);

    debugPrint('Local Calculation (1-10 scale):');
    debugPrint(
      'Duration: ${hours.toStringAsFixed(1)}h → Base: ${baseQuality.toStringAsFixed(1)}',
    );
    debugPrint(
      'Stress ($stressLevel/10): -${stressPenalty.toStringAsFixed(2)}',
    );
    debugPrint(
      'Quality ($qualitySleep/10): ${qualityBonus >= 0 ? '+' : ''}${qualityBonus.toStringAsFixed(2)}',
    );
    debugPrint(
      'Final: ${finalScore.toStringAsFixed(1)}/10 → ${percentageScore.toStringAsFixed(1)}%',
    );

    return percentageScore.toDouble();
  }

  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing API connection...');
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      final isHealthy = response.statusCode == 200;

      return isHealthy;
    } catch (e) {
      return false;
    }
  }
}
