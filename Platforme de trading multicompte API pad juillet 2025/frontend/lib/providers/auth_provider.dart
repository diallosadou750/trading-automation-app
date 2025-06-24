import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _userInfo;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get error => _error;

  // Connexion avec email et mot de passe
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(email, password);
      _isAuthenticated = true;
      await _loadUserInfo();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inscription
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.register(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _apiService.removeToken();
    _isAuthenticated = false;
    _userInfo = null;
    notifyListeners();
  }

  // Charger les informations utilisateur
  Future<void> _loadUserInfo() async {
    try {
      _userInfo = await _apiService.getUserInfo();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Vérifier si l'utilisateur est connecté au démarrage
  Future<void> checkAuthStatus() async {
    try {
      await _loadUserInfo();
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 