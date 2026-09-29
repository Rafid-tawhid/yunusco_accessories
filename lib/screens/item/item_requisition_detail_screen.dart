import 'package:flutter/material.dart';

import '../../helper_class/api_service_class.dart';
import '../../helper_class/user_data.dart';
import '../../models/item_req_detail_model.dart';
import '../../theme/app_theme.dart';


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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          requisition?.requisitionNo ?? 'Requisition details',
          style: const TextStyle(fontSize: 16),
        ),
        toolbarHeight: 52,
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
              size: 40,
              color: AppColors.danger,
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Requisition details are unavailable.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadRequisition,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 36),
              ),
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
            padding: const EdgeInsets.all(12),
            children: [
              _SummaryCard(requisition: requisition),
              const SizedBox(height: 12),
              Text(
                'Requested items (${requisition.details.length})',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              if (requisition.details.isEmpty)
                const _InfoCard(
                  child: Text(
                    'No item details were returned.',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else
                ...requisition.details.map(
                      (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _LineCard(line: line),
                  ),
                ),
              if (requisition.rejectReason?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 6),
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
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canDecide
                          ? () => _submitDecision(requisition, 'Reject')
                          : null,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canDecide
                          ? () => _submitDecision(requisition, 'Approve')
                          : null,
                      icon: _isProcessing
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(0, 40),
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
    return showDialog<String>(
      context: context,
      builder: (_) => _DecisionCommentDialog(decision: decision),
    );
  }
}

// ---------------------------------------------------------------------------
// Decision comment dialog
// ---------------------------------------------------------------------------
class _DecisionCommentDialog extends StatefulWidget {
  const _DecisionCommentDialog({required this.decision});

  final String decision;

  @override
  State<_DecisionCommentDialog> createState() => _DecisionCommentDialogState();
}

class _DecisionCommentDialogState extends State<_DecisionCommentDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decision = widget.decision;
    return AlertDialog(
      title: Text('$decision requisition?', style: const TextStyle(fontSize: 16)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            decision == 'Reject'
                ? 'Add a note explaining why this requisition is rejected.'
                : 'Add an optional note for this approval.',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText:
              decision == 'Reject' ? 'Rejection note' : 'Optional note',
              errorText: _validationError,
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: .5),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 13)),
        ),
        ElevatedButton(
          onPressed: () {
            final comment = _controller.text.trim();
            if (decision == 'Reject' && comment.isEmpty) {
              setState(
                    () => _validationError = 'A rejection note is required.',
              );
              return;
            }
            Navigator.pop(context, comment);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
            decision == 'Approve' ? AppColors.success : AppColors.danger,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 36),
            textStyle: const TextStyle(fontSize: 13),
          ),
          child: Text(decision),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card — 2-column compact grid
// ---------------------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.requisition});

  final ItemReqDetailModel requisition;

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      //['Requisition', requisition.requisitionNo ?? '—'],
      ['Status', _statusLabel(requisition.status)],
      if (requisition.submittedBy?.isNotEmpty == true)
        ['Submitted by', requisition.submittedBy!],
      if (requisition.requisitionDate?.isNotEmpty == true)
        ['Requisition date', _formatDate(requisition.requisitionDate!)],
      if (requisition.totalQuantity != null)
        ['Total quantity', _formatQuantity(requisition.totalQuantity!)],
      if (requisition.remarks?.trim().isNotEmpty == true)
        ['Remarks', requisition.remarks!.trim()],
      // if (requisition.isLocked != null)
      //   ['Locked', requisition.isLocked! ? 'Yes' : 'No'],
      // if (requisition.createdDate?.isNotEmpty == true)
      //   ['Created date', _formatDate(requisition.createdDate!)],
      // if (requisition.decidedBy?.isNotEmpty == true)
      //   ['Decided by', requisition.decidedBy!],
      // if (requisition.decidedDate?.isNotEmpty == true)
      //   ['Decision date', _formatDate(requisition.decidedDate!)],
    ];

    final borderColor = AppColors.textSecondary.withValues(alpha: 0.35);

    return Table(
      border: TableBorder.all(
        color: borderColor,
        width: 0.8,
      ),
      columnWidths: const {
        0: FlexColumnWidth(0.42),
        1: FlexColumnWidth(0.58),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final row in rows)
          TableRow(
            children: [
              Container(
                color: AppColors.background.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Text(
                  row[0],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Text(
                  row[1],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
      ],
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

class _KV {
  final String label;
  final String value;
  const _KV(this.label, this.value);
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.item});
  final _KV item;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
          height: 1.25,
        ),
        children: [
          TextSpan(
            text: '${item.label}: ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextSpan(
            text: item.value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item line — compact single card with collapsible history
// ---------------------------------------------------------------------------
class _LineCard extends StatelessWidget {
  const _LineCard({required this.line});

  final ItemReqLineModel line;

  @override
  Widget build(BuildContext context) {
    final title = line.itemName?.isNotEmpty == true
        ? line.itemName!
        : 'Item ${line.itemId ?? ''}';
    final qty = line.quantity == null
        ? '—'
        : '${_formatQuantity(line.quantity!)} ${line.unitId ?? ''}'.trim();
    final buyer = line.buyerName?.isNotEmpty == true
        ? line.buyerName!
        : (line.buyerId?.isNotEmpty == true ? line.buyerId! : '—');

    return _InfoCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${line.lineNo ?? '-'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  qty,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            [
              'Buyer: $buyer',
              if (line.itemId?.isNotEmpty == true) 'ID: ${line.itemId}',
              if (line.createdByName?.isNotEmpty == true)
                'By: ${line.createdByName}',
            ].join('   •   '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          if (line.last6MonthsHistory.isNotEmpty) ...[
            const SizedBox(height: 2),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 4),
                dense: true,
                visualDensity: VisualDensity.compact,
                minTileHeight: 32,
                iconColor: AppColors.textSecondary,
                collapsedIconColor: AppColors.textSecondary,
                title: const Text(
                  'Last 6 months',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                children: [
                  _HistoryStrip(
                    history: line.last6MonthsHistory,
                    unit: line.unitId,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History as horizontal chips
// ---------------------------------------------------------------------------
class _HistoryStrip extends StatelessWidget {
  const _HistoryStrip({required this.history, this.unit});

  final List<ItemReqHistoryModel> history;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final h = history[i];
          final month = h.monthNo?.toInt();
          final year = h.yearNo?.toInt();
          final label = month != null && month >= 1 && month <= 12
              ? '${_monthNames[month - 1]} ${year ?? ''}'.trim()
              : '—';
          final qty = h.quantity == null
              ? '—'
              : '${_formatQuantity(h.quantity!)}'
              '${unit?.isNotEmpty == true ? ' $unit' : ''}';

          return Container(
            width: 86,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  qty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatQuantity(num quantity) {
  return quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();
}

String _formatCurrency(num amount) {
  final value = amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
  return '\$$value';
}

String _formatDate(String value) {
  final match = RegExp(r'^/Date\((-?\d+)(?:[+-]\d{4})?\)/$').firstMatch(value);
  final date = match == null
      ? DateTime.tryParse(value)
      : DateTime.fromMillisecondsSinceEpoch(int.parse(match.group(1)!));
  if (date == null) return value;
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}