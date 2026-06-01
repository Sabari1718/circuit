import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import '../models/grid_card_model.dart';
import '../services/auth_service.dart'; // ADD THIS

class GridCardService {
  static final GridCardService _instance = GridCardService._internal();

  factory GridCardService() => _instance;

  GridCardService._internal();

  static const String _endpoint =
      'https://user.jobes24x7.com/api/grid-card/9508383027';

  GridCardModel? _cachedGrid;

  GridCardModel? get cachedGrid => _cachedGrid;

  Future<GridCardModel> fetchGridCard({bool forceRefresh = false}) async {
    if (_cachedGrid != null && !forceRefresh) {
      return _cachedGrid!;
    }

    try {
      print("===== GRID CARD API DEBUG =====");
      print("GRID API URL: $_endpoint");

      // GET LATEST TOKEN
      final token = await AuthService().getValidToken();

      if (token == null || token.isEmpty) {
        throw Exception('No valid token found');
      }

      print("TOKEN => $token");

      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY:");
      print(response.body);
      print("===============================");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
        jsonDecode(response.body);

        _cachedGrid = GridCardModel.fromJson(jsonResponse);
        return _cachedGrid!;
      }

      if (response.statusCode == 401) {
        throw Exception('401 Unauthorized - Token expired or invalid');
      }

      if (response.statusCode == 404) {
        throw Exception('404 API Not Found');
      }

      throw Exception('API Error: ${response.statusCode}');
    } catch (e, stacktrace) {
      print("GRID CARD API ERROR:");
      print(e);

      print("STACKTRACE:");
      print(stacktrace);

      rethrow;
    }
  }
}