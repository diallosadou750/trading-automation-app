import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class TradingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _apiKeys = [];
  List<Map<String, dynamic>> _tradingHistory = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get apiKeys => _apiKeys;
  List<Map<String, dynamic>> get tradingHistory => _tradingHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger les clés API
  Future<void> loadApiKeys() async {
    _setLoading(true);
    _clearError();

    try {
      _apiKeys = await _apiService.getApiKeys();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter une clé API
  Future<bool> addApiKey(String exchange, String key, String secret) async {
    _setLoading(true);
    _clearError();

    try {
      final newKey = await _apiService.addApiKey(exchange, key, secret);
      _apiKeys.add(newKey);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer une clé API
  Future<bool> deleteApiKey(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.deleteApiKey(id);
      _apiKeys.removeWhere((key) => key['id'] == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Charger l'historique des trades
  Future<void> loadTradingHistory() async {
    _setLoading(true);
    _clearError();

    try {
      _tradingHistory = await _apiService.getTradingHistory();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Exécuter un trade
  Future<bool> executeTrade(String symbol, String side, double quantity, String exchange) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.executeTrade(symbol, side, quantity, exchange);
      // Recharger l'historique après l'exécution
      await loadTradingHistory();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Calculer le PnL total
  double get totalPnL {
    return _tradingHistory.fold(0.0, (sum, trade) {
      final pnl = trade['pnl'] ?? 0.0;
      return sum + pnl;
    });
  }

  // Obtenir les trades gagnants
  List<Map<String, dynamic>> get profitableTrades {
    return _tradingHistory.where((trade) => (trade['pnl'] ?? 0.0) > 0).toList();
  }

  // Obtenir les trades perdants
  List<Map<String, dynamic>> get losingTrades {
    return _tradingHistory.where((trade) => (trade['pnl'] ?? 0.0) < 0).toList();
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