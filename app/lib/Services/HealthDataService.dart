import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/sharedPref.dart';
import '../Constants/Constants.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../Pages/homepage.dart';

class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  final logger = Logger();
  HealthDataService._internal();

  Future<Map<String, dynamic>> getPredictionByDate(DateTime date) async {
    try {
      final token = await sharedPref.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/api/v1/health/prediction/${date.toIso8601String()}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Failed to load prediction data');
      }
    } catch (e) {
      logger.e('Error fetching prediction data: $e');
      throw Exception('Failed to load prediction data');
    }
  }

  Future<void> submitHealthData({
    required BuildContext context,
    required double height,
    required double weight,
    required int stroke,
    required int heartDiseaseorAttack,
    required int sex,
    required int age,
  }) async {
    try {
      final token = await sharedPref.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/health/predict'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Height': height,
          'Weight': weight,
          'Stroke': stroke,
          'HeartDiseaseorAttack': heartDiseaseorAttack,
          'Sex': sex,
          'Age': age,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.d('responseData: $responseData');
        // Navigate to homepage after successful submission
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        throw Exception('Failed to submit health data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting health data: $e');
    }
  }
}
