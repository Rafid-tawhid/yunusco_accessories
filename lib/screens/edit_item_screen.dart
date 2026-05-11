import 'package:flutter/material.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  // Controllers for text fields
  final TextEditingController subBrandController = TextEditingController();
  final TextEditingController itemReferenceController = TextEditingController();
  final TextEditingController optionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final TextEditingController itemSizeController = TextEditingController();
  final TextEditingController itemSampleNoController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Selected values for dropdowns
  String? selectedBrand;
  String? selectedItemType;
  String? selectedProductType;
  String? selectedProductLine;
  String? selectedUOM;
  DateTime? selectedApprovedDate;
  String? selectedStatus; // Active/Inactive
  String? selectedBlur; // Blur/Sharpen
  String? selectedFix; // Fix/UnFix

  // Dropdown options
  final List<String> brandOptions = [
    'BASIC RESOURCES-SSI',
    'NIKE',
    'ADIDAS',
    'PUMA',
    'UNDER ARMOUR',
  ];

  final List<String> itemTypeOptions = [
    'BANDEROLE',
    'HANG TAG',
    'PATCH',
    'LABEL',
    'STICKER',
  ];

  final List<String> productTypeOptions = [
    'PRINTED (ROTARY)',
    'PRINTED (FLAT)',
    'EMBOSSED',
    'WOVEN',
    'DAMASK',
  ];

  final List<String> productLineOptions = [
    'PFL',
    'APPAREL',
    'FOOTWEAR',
    'ACCESSORIES',
  ];

  final List<String> uomOptions = [
    'Piece',
    'Dozen',
    'Set',
    'Roll',
    'Box',
  ];

  final List<String> statusOptions = ['Active', 'Inactive'];
  final List<String> blurOptions = ['Can\'t See (Blur)', 'Sharp (Clear)'];
  final List<String> fixOptions = ['Fixed', 'Unfixed'];

  @override
  void dispose() {
    subBrandController.dispose();
    itemReferenceController.dispose();
    optionController.dispose();
    itemPriceController.dispose();
    itemSizeController.dispose();
    itemSampleNoController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Brand (Dropdown)
            _buildDropdownField(
              label: 'Brand',
              value: selectedBrand,
              items: brandOptions,
              onChanged: (value) {
                setState(() {
                  selectedBrand = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 2. Sub-Brand (Text Field - NOT dropdown)
            _buildTextField(
              controller: subBrandController,
              label: 'Sub-Brand',
              hint: 'Enter sub-brand name',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 3. Item Reference (Text Field)
            _buildTextField(
              controller: itemReferenceController,
              label: 'Item Reference',
              hint: 'Enter item reference',
            ),
            const SizedBox(height: 16),

            // 4. Item Type (Dropdown)
            _buildDropdownField(
              label: 'Item Type',
              value: selectedItemType,
              items: itemTypeOptions,
              onChanged: (value) {
                setState(() {
                  selectedItemType = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 5. Product Type (Dropdown)
            _buildDropdownField(
              label: 'Product Type',
              value: selectedProductType,
              items: productTypeOptions,
              onChanged: (value) {
                setState(() {
                  selectedProductType = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 6. Product Line / Sub-Category (Dropdown)
            _buildDropdownField(
              label: 'Product Line / Sub-Category',
              value: selectedProductLine,
              items: productLineOptions,
              onChanged: (value) {
                setState(() {
                  selectedProductLine = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 7. Option (Text Field)
            _buildTextField(
              controller: optionController,
              label: 'Option',
              hint: 'Enter option',
            ),
            const SizedBox(height: 16),

            // 8. Unit of Measurement (Dropdown)
            _buildDropdownField(
              label: 'Unit of Measurement',
              value: selectedUOM,
              items: uomOptions,
              onChanged: (value) {
                setState(() {
                  selectedUOM = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 9. Item Price (Text Field - Number)
            _buildTextField(
              controller: itemPriceController,
              label: 'Item Price',
              hint: 'Enter price',
              keyboardType: TextInputType.number,
              prefixText: '৳ ',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 10. Item Size (Text Field)
            _buildTextField(
              controller: itemSizeController,
              label: 'Item Size',
              hint: 'e.g., 60x30',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 11. Approved Date (Date Picker)
            _buildDatePickerField(
              label: 'Approved Date',
              selectedDate: selectedApprovedDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedApprovedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    selectedApprovedDate = picked;
                  });
                }
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 12. Item Sample No (Text Field)
            _buildTextField(
              controller: itemSampleNoController,
              label: 'Item Sample No',
              hint: 'Enter sample number',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 13. Remarks (Text Field - Multi-line)
            _buildTextField(
              controller: remarksController,
              label: 'Remarks',
              hint: 'Enter remarks',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 14. Active/Inactive (Dropdown)
            _buildDropdownField(
              label: 'Active/Inactive',
              value: selectedStatus,
              items: statusOptions,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 15. Blur/Sharpen (Dropdown)
            _buildDropdownField(
              label: 'Blur/Sharpen',
              value: selectedBlur,
              items: blurOptions,
              onChanged: (value) {
                setState(() {
                  selectedBlur = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // 16. Fix/UnFix (Dropdown)
            _buildDropdownField(
              label: 'Fix/UnFix',
              value: selectedFix,
              items: fixOptions,
              onChanged: (value) {
                setState(() {
                  selectedFix = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 24),

            // Submit Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper: Build Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade700),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Helper: Build Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Select $label'),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Helper: Build Date Picker Field
  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Select date'
                        : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(
                      color: selectedDate == null ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _resetForm() {
    setState(() {
      selectedBrand = null;
      subBrandController.clear();
      itemReferenceController.clear();
      selectedItemType = null;
      selectedProductType = null;
      selectedProductLine = null;
      optionController.clear();
      selectedUOM = null;
      itemPriceController.clear();
      itemSizeController.clear();
      selectedApprovedDate = null;
      itemSampleNoController.clear();
      remarksController.clear();
      selectedStatus = null;
      selectedBlur = null;
      selectedFix = null;
    });
  }

  void _submitForm() {
    // Validate required fields
    if (selectedBrand == null) {
      _showError('Please select Brand');
      return;
    }
    if (subBrandController.text.trim().isEmpty) {
      _showError('Please enter Sub-Brand');
      return;
    }
    if (selectedItemType == null) {
      _showError('Please select Item Type');
      return;
    }
    if (selectedProductType == null) {
      _showError('Please select Product Type');
      return;
    }
    if (selectedProductLine == null) {
      _showError('Please select Product Line');
      return;
    }
    if (selectedUOM == null) {
      _showError('Please select Unit of Measurement');
      return;
    }
    if (itemPriceController.text.trim().isEmpty) {
      _showError('Please enter Item Price');
      return;
    }
    if (itemSizeController.text.trim().isEmpty) {
      _showError('Please enter Item Size');
      return;
    }
    if (selectedApprovedDate == null) {
      _showError('Please select Approved Date');
      return;
    }
    if (itemSampleNoController.text.trim().isEmpty) {
      _showError('Please enter Item Sample No');
      return;
    }
    if (selectedStatus == null) {
      _showError('Please select Status');
      return;
    }
    if (selectedBlur == null) {
      _showError('Please select Blur/Sharpen option');
      return;
    }
    if (selectedFix == null) {
      _showError('Please select Fix/UnFix option');
      return;
    }

    // Collect all data
    final formData = {
      'brand': selectedBrand,
      'subBrand': subBrandController.text.trim(),
      'itemReference': itemReferenceController.text.trim(),
      'itemType': selectedItemType,
      'productType': selectedProductType,
      'productLine': selectedProductLine,
      'option': optionController.text.trim(),
      'uom': selectedUOM,
      'itemPrice': double.tryParse(itemPriceController.text.trim()) ?? 0,
      'itemSize': itemSizeController.text.trim(),
      'approvedDate': selectedApprovedDate,
      'itemSampleNo': itemSampleNoController.text.trim(),
      'remarks': remarksController.text.trim(),
      'status': selectedStatus,
      'blur': selectedBlur,
      'fix': selectedFix,
    };

    print('Form Data: $formData');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}