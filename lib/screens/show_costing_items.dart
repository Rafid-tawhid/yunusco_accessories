// screens/view_accessories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/acessories_model.dart';
import '../riverpod/costing_provider.dart';


class ViewAccessoriesScreen extends ConsumerWidget {
  const ViewAccessoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessoriesAsync = ref.watch(accessoriesListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Accessories'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(accessoriesListProvider);
            },
          ),
        ],
      ),
      body: accessoriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading accessories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(accessoriesListProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (accessories) {
          if (accessories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Accessories Found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some accessories to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return _buildAccessoriesList(accessories);
        },
      ),
    );
  }

  Widget _buildAccessoriesList(List<GarmentAccessory> accessories) {
    return ListView.builder(
      itemCount: accessories.length,
      itemBuilder: (context, index) {
        final accessory = accessories[index];
        return _buildAccessoryCard(accessory);
      },
    );
  }

  Widget _buildAccessoryCard(GarmentAccessory accessory) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            accessory.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          accessory.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${accessory.type} • ${accessory.material} • \$${accessory.price}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Text(
          'Qty: ${accessory.quantity}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _buildInfoSection('Basic Information', [
                  _buildInfoRow('Type', accessory.type),
                  _buildInfoRow('Material', accessory.material),
                  _buildInfoRow('Brand', accessory.brand),
                  _buildInfoRow('Color', accessory.color),
                  _buildInfoRow('Size', accessory.size),
                ]),

                const SizedBox(height: 16),

                // Dimensions
                _buildInfoSection('Dimensions', [
                  _buildInfoRow('Length', accessory.length),
                  _buildInfoRow('Width', accessory.width),
                  _buildInfoRow('Thickness', accessory.thickness),
                  _buildInfoRow('Diameter', accessory.diameter),
                  _buildInfoRow('Weight', accessory.weight),
                ]),

                const SizedBox(height: 16),

                // Pricing & Supplier
                _buildInfoSection('Pricing & Supplier', [
                  _buildInfoRow('Price', '\$${accessory.price}'),
                  _buildInfoRow('Quantity', '${accessory.quantity}'),
                  _buildInfoRow('Unit', accessory.unit),
                  _buildInfoRow('Supplier', accessory.supplier),
                  _buildInfoRow('Supplier Code', accessory.supplierCode),
                  _buildInfoRow('Country of Origin', accessory.countryOfOrigin),
                ]),

                const SizedBox(height: 16),

                // Additional Information
                _buildInfoSection('Additional Information', [
                  _buildInfoRow('Composition', accessory.composition),
                  _buildInfoRow('Finish', accessory.finish),
                  _buildInfoRow('Pattern', accessory.pattern),
                  _buildInfoRow('Quality Grade', accessory.qualityGrade),
                  _buildInfoRow('Usage', accessory.usage),
                  _buildInfoRow('Care Instructions', accessory.careInstructions),
                  _buildInfoRow('Washable', accessory.isWashable ? 'Yes' : 'No'),
                  _buildInfoRow('Eco Friendly', accessory.isEcoFriendly ? 'Yes' : 'No'),
                ]),

                if (accessory.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection('Description', [
                    Text(
                      accessory.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}