import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/trading_provider.dart';
import '../utils/theme.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exchangeController = TextEditingController();
  final _keyController = TextEditingController();
  final _secretController = TextEditingController();
  bool _obscureSecret = true;

  final List<String> _supportedExchanges = [
    'Binance',
    'Bybit',
    'Hyperliquid',
    'KuCoin',
    'OKX',
    'Coinbase',
    'Kraken',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TradingProvider>(context, listen: false).loadApiKeys();
    });
  }

  @override
  void dispose() {
    _exchangeController.dispose();
    _keyController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _addApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await Provider.of<TradingProvider>(context, listen: false)
        .addApiKey(
          _exchangeController.text,
          _keyController.text,
          _secretController.text,
        );

    if (success && mounted) {
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clé API ajoutée avec succès')),
      );
    }
  }

  void _clearForm() {
    _exchangeController.clear();
    _keyController.clear();
    _secretController.clear();
  }

  Future<void> _deleteApiKey(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette clé API ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Provider.of<TradingProvider>(context, listen: false)
          .deleteApiKey(id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clé API supprimée avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des clés API'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Consumer<TradingProvider>(
        builder: (context, trading, child) {
          return Column(
            children: [
              // Formulaire d'ajout
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajouter une clé API',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        // Sélection de l'exchange
                        DropdownButtonFormField<String>(
                          value: _exchangeController.text.isEmpty ? null : _exchangeController.text,
                          decoration: const InputDecoration(
                            labelText: 'Exchange',
                            prefixIcon: Icon(Icons.exchange),
                          ),
                          items: _supportedExchanges.map((exchange) {
                            return DropdownMenuItem(
                              value: exchange,
                              child: Text(exchange),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _exchangeController.text = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un exchange';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Clé API
                        TextFormField(
                          controller: _keyController,
                          decoration: const InputDecoration(
                            labelText: 'Clé API',
                            prefixIcon: Icon(Icons.key),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la clé API';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Secret API
                        TextFormField(
                          controller: _secretController,
                          obscureText: _obscureSecret,
                          decoration: InputDecoration(
                            labelText: 'Secret API',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureSecret ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureSecret = !_obscureSecret;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le secret API';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Bouton d'ajout
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: trading.isLoading ? null : _addApiKey,
                            child: trading.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Ajouter la clé API'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Liste des clés API
              Expanded(
                child: trading.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : trading.apiKeys.isEmpty
                        ? const Center(
                            child: Text('Aucune clé API configurée'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: trading.apiKeys.length,
                            itemBuilder: (context, index) {
                              final apiKey = trading.apiKeys[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Text(
                                      apiKey['exchange'].substring(0, 1),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(apiKey['exchange']),
                                  subtitle: Text(
                                    'Ajoutée le ${DateTime.parse(apiKey['created_at']).toString().substring(0, 10)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                    onPressed: () => _deleteApiKey(apiKey['id']),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
} 