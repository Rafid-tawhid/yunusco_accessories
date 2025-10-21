import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../riverpod/data_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? selectedRbo;
  Map<String, dynamic>? selectedItem;
  final TextEditingController _searchController = TextEditingController(); // Add this

  @override
  void dispose() {
    _searchController.dispose(); // Don't forget to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rboAsync = ref.watch(rboProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C5530),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: rboAsync.when(
          data: (rboList) {
            if (rboList.isEmpty) {
              return const Center(child: Text('No RBO data found.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select RBO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                DropdownButtonHideUnderline(
                  child: DropdownButton2<Map<String, dynamic>>(
                    isExpanded: true,
                    hint: const Text("Choose an RBO"),
                    value: selectedRbo,
                    items: rboList.map((rbo) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: rbo,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFF2C5530),
                              child: Text(
                                rbo['RboId'].toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(rbo['RboName'] ?? '',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRbo = value;
                        selectedItem = null;
                        _searchController.clear(); // Clear search when RBO changes
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                        color: Colors.white,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      offset: const Offset(0, 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (selectedRbo != null) ...[
                  const Text(
                    "Select Item",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  Consumer(
                    builder: (context, ref, _) {
                      final itemAsync =
                      ref.watch(itemsProvider(selectedRbo!['RboId']));

                      return itemAsync.when(
                        data: (itemList) {
                          if (itemList.isEmpty) {
                            return const Text(
                                "No items found for this RBO.");
                          }

                          return DropdownButtonHideUnderline(
                            child: DropdownButton2<Map<String, dynamic>>(
                              isExpanded: true,
                              hint: const Text("Choose an Item"),
                              value: selectedItem,
                              items: itemList.map((item) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: item,
                                  child: Text(
                                    item['ItemRef'] ?? '',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedItem = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Selected Item: ${value?['ItemRef'] ?? ''}")),
                                );
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                  color: Colors.white,
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 300,
                                offset: const Offset(0, 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                              dropdownSearchData: DropdownSearchData(
                                searchController: _searchController, // Use the same controller
                                searchInnerWidgetHeight: 50,
                                searchInnerWidget: Container(
                                  height: 50,
                                  padding: const EdgeInsets.all(8),
                                  child: TextFormField(
                                    controller: _searchController, // Use the same controller
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search item...',
                                      hintStyle: const TextStyle(fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return item.value!['ItemRef']
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchValue.toLowerCase());
                                },
                              ),
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  _searchController.clear(); // Clear search when dropdown closes
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          );
                        },
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (error, _) =>
                            Text('Error loading items: $error'),
                      );
                    },
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error: $error', style: TextStyle(color: Colors.red))),
        ),
      ),
    );
  }
}