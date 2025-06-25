// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  
  ApiService({required this.baseUrl});
  
  Future<bool> sendGroupedNumbers(Map<int, int> groupedNumbers) async {
    try {
      final Map<String, int> jsonMap = {};
      groupedNumbers.forEach(
        (key, value) {
          jsonMap[key.toString()] = value;
        }
      );
      
      final response = await http.post(
        Uri.parse('$baseUrl/update-attendance'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'grouped_numbers': jsonMap}),
      );
      
      if (response.statusCode == 200) {
        print('Data successfully sent to FastAPI');
        return true;
      } else {
        print('Failed to send data: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return false;
    }
  }
}