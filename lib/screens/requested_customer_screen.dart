import 'package:flutter/material.dart';
import '../helper_class/api_service_class.dart';
import '../models/requested_customer_model.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import 'customer_profile_details_screen.dart';

class RequestedCustomerScreen extends StatefulWidget {
  const RequestedCustomerScreen({super.key});

  @override
  State<RequestedCustomerScreen> createState() => _RequestedCustomerScreenState();
}

class _RequestedCustomerScreenState extends State<RequestedCustomerScreen> {
  final ApiService _apiService = ApiService();
  List<RequestedCustomerModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    final customers = await _apiService.getRequestedCustomers();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Requested Customers'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : _customers.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    key: const ValueKey('list'),
                    onRefresh: _fetchCustomers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FadeSlideIn.staggered(
                            index: index,
                            child: _CustomerCard(
                              customer: customer,
                              onTap: () => _showDetails(customer),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded, size: 42, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No requested customers found',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetails(RequestedCustomerModel customer) async {
    final isPending = customer.isConfirm == true && customer.isConfirmManagement != 1;

    await Navigator.push(
      context,
      AppTheme.pageRoute(
        CustomerProfileDetailScreen(
          customerId: customer.yTACustomerId!.toInt(),
          isPending: isPending,
        ),
      ),
    );
    // Refresh in case the item was accepted/rejected on the detail screen.
    _fetchCustomers();
  }
}

class _CustomerCard extends StatelessWidget {
  final RequestedCustomerModel customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  String? _resolveStatus() {
    // if (customer.isConfirm == true) return 'Confirmed';
    if (customer.isConfirmManagement == 1) {
      return 'Mgmt Confirmed';
    } else {
      return 'Pending';
    }

  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Mgmt Confirmed':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = customer.yTACustomerName ?? customer.yTABillToCompanyName ?? 'Unknown Customer';
    final contact = customer.yTABillToCellNo ?? customer.yTABillToTelephone;
    final email = customer.yTACustomerEmail?.toString();
    final status = _resolveStatus();

    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(fontSize: 10.5, color: _statusColor(status), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    if (contact != null && contact.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(contact, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(email, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
