// screens/simple_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:yunusco_accessories/screens/show_costing_items.dart';

import 'create_costing_screen.dart';

class SimpleDashboardScreen extends StatelessWidget {
  const SimpleDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garment Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Costing Module
            _buildModuleCard(
              context: context,
              title: 'Costing',
              description: 'Calculate accessory pricing and costs',
              icon: Icons.calculate,
              color: Colors.orange,
              route: '/costing',
            ),

            const SizedBox(height: 20),

            // Accessories Module
            _buildModuleCard(
              context: context,
              title: 'Accessories',
              description: 'Manage garment accessories',
              icon: Icons.inventory_2,
              color: Colors.green,
              route: '/accessories',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to respective screen
          if (route == '/costing') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CostingScreen()),
            );
          } else if (route == '/accessories') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewAccessoriesScreen()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}