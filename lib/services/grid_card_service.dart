import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/grid_card_model.dart';

class GridCardService {
  static final GridCardService _instance =
  GridCardService._internal();

  factory GridCardService() => _instance;

  GridCardService._internal();

  /// ✅ WORKING API URL
  static const String _endpoint =
      'https://user.jobes24x7.com/api/grid-card/9508383027';

  /// ✅ REAL JWT TOKEN
  static const String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTIsImVtYWlsIjoic2FiYXJpc2h3YXJhbjE3MThAZ21haWwuY29tIiwidXNlcl9tYWluX2lkIjoiOTUwODM4MzAyNyIsInVzZXJfbmFtZSI6IlNhYmFyaSAiLCJ1c2VyX3R5cGUiOiJndWVzdCIsImlhdCI6MTc3OTMzNjA2MywiZXhwIjoxNzc5NDIyNDYzfQ.ap94YHeX4xZnNbrkInhDNPEVaPwb473TWCPQZ23G1qc';

  GridCardModel? _cachedGrid;

  GridCardModel? get cachedGrid => _cachedGrid;

  Future<GridCardModel> fetchGridCard({
    bool forceRefresh = false,
  }) async {
    if (_cachedGrid != null && !forceRefresh) {
      return _cachedGrid!;
    }

    try {
      print("===== GRID CARD API DEBUG =====");
      print("GRID API URL: $_endpoint");

      final response = await http.get(
        Uri.parse(_endpoint),

        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      print(
        "STATUS CODE: ${response.statusCode}",
      );

      print("RESPONSE BODY:");
      print(response.body);

      print("===============================");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
        jsonDecode(response.body);

        print("JSON SUCCESSFULLY PARSED");

        _cachedGrid =
            GridCardModel.fromJson(jsonResponse);

        return _cachedGrid!;
      }

      if (response.statusCode == 401) {
        throw Exception(
          '401 Unauthorized - Token expired or invalid',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          '404 API Not Found',
        );
      }

      throw Exception(
        'API Error: ${response.statusCode}',
      );
    } catch (e, stacktrace) {
      print("GRID CARD API ERROR:");
      print(e);

      print("STACKTRACE:");
      print(stacktrace);

      rethrow;
    }
  }
}