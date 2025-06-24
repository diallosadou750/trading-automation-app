import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  static const String tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers avec token d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Supprimer le token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(data['access_token']);
      return data;
    } else {
      throw Exception('Échec de la connexion');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de l\'inscription');
    }
  }

  // Gestion des clés API
  Future<List<Map<String, dynamic>>> getApiKeys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api-keys/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Échec de récupération des clés API');
    }
  }

  Future<Map<String, dynamic>> addApiKey(String exchange, String key, String secret) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api-keys/'),
      headers: await _getHeaders(),
      body: json.encode({
        'exchange': exchange,
        'key': key,
        'secret': secret,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec d\'ajout de la clé API');
    }
  }

  Future<void> deleteApiKey(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api-keys/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de suppression de la clé API');
    }
  }

  // Trading
  Future<List<Map<String, dynamic>>> getTradingHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trading/history'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Échec de récupération de l\'historique');
    }
  }

  Future<Map<String, dynamic>> executeTrade(String symbol, String side, double quantity, String exchange) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trading/execute'),
      headers: await _getHeaders(),
      body: json.encode({
        'symbol': symbol,
        'side': side,
        'quantity': quantity,
        'exchange': exchange,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec d\'exécution du trade');
    }
  }

  // Informations utilisateur
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de récupération des informations utilisateur');
    }
  }
} 