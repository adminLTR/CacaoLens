import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  // Analysis endpoints
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/analysis/image');
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analysis'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load analysis history');
      }
    } catch (e) {
      throw Exception('Error fetching analysis history: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalysisById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analysis/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load analysis');
      }
    } catch (e) {
      throw Exception('Error fetching analysis: $e');
    }
  }

  // Cacao endpoints
  Future<List<Map<String, dynamic>>> getCacaoList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cacao'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load cacao list');
      }
    } catch (e) {
      throw Exception('Error fetching cacao list: $e');
    }
  }

  Future<Map<String, dynamic>> getCacaoById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cacao/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load cacao');
      }
    } catch (e) {
      throw Exception('Error fetching cacao: $e');
    }
  }

  Future<Map<String, dynamic>> createCacao(Map<String, dynamic> cacaoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cacao'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cacaoData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to create cacao');
      }
    } catch (e) {
      throw Exception('Error creating cacao: $e');
    }
  }
}
