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

class _ItemRequisitionsScreenState extends State<ItemRequisitionsScreen> {
  final ApiService _apiService = ApiService();
  List<ItemReqModel> _requisitions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequisitions();
  }

  Future<void> _fetchRequisitions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requisitions = await _apiService
          .getPendingMaterialRequisitionsNew();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pending Item Requisitions'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isLoading
            ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              )
            : _error != null
            ? _buildMessage(
                key: const ValueKey('error'),
                icon: Icons.error_outline_rounded,
                message: 'Unable to load requisitions.\n$_error',
              )
            : _requisitions.isEmpty
            ? _buildMessage(
                key: const ValueKey('empty'),
                icon: Icons.inventory_2_outlined,
                message: 'No pending item requisitions found',
              )
            : RefreshIndicator(
                key: const ValueKey('list'),
                onRefresh: _fetchRequisitions,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  itemCount: _requisitions.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RequisitionCard(
                      requisition: _requisitions[index],
                      onTap: () => _openDetails(_requisitions[index]),
                    ),
                  ),
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
    required Key key,
    required IconData icon,
    required String message,
  }) {
    return RefreshIndicator(
      key: key,
      onRefresh: _fetchRequisitions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 46, color: AppColors.textSecondary),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
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

class _RequisitionCard extends StatelessWidget {
  const _RequisitionCard({required this.requisition, required this.onTap});

  final ItemReqModel requisition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final requisitionNo = requisition.requisitionNo?.trim();
    final date = requisition.requisitionDate?.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    requisitionNo?.isNotEmpty == true
                        ? requisitionNo!
                        : 'Requisition',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (requisition.isLocked == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (date?.isNotEmpty == true)
              _RequisitionDetail(
                icon: Icons.calendar_today_rounded,
                label: date!,
              ),
            if (requisition.totalQuantity != null)
              _RequisitionDetail(
                icon: Icons.inventory_2_outlined,
                label: 'Total quantity: ${requisition.totalQuantity}',
              ),
            if (requisition.remarks?.trim().isNotEmpty == true)
              _RequisitionDetail(
                icon: Icons.notes_rounded,
                label: requisition.remarks!.trim(),
              ),
            if (requisition.submittedBy?.trim().isNotEmpty == true)
              _RequisitionDetail(
                icon: Icons.person_outline_rounded,
                label: 'Submitted by ${requisition.submittedBy!.trim()}',
              ),
            if (requisition.status != null)
              _RequisitionDetail(
                icon: Icons.info_outline_rounded,
                label: 'Status: ${requisition.status}',
              ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'See details',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequisitionDetail extends StatelessWidget {
  const _RequisitionDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
