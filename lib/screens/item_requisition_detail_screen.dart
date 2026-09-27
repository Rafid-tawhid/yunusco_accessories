import 'package:flutter/material.dart';

import '../helper_class/api_service_class.dart';
import '../helper_class/user_data.dart';
import '../models/item_req_detail_model.dart';
import '../theme/app_theme.dart';

class ItemRequisitionDetailScreen extends StatefulWidget {
  const ItemRequisitionDetailScreen({super.key, required this.requisitionId});

  final num requisitionId;

  @override
  State<ItemRequisitionDetailScreen> createState() =>
      _ItemRequisitionDetailScreenState();
}

class _ItemRequisitionDetailScreenState
    extends State<ItemRequisitionDetailScreen> {
  final ApiService _api = ApiService();
  ItemReqDetailModel? _requisition;
  String? _error;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadRequisition();
  }

  Future<void> _loadRequisition() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final requisition = await _api.getManagementMaterialRequisition(
        widget.requisitionId,
      );
      if (!mounted) return;
      setState(() {
        _requisition = requisition;
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
    final requisition = _requisition;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(requisition?.requisitionNo ?? 'Requisition details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : requisition == null
          ? _buildError()
          : _buildDetails(requisition),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Requisition details are unavailable.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadRequisition,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(ItemReqDetailModel requisition) {
    final canDecide = requisition.status == 0 && !_isProcessing;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(requisition: requisition),
              const SizedBox(height: 18),
              Text(
                'Requested items (${requisition.details.length})',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (requisition.details.isEmpty)
                const _InfoCard(child: Text('No item details were returned.'))
              else
                ...requisition.details.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LineCard(line: line),
                  ),
                ),
              if (requisition.rejectReason?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _InfoCard(
                  child: _InfoRow(
                    icon: Icons.comment_outlined,
                    label: 'Decision note',
                    value: requisition.rejectReason!.trim(),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (requisition.status == 0)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canDecide
                          ? () => _submitDecision(requisition, 'Reject')
                          : null,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canDecide
                          ? () => _submitDecision(requisition, 'Approve')
                          : null,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

  Future<void> _submitDecision(
    ItemReqDetailModel requisition,
    String decision,
  ) async {
    final decidedBy = UserData.user.userId;
    if (decidedBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your user ID is not available. Please sign in again.'),
        ),
      );
      return;
    }

    final comment = await _requestComment(decision);
    if (comment == null || !mounted) return;
    setState(() => _isProcessing = true);

    try {
      await _api.decideMaterialRequisition(
        ItemReqDecisionRequest(
          id: requisition.materialRequisitionMasterId ?? widget.requisitionId,
          decision: decision,
          comment: comment,
          decidedBy: decidedBy.toString(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Requisition ${decision == 'Approve' ? 'approved' : 'rejected'}.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not ${decision.toLowerCase()} requisition: $error',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<String?> _requestComment(String decision) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          String? validationError;
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text('$decision requisition?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    decision == 'Reject'
                        ? 'Add a note explaining why this requisition is rejected.'
                        : 'Add an optional note for this approval.',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: decision == 'Reject'
                          ? 'Rejection note'
                          : 'Optional note',
                      errorText: validationError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final comment = controller.text.trim();
                    if (decision == 'Reject' && comment.isEmpty) {
                      setDialogState(
                        () => validationError = 'A rejection note is required.',
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, comment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decision == 'Approve'
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                  child: Text(decision),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.requisition});

  final ItemReqDetailModel requisition;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.receipt_long_rounded,
            label: 'Requisition',
            value: requisition.requisitionNo ?? '—',
          ),
          _InfoRow(
            icon: Icons.info_outline_rounded,
            label: 'Status',
            value: _statusLabel(requisition.status),
          ),
          if (requisition.submittedBy?.isNotEmpty == true)
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Submitted by',
              value: requisition.submittedBy!,
            ),
          if (requisition.decidedBy?.isNotEmpty == true)
            _InfoRow(
              icon: Icons.verified_user_outlined,
              label: 'Decided by',
              value: requisition.decidedBy!,
            ),
          if (requisition.decidedDate?.isNotEmpty == true)
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Decision date',
              value: requisition.decidedDate!,
            ),
        ],
      ),
    );
  }

  String _statusLabel(num? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return status?.toString() ?? 'Unknown';
    }
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.line});

  final ItemReqLineModel line;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.itemName?.isNotEmpty == true
                ? line.itemName!
                : 'Item ${line.itemId ?? ''}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.numbers_rounded,
            label: 'Quantity',
            value: '${line.quantity ?? '—'} ${line.unitId ?? ''}'.trim(),
          ),
          if (line.buyerName?.isNotEmpty == true)
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Buyer',
              value: line.buyerName!,
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 9),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
