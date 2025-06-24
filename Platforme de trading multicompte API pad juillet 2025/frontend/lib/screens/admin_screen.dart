import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/trading_provider.dart';
import '../utils/theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.analytics), text: 'Performance'),
            Tab(icon: Icon(Icons.settings), text: 'Configuration'),
            Tab(icon: Icon(Icons.security), text: 'Sécurité'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildPerformanceTab(),
          _buildConfigurationTab(),
          _buildSecurityTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestion des utilisateurs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildUserStats(),
                  const SizedBox(height: 16),
                  _buildUserList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total', '1,234', AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Actifs', '987', AppTheme.profitColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Nouveaux', '45', AppTheme.accentColor),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Utilisateurs récents',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text('U${index + 1}'),
                ),
                title: Text('user${index + 1}@example.com'),
                subtitle: Text('Inscrit le ${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10)}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                    const PopupMenuItem(
                      value: 'suspend',
                      child: Text('Suspendre'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                  onSelected: (value) {
                    // TODO: Implémenter les actions
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Action: $value')),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Métriques de performance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceMetrics(),
                  const SizedBox(height: 16),
                  _buildSystemHealth(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Temps de réponse', '245ms', AppTheme.profitColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard('Requêtes/min', '1,234', AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Taux d\'erreur', '0.5%', AppTheme.warningColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard('CPU', '45%', AppTheme.neutralColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemHealth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'État du système',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildHealthIndicator('Base de données', 'En ligne', Colors.green),
        _buildHealthIndicator('Redis', 'En ligne', Colors.green),
        _buildHealthIndicator('API Trading', 'En ligne', Colors.green),
        _buildHealthIndicator('Webhooks', 'En ligne', Colors.green),
      ],
    );
  }

  Widget _buildConfigurationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration du système',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildConfigSection('Trading', [
                    _buildConfigItem('Mode sandbox', true),
                    _buildConfigItem('Exécution automatique', true),
                    _buildConfigItem('Notifications', true),
                  ]),
                  const SizedBox(height: 16),
                  _buildConfigSection('Sécurité', [
                    _buildConfigItem('Rate limiting', true),
                    _buildConfigItem('Validation des signatures', true),
                    _buildConfigItem('Chiffrement AES-256', true),
                  ]),
                  const SizedBox(height: 16),
                  _buildConfigSection('Monitoring', [
                    _buildConfigItem('Alertes Telegram', true),
                    _buildConfigItem('Logs détaillés', true),
                    _buildConfigItem('Métriques temps réel', true),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sécurité et audit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityMetrics(),
                  const SizedBox(height: 16),
                  _buildAuditLog(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Tentatives d\'attaque', '12', AppTheme.errorColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('IPs bloquées', '5', AppTheme.warningColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Alertes', '3', AppTheme.accentColor),
        ),
      ],
    );
  }

  Widget _buildAuditLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log d\'audit récent',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.security,
                  color: AppTheme.primaryColor,
                ),
                title: Text('Tentative d\'accès non autorisé'),
                subtitle: Text('IP: 192.168.1.${index + 1} - ${DateTime.now().subtract(Duration(hours: index)).toString().substring(11, 16)}'),
                trailing: Chip(
                  label: const Text('BLOQUÉ'),
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String service, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8),
          Text(service),
          const Spacer(),
          Text(status, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildConfigSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildConfigItem(String title, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? AppTheme.profitColor : AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
          const Spacer(),
          Switch(
            value: enabled,
            onChanged: (value) {
              // TODO: Implémenter le changement de configuration
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title: ${value ? "activé" : "désactivé"}')),
              );
            },
          ),
        ],
      ),
    );
  }
} 