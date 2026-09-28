import 'package:flutter/material.dart';

import '../helper_class/api_service_class.dart';
import '../models/item_req_model.dart';
import '../theme/app_theme.dart';
import 'item_requisition_detail_screen.dart';

class ItemRequisitionsScreen extends StatefulWidget {
  const ItemRequisitionsScreen({super.key});

  @override
  State<ItemRequisitionsScreen> createState() => _ItemRequisitionsScreenState();
}

enum _ReqFilter { pending, approved, rejected }

class _ItemRequisitionsScreenState extends State<ItemRequisitionsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ItemReqModel> _requisitions = [];
  bool _isLoading = true;
  String? _error;

  _ReqFilter _filter = _ReqFilter.pending;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    _fetchRequisitions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequisitions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requisitions =
      await _apiService.getPendingMaterialRequisitionsNew();
      if (!mounted) return;
      setState(() {
        _requisitions = requisitions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  int _statusOf(ItemReqModel r) => r.status?.toInt() ?? 0;

  List<ItemReqModel> get _filteredRequisitions {
    return _requisitions.where((r) {
      // Filter chip
      final status = _statusOf(r);
      switch (_filter) {
        case _ReqFilter.pending:
          if (status != 0) return false;
          break;
        case _ReqFilter.approved:
          if (status != 1) return false;
          break;
        case _ReqFilter.rejected:
          if (status != 2) return false;
          break;
      }

      // Search query
      if (_searchQuery.isEmpty) return true;
      final no = (r.requisitionNo ?? '').toLowerCase();
      final date = (r.requisitionDate ?? '').toLowerCase();
      final by = (r.submittedBy ?? '').toLowerCase();
      final remarks = (r.remarks ?? '').toLowerCase();
      return no.contains(_searchQuery) ||
          date.contains(_searchQuery) ||
          by.contains(_searchQuery) ||
          remarks.contains(_searchQuery);
    }).toList();
  }

  int get _pendingCount => _requisitions.where((r) => _statusOf(r) == 0).length;
  int get _approvedCount => _requisitions.where((r) => _statusOf(r) == 1).length;
  int get _rejectedCount => _requisitions.where((r) => _statusOf(r) == 2).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Item Requisitions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchRequisitions,
            icon: const Icon(Icons.refresh_rounded),
          ),
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
                hintText: 'Search requisition no, submitter...',
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
              _filterChip('Pending', _ReqFilter.pending, _pendingCount),
              const SizedBox(width: 8),
              _filterChip('Approved', _ReqFilter.approved, _approvedCount),
              const SizedBox(width: 8),
              _filterChip('Rejected', _ReqFilter.rejected, _rejectedCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _ReqFilter value, int count) {
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
                fontSize: 11.5,
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildMessage(
        icon: Icons.error_outline_rounded,
        message: 'Unable to load requisitions.\n$_error',
      );
    }

    final list = _filteredRequisitions;

    if (list.isEmpty) {
      return _buildMessage(
        icon: _requisitions.isEmpty
            ? Icons.inventory_2_outlined
            : Icons.search_off_rounded,
        message: _requisitions.isEmpty
            ? 'No item requisitions found'
            : 'No matching requisitions',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRequisitions,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        itemCount: list.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RequisitionCard(
            requisition: list[index],
            onTap: () => _openDetails(list[index]),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(ItemReqModel requisition) async {
    final id = requisition.materialRequisitionMasterId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requisition ID is missing.')),
      );
      return;
    }

    final decided = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemRequisitionDetailScreen(requisitionId: id),
      ),
    );
    if (decided == true && mounted) {
      await _fetchRequisitions();
    }
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
  }) {
    return RefreshIndicator(
      onRefresh: _fetchRequisitions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
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
                        icon,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status meta helper — 0: Pending, 1: Approved, 2: Rejected
class _StatusMeta {
  final String label;
  final Color color;

  const _StatusMeta({required this.label, required this.color});

  static _StatusMeta fromStatus(int? status) {
    switch (status) {
      case 1:
        return const _StatusMeta(
          label: 'Approved',
          color: AppColors.success,
        );
      case 2:
        return _StatusMeta(
          label: 'Rejected',
          color: AppColors.error,
        );
      case 0:
      default:
        return const _StatusMeta(
          label: 'Pending',
          color: AppColors.warning,
        );
    }
  }
}

class _RequisitionCard extends StatelessWidget {
  const _RequisitionCard({required this.requisition, required this.onTap});

  final ItemReqModel requisition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final requisitionNo = requisition.requisitionNo?.trim();
    final date = requisition.requisitionDate?.trim();
    final status = _StatusMeta.fromStatus(requisition.status!.toInt());
    final submittedBy = requisition.submittedBy?.trim();
    final remarks = requisition.remarks?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requisitionNo?.isNotEmpty == true
                              ? requisitionNo!
                              : 'Requisition',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (date?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            date!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusPill(status),
                ],
              ),
              if (requisition.totalQuantity != null ||
                  submittedBy?.isNotEmpty == true ||
                  remarks?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                if (requisition.totalQuantity != null)
                  _infoRow(Icons.inventory_2_outlined,
                      'Qty: ${requisition.totalQuantity}'),
                if (submittedBy?.isNotEmpty == true) ...[
                  if (requisition.totalQuantity != null)
                    const SizedBox(height: 4),
                  _infoRow(Icons.person_outline_rounded, submittedBy!),
                ],
                if (remarks?.isNotEmpty == true) ...[
                  if (requisition.totalQuantity != null ||
                      submittedBy?.isNotEmpty == true)
                    const SizedBox(height: 4),
                  _infoRow(Icons.notes_rounded, remarks!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(_StatusMeta status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          color: status.color,
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
}