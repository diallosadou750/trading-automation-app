import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/trading_provider.dart';
import '../utils/theme.dart';

class TradingHistoryScreen extends StatefulWidget {
  const TradingHistoryScreen({super.key});

  @override
  State<TradingHistoryScreen> createState() => _TradingHistoryScreenState();
}

class _TradingHistoryScreenState extends State<TradingHistoryScreen> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Gagnants', 'Perdants'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TradingProvider>(context, listen: false).loadTradingHistory();
    });
  }

  List<Map<String, dynamic>> _getFilteredTrades(List<Map<String, dynamic>> trades) {
    switch (_selectedFilter) {
      case 'Gagnants':
        return trades.where((trade) => (trade['pnl'] ?? 0.0) > 0).toList();
      case 'Perdants':
        return trades.where((trade) => (trade['pnl'] ?? 0.0) < 0).toList();
      default:
        return trades;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des trades'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Filtrer les trades'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _filters.map((filter) {
                      return RadioListTile<String>(
                        title: Text(filter),
                        value: filter,
                        groupValue: _selectedFilter,
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TradingProvider>(
        builder: (context, trading, child) {
          if (trading.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTrades = _getFilteredTrades(trading.tradingHistory);

          if (filteredTrades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun trade trouvé',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'Tous'
                        ? 'Commencez à trader pour voir votre historique'
                        : 'Aucun trade ${_selectedFilter.toLowerCase()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Résumé des statistiques
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Total',
                        filteredTrades.length.toString(),
                        AppTheme.neutralColor,
                      ),
                      _buildStatItem(
                        'Gagnants',
                        filteredTrades.where((t) => (t['pnl'] ?? 0.0) > 0).length.toString(),
                        AppTheme.profitColor,
                      ),
                      _buildStatItem(
                        'Perdants',
                        filteredTrades.where((t) => (t['pnl'] ?? 0.0) < 0).length.toString(),
                        AppTheme.lossColor,
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des trades
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTrades.length,
                  itemBuilder: (context, index) {
                    final trade = filteredTrades[index];
                    final pnl = trade['pnl'] ?? 0.0;
                    final isProfitable = pnl > 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isProfitable ? AppTheme.profitColor : AppTheme.lossColor,
                          child: Icon(
                            isProfitable ? Icons.trending_up : Icons.trending_down,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              trade['symbol'] ?? 'N/A',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: trade['side'] == 'BUY' ? AppTheme.profitColor : AppTheme.lossColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                trade['side'] ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantité: ${trade['quantity']?.toStringAsFixed(4) ?? 'N/A'}'),
                            Text('Prix: ${trade['price']?.toStringAsFixed(2) ?? 'N/A'} USDT'),
                            Text('Exchange: ${trade['exchange'] ?? 'N/A'}'),
                            Text(
                              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(trade['timestamp']))}',
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${pnl.toStringAsFixed(2)} USDT',
                              style: TextStyle(
                                color: isProfitable ? AppTheme.profitColor : AppTheme.lossColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (trade['strategy'] != null)
                              Text(
                                trade['strategy'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          _showTradeDetails(trade);
                        },
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showTradeDetails(Map<String, dynamic> trade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails du trade - ${trade['symbol']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Symbole', trade['symbol'] ?? 'N/A'),
            _buildDetailRow('Côté', trade['side'] ?? 'N/A'),
            _buildDetailRow('Quantité', trade['quantity']?.toStringAsFixed(4) ?? 'N/A'),
            _buildDetailRow('Prix', '${trade['price']?.toStringAsFixed(2) ?? 'N/A'} USDT'),
            _buildDetailRow('PnL', '${(trade['pnl'] ?? 0.0).toStringAsFixed(2)} USDT'),
            _buildDetailRow('Exchange', trade['exchange'] ?? 'N/A'),
            _buildDetailRow('Stratégie', trade['strategy'] ?? 'N/A'),
            _buildDetailRow(
              'Date',
              DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(trade['timestamp'])),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 