import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/screens/create_costing_screen.dart';
import '../riverpod/items_provider.dart';
import '../widgets/item_card.dart';
import '../models/items_model.dart';
import 'edit_item_screen.dart';

// ============================================
// ITEMS LIST SCREEN - Main screen to display all items
// ============================================

class ItemsListScreen extends ConsumerStatefulWidget {
  const ItemsListScreen({super.key});

  @override
  ConsumerState<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends ConsumerState<ItemsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchTermProvider.notifier).state = _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsListProvider);
    final filteredItems = ref.watch(categoryFilteredItemsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isLoading = itemsAsync.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Items List'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(itemsListProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, code...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchTermProvider.notifier).state = '';
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(itemsAsync, filteredItems, isLoading),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody(
      AsyncValue<List<ItemsModel>> itemsAsync,
      List<ItemsModel> filteredItems,
      bool isLoading,
      ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (itemsAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              itemsAsync.error.toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(itemsListProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty ? 'No matching items found' : 'No items available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(itemsListProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return ItemCard(
            item: item,
            onTap: () => _showItemDetails(context, item),
            onFavorite: () => _toggleFavorite(item),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Colors.blue.shade700,
      child: const Icon(Icons.arrow_upward, color: Colors.white),
    );
  }

  void _showItemDetails(BuildContext context, ItemsModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ItemDetailsSheet(item: item);
      },
    );
  }

  void _toggleFavorite(ItemsModel item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${item.displayName} to favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ============================================
// ITEM DETAILS SHEET - Shows full item information
// ============================================

class _ItemDetailsSheet extends StatefulWidget {
  final ItemsModel item;

  const _ItemDetailsSheet({
    required this.item,
  });

  @override
  State<_ItemDetailsSheet> createState() => _ItemDetailsSheetState();
}

class _ItemDetailsSheetState extends State<_ItemDetailsSheet> {
  late final TextEditingController _priceController;
  late final TextEditingController _commissionController;
  late final TextEditingController _remarksController;
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _commissionFocusNode = FocusNode();
  final FocusNode _remarksFocusNode = FocusNode();
  bool _isUpdating = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _priceController = TextEditingController(
      text: widget.item.basicPrice?.toStringAsFixed(2) ?? '',
    );
    _commissionController = TextEditingController(
      text: '0',
    );
    _remarksController = TextEditingController(
      text: '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _commissionController.dispose();
    _remarksController.dispose();
    _priceFocusNode.dispose();
    _commissionFocusNode.dispose();
    _remarksFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateDetails() async {
    final String priceText = _priceController.text.trim();
    final String commissionText = _commissionController.text.trim();
    final String remarks = _remarksController.text.trim();

    double? newPrice;
    if (priceText.isNotEmpty) {
      newPrice = double.tryParse(priceText);
      if (newPrice == null) {
        _showErrorSnackBar('Please enter a valid price');
        return;
      }
      if (newPrice < 0) {
        _showErrorSnackBar('Price cannot be negative');
        return;
      }
    }

    double? commission;
    if (commissionText.isNotEmpty) {
      commission = double.tryParse(commissionText);
      if (commission == null) {
        _showErrorSnackBar('Please enter a valid commission');
        return;
      }
      if (commission < 0) {
        _showErrorSnackBar('Commission cannot be negative');
        return;
      }
      if (commission > 100) {
        _showErrorSnackBar('Commission cannot exceed 100%');
        return;
      }
    }

    setState(() => _isUpdating = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Details updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _priceFocusNode.unfocus();
        _commissionFocusNode.unfocus();
        _remarksFocusNode.unfocus();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update details');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with status indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.itemRef.toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.item.isActive == 'T'
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.item.isActive == 'T' ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: widget.item.isActive == 'T'
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Basic Information Card
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow('Name', widget.item.itemName ?? 'N/A'),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 8),
                            _buildDetailRow('Size', widget.item.size ?? 'N/A'),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 8),
                            _buildDetailRow('Material', widget.item.materialDesc ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Update Details Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.indigo.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price Field
                          const Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceController,
                            focusNode: _priceFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            // Only numbers and decimal allowed
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],

                            decoration: InputDecoration(
                              hintText: 'Enter price',
                              prefixStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Commission Field
                          const Text(
                            'Commission (%)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commissionController,
                            focusNode: _commissionFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            // Only numbers and decimal allowed
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter commission percentage',
                              suffixText: '%',
                              suffixStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Remarks Field
                          const Text(
                            'Remarks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _remarksController,
                            focusNode: _remarksFocusNode,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter remarks here...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isUpdating ? null : _updateDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isUpdating
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Update Details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.grey.shade900,
                fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}