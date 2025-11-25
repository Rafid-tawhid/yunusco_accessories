// screens/add_garment_accessories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/helper_class/helper_class.dart';
import 'package:yunusco_accessories/screens/show_costing_items.dart';

import '../models/acessories_model.dart';
import '../riverpod/costing_provider.dart';



class AddGarmentAccessoriesScreen extends ConsumerStatefulWidget {
  const AddGarmentAccessoriesScreen({super.key});

  @override
  ConsumerState<AddGarmentAccessoriesScreen> createState() => _AddGarmentAccessoriesScreenState();
}

class _AddGarmentAccessoriesScreenState extends ConsumerState<AddGarmentAccessoriesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Information Controllers
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _usageController = TextEditingController();

  // Material & Composition Controllers
  final _materialController = TextEditingController();
  final _compositionController = TextEditingController();
  final _finishController = TextEditingController();
  final _patternController = TextEditingController();
  final _qualityGradeController = TextEditingController();

  // Dimensions & Measurements Controllers
  final _sizeController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _thicknessController = TextEditingController();
  final _diameterController = TextEditingController();
  final _weightController = TextEditingController();

  // Color & Appearance Controllers
  final _colorController = TextEditingController();

  // Pricing & Inventory Controllers
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1000');
  final _unitController = TextEditingController(text: 'Pieces');

  // Supplier Information Controllers
  final _supplierController = TextEditingController();
  final _supplierCodeController = TextEditingController();
  final _countryOfOriginController = TextEditingController();

  // Care & Usage Controllers
  final _careInstructionsController = TextEditingController();

  // Boolean values for checkboxes
  bool _isWashable = true;
  bool _isEcoFriendly = false;

  // Storage for accessories
  List<GarmentAccessory> _accessoriesList = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample data for testing
    _typeController.text = 'Button';
    _materialController.text = 'Plastic';
    _compositionController.text = '100% Polyester';
    _sizeController.text = '16mm';
    _colorController.text = 'Black';
    _finishController.text = 'Matte';
    _brandController.text = 'Premium Brand';
    _supplierController.text = 'Global Accessories Ltd.';
    _supplierCodeController.text = 'BTN-16-BLK';
    _countryOfOriginController.text = 'China';
    _qualityGradeController.text = 'A+';
    _usageController.text = 'Shirts, Jackets, Pants';
    _careInstructionsController.text = 'Machine washable';
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _typeController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _usageController.dispose();
    _materialController.dispose();
    _compositionController.dispose();
    _finishController.dispose();
    _patternController.dispose();
    _qualityGradeController.dispose();
    _sizeController.dispose();
    _dimensionsController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _thicknessController.dispose();
    _diameterController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _supplierController.dispose();
    _supplierCodeController.dispose();
    _countryOfOriginController.dispose();
    _careInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _addAccessory() async {
    if (_formKey.currentState!.validate()) {
      final accessory = GarmentAccessory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _typeController.text,
        material: _materialController.text,
        composition: _compositionController.text,
        size: _sizeController.text,
        dimensions: _dimensionsController.text,
        color: _colorController.text,
        weight: _weightController.text,
        thickness: _thicknessController.text,
        length: _lengthController.text,
        width: _widthController.text,
        diameter: _diameterController.text,
        pattern: _patternController.text,
        finish: _finishController.text,
        brand: _brandController.text,
        unit: _unitController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        supplier: _supplierController.text,
        supplierCode: _supplierCodeController.text,
        description: _descriptionController.text,
        usage: _usageController.text,
        status: DashboardHelper.reviewStatus,
        careInstructions: _careInstructionsController.text,
        countryOfOrigin: _countryOfOriginController.text,
        qualityGrade: _qualityGradeController.text,
        isWashable: _isWashable,
        isEcoFriendly: _isEcoFriendly,
      );

      setState(() {
        _accessoriesList.add(accessory);
      });




      try {
        await ref.read(accessorySaveProvider(accessory).future);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${accessory.name} saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _isWashable = true;
      _isEcoFriendly = false;
    });
    _quantityController.text = '1000';
    _unitController.text = 'Pieces';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Garment Accessories'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewAccessoriesScreen()));
            },
            tooltip: 'View All Accessories',
          ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionHeader('Basic Information', Icons.info),
                      _buildBasicInfoSection(),

                      _buildSectionHeader('Material & Composition', Icons.construction),
                      _buildMaterialSection(),

                      _buildSectionHeader('Dimensions & Measurements', Icons.square_foot),
                      _buildDimensionsSection(),

                      _buildSectionHeader('Appearance & Finish', Icons.color_lens),
                      _buildAppearanceSection(),

                      _buildSectionHeader('Pricing & Inventory', Icons.attach_money),
                      _buildPricingSection(),

                      _buildSectionHeader('Supplier Information', Icons.business),
                      _buildSupplierSection(),

                      _buildSectionHeader('Care & Usage', Icons.cabin),
                      _buildCareSection(),

                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Accessory Name *',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
                hintText: 'e.g., 4-hole Plastic Button, Nylon Zipper',
              ),
              validator: (val) => val == null || val.isEmpty ? 'Enter accessory name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
                hintText: 'e.g., Button, Zipper, Elastic, Label',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                prefixIcon: Icon(Icons.branding_watermark),
                border: OutlineInputBorder(),
                hintText: 'Brand name if applicable',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usageController,
              decoration: const InputDecoration(
                labelText: 'Usage/Application',
                prefixIcon: Icon(Icons.assignment),
                border: OutlineInputBorder(),
                hintText: 'e.g., Shirts, Jackets, Pants, Bags',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _materialController,
              decoration: const InputDecoration(
                labelText: 'Material',
                prefixIcon: Icon(Icons.construction),
                border: OutlineInputBorder(),
                hintText: 'e.g., Plastic, Metal, Cotton, Polyester',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _compositionController,
              decoration: const InputDecoration(
                labelText: 'Composition',
                prefixIcon: Icon(Icons.science),
                border: OutlineInputBorder(),
                hintText: 'e.g., 100% Cotton, 65% Polyester 35% Cotton',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _finishController,
              decoration: const InputDecoration(
                labelText: 'Finish/Surface',
                prefixIcon: Icon(Icons.texture),
                border: OutlineInputBorder(),
                hintText: 'e.g., Matte, Glossy, Brushed, Polished',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _patternController,
              decoration: const InputDecoration(
                labelText: 'Pattern/Design',
                prefixIcon: Icon(Icons.pattern),
                border: OutlineInputBorder(),
                hintText: 'e.g., Plain, Striped, Floral, Geometric',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qualityGradeController,
              decoration: const InputDecoration(
                labelText: 'Quality Grade',
                prefixIcon: Icon(Icons.grade),
                border: OutlineInputBorder(),
                hintText: 'e.g., A+, Premium, Standard, Economy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionsSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      prefixIcon: Icon(Icons.aspect_ratio),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 16mm, #5, Medium',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _dimensionsController,
                    decoration: const InputDecoration(
                      labelText: 'Dimensions',
                      prefixIcon: Icon(Icons.format_size),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 2x3cm, 1"x2"',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lengthController,
                    decoration: const InputDecoration(
                      labelText: 'Length',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 50cm, 20"',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 2cm, 0.5"',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _thicknessController,
                    decoration: const InputDecoration(
                      labelText: 'Thickness',
                      prefixIcon: Icon(Icons.height),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 0.5mm, 2mm',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _diameterController,
                    decoration: const InputDecoration(
                      labelText: 'Diameter',
                      prefixIcon: Icon(Icons.circle),
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 5mm, 0.25"',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
                hintText: 'e.g., 5g, 0.2oz, 50gsm',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.color_lens),
                border: OutlineInputBorder(),
                hintText: 'e.g., Black, Navy Blue, White, Red',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price per Unit *',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                      hintText: '0.00',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid price' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(),
                      hintText: '1000',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || int.tryParse(val) == null ? 'Enter valid quantity' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                prefixIcon: Icon(Icons.square_foot),
                border: OutlineInputBorder(),
                hintText: 'e.g., Pieces, Meters, Yards, Rolls',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier Name',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
                hintText: 'Supplier company name',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _supplierCodeController,
              decoration: const InputDecoration(
                labelText: 'Supplier Code/Part Number',
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
                hintText: 'e.g., BTN-16-BLK, ZIP-05-NYL',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryOfOriginController,
              decoration: const InputDecoration(
                labelText: 'Country of Origin',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
                hintText: 'e.g., China, Bangladesh, India',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareSection() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _careInstructionsController,
              decoration: const InputDecoration(
                labelText: 'Care Instructions',
                prefixIcon: Icon(Icons.local_laundry_service),
                border: OutlineInputBorder(),
                hintText: 'e.g., Machine wash cold, Do not bleach',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Washable'),
                    value: _isWashable,
                    onChanged: (value) {
                      setState(() {
                        _isWashable = value ?? false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Eco Friendly'),
                    value: _isEcoFriendly,
                    onChanged: (value) {
                      setState(() {
                        _isEcoFriendly = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text(
              'Clear Form',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _addAccessory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Add Accessory',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

}