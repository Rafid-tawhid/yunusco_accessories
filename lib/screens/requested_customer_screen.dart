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

enum _CustomerFilter { pending, confirmed, rejected }

class _RequestedCustomerScreenState extends State<RequestedCustomerScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<RequestedCustomerModel> _customers = [];
  bool _isLoading = true;
  _CustomerFilter _filter = _CustomerFilter.pending;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    _fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // Status: null/0 = pending, 1 = confirmed, 2 = rejected
  _CustomerStatus _statusOf(RequestedCustomerModel c) {
    final v = c.isConfirmManagement;
    if (v == 1) return _CustomerStatus.confirmed;
    if (v == 2) return _CustomerStatus.rejected;
    return _CustomerStatus.pending; // null or 0
  }

  List<RequestedCustomerModel> get _filteredCustomers {
    return _customers.where((c) {
      final status = _statusOf(c);
      switch (_filter) {
        case _CustomerFilter.pending:
          if (status != _CustomerStatus.pending) return false;
          break;
        case _CustomerFilter.confirmed:
          if (status != _CustomerStatus.confirmed) return false;
          break;
        case _CustomerFilter.rejected:
          if (status != _CustomerStatus.rejected) return false;
          break;
      }

      if (_searchQuery.isEmpty) return true;
      final name = (c.yTACustomerName ?? c.yTABillToCompanyName ?? '').toLowerCase();
      final phone = (c.yTABillToCellNo ?? c.yTABillToTelephone ?? '').toLowerCase();
      final email = (c.yTACustomerEmail?.toString() ?? '').toLowerCase();
      return name.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          email.contains(_searchQuery);
    }).toList();
  }

  int get _pendingCount =>
      _customers.where((c) => _statusOf(c) == _CustomerStatus.pending).length;
  int get _confirmedCount =>
      _customers.where((c) => _statusOf(c) == _CustomerStatus.confirmed).length;
  int get _rejectedCount =>
      _customers.where((c) => _statusOf(c) == _CustomerStatus.rejected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Requested Customers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            _fetchCustomers();
          }, icon: Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ─────────────────────── Search & Filter ───────────────────────
  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search name, phone or email',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: AppColors.textSecondary,
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          Row(
            children: [
              _filterChip('Pending', _CustomerFilter.pending, _pendingCount),
              const SizedBox(width: 8),
              _filterChip('Confirmed', _CustomerFilter.confirmed, _confirmedCount),
              const SizedBox(width: 8),
              _filterChip('Rejected', _CustomerFilter.rejected, _rejectedCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _CustomerFilter value, int count) {
    final selected = _filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Center(
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── Body ───────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: _SkeletonCard(),
        ),
      );
    }

    final list = _filteredCustomers;

    if (list.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final customer = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FadeSlideIn.staggered(
            index: index,
            child: _CustomerCard(
              customer: customer,
              onTap: () => _showDetails(customer),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    final hasSearch = _searchQuery.isNotEmpty;
    final title = hasSearch ? 'No matching customers' : 'No requested customers yet';
    final subtitle = hasSearch
        ? 'Try a different search or filter'
        : 'New requests will appear here';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off_rounded : Icons.people_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetails(RequestedCustomerModel customer) async {
    // Pending = management decision not yet made
    final isPending = _statusOf(customer) == _CustomerStatus.pending;

    await Navigator.push(
      context,
      AppTheme.pageRoute(
        CustomerProfileDetailScreen(
          customerId: customer.yTACustomerId!.toInt(),
          isPending: isPending,
        ),
      ),
    );
    _fetchCustomers();
  }
}

// ─────────────────────────── Status ───────────────────────────
enum _CustomerStatus { pending, confirmed, rejected }

// ─────────────────────────── Card ───────────────────────────
class _CustomerCard extends StatelessWidget {
  final RequestedCustomerModel customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  // null/0 = pending, 1 = confirmed, 2 = rejected
  _CustomerStatus get _status {
    final v = customer.isConfirmManagement;
    if (v == 1) return _CustomerStatus.confirmed;
    if (v == 2) return _CustomerStatus.rejected;
    return _CustomerStatus.pending;
  }

  String get _statusLabel {
    switch (_status) {
      case _CustomerStatus.confirmed:
        return 'Confirmed';
      case _CustomerStatus.rejected:
        return 'Rejected';
      case _CustomerStatus.pending:
        return 'Pending';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case _CustomerStatus.confirmed:
        return AppColors.success;
      case _CustomerStatus.rejected:
        return AppColors.error;
      case _CustomerStatus.pending:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = customer.yTACustomerName ??
        customer.yTABillToCompanyName ??
        'Unknown Customer';
    final contact = customer.yTABillToCellNo ?? customer.yTABillToTelephone;
    final email = customer.yTACustomerEmail?.toString();
    final initials = _initialsOf(name);

    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusPill(),
                ],
              ),
              if (contact != null && contact.isNotEmpty) ...[
                const SizedBox(height: 8),
                _infoRow(Icons.phone_outlined, contact),
              ],
              if (email != null && email.isNotEmpty) ...[
                const SizedBox(height: 4),
                _infoRow(Icons.email_outlined, email),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          fontSize: 10,
          color: _statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ─────────────────────────── Skeleton ───────────────────────────
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = 0.4 + (_controller.value * 0.4);
        final base = AppColors.divider.withOpacity(t * 0.5);

        Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(5),
          ),
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: base, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(120, 12),
                    const SizedBox(height: 6),
                    bar(90, 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}