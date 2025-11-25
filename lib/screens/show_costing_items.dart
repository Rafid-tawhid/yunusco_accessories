// screens/view_accessories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/helper_class/helper_class.dart';

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

          return _buildAccessoriesList(accessories, ref,context);
        },
      ),
    );
  }

  Widget _buildAccessoriesList(List<GarmentAccessory> accessories, WidgetRef ref,BuildContext context) {
    return ListView.builder(
      itemCount: accessories.length,
      itemBuilder: (context, index) {
        final accessory = accessories[index];
        return _buildAccessoryCard(accessory, ref,context);
      },
    );
  }

  Widget _buildAccessoryCard(GarmentAccessory accessory, WidgetRef ref,BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(accessory.status).withOpacity(0.2),
          child: Text(
            accessory.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getStatusColor(accessory.status),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                accessory.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(accessory.status),
          ],
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
                // Status Section
                _buildInfoSection('Status Information', [
                  _buildInfoRow('Status', accessory.status),
                  _buildStatusInfo(accessory.status),
                ]),

                const SizedBox(height: 16),

                // Price Update Section
                _buildPriceUpdateSection(accessory, ref,context),

                const SizedBox(height: 16),

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
                  _buildInfoRow('Current Price', '\$${accessory.price}'),
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

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusInfo(String status) {
    String statusInfo = '';
    Color statusColor = Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        statusInfo = 'This accessory is currently available and in stock';
        statusColor = Colors.green;
        break;
      case 'out of stock':
        statusInfo = 'This accessory is currently out of stock';
        statusColor = Colors.red;
        break;
      case 'discontinued':
        statusInfo = 'This accessory has been discontinued';
        statusColor = Colors.orange;
        break;
      case 'low stock':
        statusInfo = 'This accessory is running low on stock';
        statusColor = Colors.orange;
        break;
      default:
        statusInfo = 'Status information not available';
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: statusColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            statusInfo,
            style: TextStyle(
              color: statusColor,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceUpdateSection(GarmentAccessory accessory, WidgetRef ref,BuildContext context) {
    final TextEditingController priceController = TextEditingController(
      text: accessory.price.toString(),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Price',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'New Price',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  _updatePrice(context, accessory, priceController.text, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current Price: \$${accessory.price}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _updatePrice(BuildContext context, GarmentAccessory accessory, String newPrice, WidgetRef ref) {
    final double? parsedPrice = double.tryParse(newPrice);

    if (parsedPrice == null || parsedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Price'),
        content: Text('Are you sure you want to update the price from \$${accessory.price} to \$$parsedPrice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Updating price...'),
                  backgroundColor: Colors.blue.shade700,
                  duration: const Duration(seconds: 2),
                ),
              );

              try {
                // Create updated accessory
                final updatedAccessory = GarmentAccessory(
                  id: accessory.id,
                  name: accessory.name,
                  type: accessory.type,
                  material: accessory.material,
                  composition: accessory.composition,
                  size: accessory.size,
                  dimensions: accessory.dimensions,
                  color: accessory.color,
                  weight: accessory.weight,
                  thickness: accessory.thickness,
                  length: accessory.length,
                  width: accessory.width,
                  diameter: accessory.diameter,
                  pattern: accessory.pattern,
                  finish: accessory.finish,
                  brand: accessory.brand,
                  unit: accessory.unit,
                  price: parsedPrice,
                  quantity: accessory.quantity,
                  supplier: accessory.supplier,
                  supplierCode: accessory.supplierCode,
                  description: accessory.description,
                  usage: accessory.usage,
                  careInstructions: accessory.careInstructions,
                  countryOfOrigin: accessory.countryOfOrigin,
                  qualityGrade: accessory.qualityGrade,
                  isWashable: accessory.isWashable,
                  isEcoFriendly: accessory.isEcoFriendly,
                  status: DashboardHelper.modifyStatus, // Keep the same status
                );

                // Update in Firebase
                await ref.read(accessorySaveProvider(updatedAccessory).future);

                // Refresh the list
                ref.invalidate(accessoriesListProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Price updated to \$$parsedPrice'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating price: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'out of stock':
        return Colors.red;
      case 'discontinued':
        return Colors.orange;
      case 'low stock':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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