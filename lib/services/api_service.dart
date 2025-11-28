import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Dùng domain Render nhé
  static const String baseUrl = "https://mit-detection-demo.onrender.com";

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }
}
