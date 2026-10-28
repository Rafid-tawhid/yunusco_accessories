import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/user_session.dart';
import '../../models/item_req_detail_model.dart';
import '../../presentation/providers/repository_providers.dart';
import '../../theme/app_theme.dart';

class ItemRequisitionDetailScreen extends ConsumerStatefulWidget {
  const ItemRequisitionDetailScreen({super.key, required this.requisitionId});

  final num requisitionId;

  @override
  ConsumerState<ItemRequisitionDetailScreen> createState() =>
      _ItemRequisitionDetailScreenState();
}

class _ItemRequisitionDetailScreenState
    extends ConsumerState<ItemRequisitionDetailScreen> {
  ItemReqDetailModel? _requisition;
  String? _error;
  bool _isLoading = true;
  bool _isProcessing = false;

  // approved qty per line, keyed by a stable line key
  final Map<String, num> _approvedQty = {};

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
      final requisition = await ref
          .read(itemRepositoryProvider)
          .getMaterialRequisitionDetails(widget.requisitionId);
      if (!mounted) return;
      setState(() {
        _requisition = requisition;
        _isLoading = false;
        // initialize approved qty = requested qty
        _approvedQty.clear();
        for (final line in requisition.details) {
          _approvedQty[_lineKey(line)] = line.quantity ?? 0;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  // stable key for a line
  String _lineKey(ItemReqLineModel line) =>
      '${line.itemId ?? 'x'}_${line.lineNo ?? 0}';

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
                    // ✅ stable key so line state (focus, cursor) survives rebuilds
                    key: ValueKey(_lineKey(line)),
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _LineCard(
                      line: line,
                      initialApprovedQty: _approvedQty[_lineKey(line)],
                      enabled: requisition.status == 0 && !_isProcessing,
                      onApprovedQtyChanged: (value) {
                        if (value == null) return;
                        setState(() => _approvedQty[_lineKey(line)] = value);
                      },
                    ),
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
    final decidedBy = UserSession.user.userId;
    if (decidedBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your user ID is not available. Please sign in again.'),
        ),
      );
      return;
    }

    // validate approved quantities
    for (final line in requisition.details) {
      final key = _lineKey(line);
      final approved = _approvedQty[key];
      if (approved == null || approved < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid approved quantity for line ${line.lineNo ?? ''}.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      if (approved > (line.quantity ?? 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Approved qty for line ${line.lineNo ?? ''} cannot exceed requested qty.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    final comment = await _requestComment(decision);
    if (comment == null || !mounted) return;
    setState(() => _isProcessing = true);

    try {
      // build approved qty payload
      final approvedLines = requisition.details.map((line) {
        return ItemReqApprovedQty(
          itemId: line.itemId,
          lineNo: line.lineNo,
          approvedQty: _approvedQty[_lineKey(line)] ?? line.quantity ?? 0,
        );
      }).toList();

      await ref
          .read(itemRepositoryProvider)
          .decideMaterialRequisition(
            ItemReqDecisionRequest(
              id:
                  requisition.materialRequisitionMasterId ??
                  widget.requisitionId,
              decision: decision,
              comment: comment,
              decidedBy: decidedBy.toString(),
              approvedLines: approvedLines,
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
      title: Text(
        '$decision requisition?',
        style: const TextStyle(fontSize: 16),
      ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              hintText: decision == 'Reject'
                  ? 'Rejection note'
                  : 'Optional note',
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
            backgroundColor: decision == 'Approve'
                ? AppColors.success
                : AppColors.danger,
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
      ['Status', _statusLabel(requisition.status)],
      if (requisition.submittedBy?.isNotEmpty == true)
        ['Submitted by', requisition.submittedBy!],
      if (requisition.requisitionDate?.isNotEmpty == true)
        ['Requisition date', _formatDate(requisition.requisitionDate!)],
      if (requisition.totalQuantity != null)
        ['Total quantity', _formatQuantity(requisition.totalQuantity!)],
      if (requisition.remarks?.trim().isNotEmpty == true)
        ['Remarks', requisition.remarks!.trim()],
    ];

    final borderColor = AppColors.textSecondary.withValues(alpha: 0.35);

    return Table(
      border: TableBorder.all(color: borderColor, width: 0.8),
      columnWidths: const {0: FlexColumnWidth(0.42), 1: FlexColumnWidth(0.58)},
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

// ---------------------------------------------------------------------------
// Item line — compact single card with collapsible history
// ---------------------------------------------------------------------------
class _LineCard extends StatefulWidget {
  const _LineCard({
    required this.line,
    required this.initialApprovedQty,
    required this.onApprovedQtyChanged,
    this.enabled = true,
  });

  final ItemReqLineModel line;
  final num? initialApprovedQty;
  final ValueChanged<num?> onApprovedQtyChanged;
  final bool enabled;

  @override
  State<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends State<_LineCard> {
  late final TextEditingController _approvedQtyCtrl;
  final FocusNode _approvedQtyFocus = FocusNode(); // ✅ NEW
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialApprovedQty ?? widget.line.quantity ?? 0;
    _approvedQtyCtrl = TextEditingController(text: _fmt(initial));
  }

  @override
  void didUpdateWidget(covariant _LineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent reset the value (e.g. reload / processing finished),
    // reflect it — but ONLY when the field is not focused, so we don't
    // yank the cursor while the user is typing.
    if (!_approvedQtyFocus.hasFocus) {
      final next = widget.initialApprovedQty ?? widget.line.quantity ?? 0;
      final formatted = _fmt(next);
      if (_approvedQtyCtrl.text != formatted) {
        _approvedQtyCtrl.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    _approvedQtyFocus.dispose(); // ✅ NEW
    _approvedQtyCtrl.dispose();
    super.dispose();
  }

  String _fmt(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  void _onChanged(String raw) {
    final parsed = num.tryParse(raw.trim());
    if (parsed == null) {
      setState(() => _errorText = 'Enter a number');
      widget.onApprovedQtyChanged(null);
      return;
    }
    if (parsed < 0) {
      setState(() => _errorText = 'Cannot be negative');
      widget.onApprovedQtyChanged(null);
      return;
    }
    final requested = widget.line.quantity ?? 0;
    if (parsed > requested) {
      setState(() => _errorText = 'Exceeds requested ($requested)');
      widget.onApprovedQtyChanged(null);
      return;
    }
    setState(() => _errorText = null);
    widget.onApprovedQtyChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final title = line.itemName?.isNotEmpty == true
        ? line.itemName!
        : 'Item ${line.itemId ?? ''}';
    final requestedQty = line.quantity == null
        ? '—'
        : '${_formatQuantity(line.quantity!)} ${line.unitName ?? ''}'.trim();
    final buyer = line.buyerName?.isNotEmpty == true
        ? line.buyerName!
        : (line.buyerId?.isNotEmpty == true ? line.buyerId! : '—');

    return _InfoCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Requested: $requestedQty',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ editable Approved Qty (with its own FocusNode)
          Row(
            children: [
              const SizedBox(
                width: 92,
                child: Text(
                  'Approved Qty',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _approvedQtyCtrl,
                    focusNode: _approvedQtyFocus, // ✅ NEW
                    enabled: widget.enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      suffixText: line.unitName,
                      errorText: _errorText,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: .5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
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
                    unit: line.unitName,
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
