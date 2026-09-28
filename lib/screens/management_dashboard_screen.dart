import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yunusco_accessories/helper_class/api_service_class.dart';
import 'package:yunusco_accessories/models/dashboard_model.dart';
import 'package:yunusco_accessories/theme/app_theme.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() =>
      _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  late Future<DashboardModel> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ApiService().getManagementDashboardDataV2();
  }

  void _reload() {
    setState(() {
      _dashboardFuture = ApiService().getManagementDashboardDataV2();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Management Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<DashboardModel>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading dashboard...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load management data',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: _buildDashboard(snapshot.data ?? DashboardModel()),
          );
        },
      ),
    );
  }

  Widget _buildDashboard(DashboardModel dashboard) {
    final monthly = dashboard.monthlySales ?? const <MonthlySales>[];
    final daily = dashboard.dailySales ?? const <DailySales>[];

    // Get current month data
    final now = DateTime.now();
    final currentYearMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Find current month data, fallback to latest available
    MonthlySales? currentMonth;
    try {
      currentMonth = monthly.firstWhere((m) => m.orderYrMn == currentYearMonth);
    } catch (_) {
      currentMonth = monthly.isNotEmpty ? monthly.last : null;
    }

    // Calculate totals
    final totalOrderValue = monthly.fold<num>(
      0,
      (sum, row) => sum + (row.orderValue ?? 0),
    );
    final totalDeliveredValue = monthly.fold<num>(
      0,
      (sum, row) => sum + (row.deliveredValue ?? 0),
    );
    final totalOrderQty = monthly.fold<num>(
      0,
      (sum, row) => sum + (row.orderQuantity ?? 0),
    );
    final totalDeliveredQty = monthly.fold<num>(
      0,
      (sum, row) => sum + (row.deliveredQuantity ?? 0),
    );

    // Current month values
    final currentOrderValue = currentMonth?.orderValue ?? 0;
    final currentDeliveredValue = currentMonth?.deliveredValue ?? 0;
    final currentOrderQty = currentMonth?.orderQuantity ?? 0;
    final currentDeliveredQty = currentMonth?.deliveredQuantity ?? 0;
    final currentMonthLabel = currentMonth?.orderYrMn ?? 'N/A';

    // Calculate growth (compare with previous month)
    double orderGrowth = 0;
    double deliveredGrowth = 0;
    if (monthly.length >= 2) {
      final currentIndex = monthly.indexWhere(
        (m) => m.orderYrMn == currentMonth?.orderYrMn,
      );
      if (currentIndex > 0) {
        final prev = monthly[currentIndex - 1];
        if ((prev.orderValue ?? 0) > 0) {
          orderGrowth =
              ((currentOrderValue - (prev.orderValue ?? 0)) /
                  (prev.orderValue ?? 0)) *
              100;
        }
        if ((prev.deliveredValue ?? 0) > 0) {
          deliveredGrowth =
              ((currentDeliveredValue - (prev.deliveredValue ?? 0)) /
                  (prev.deliveredValue ?? 0)) *
              100;
        }
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        const Text(
          'Business Overview',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Current month: $currentMonthLabel',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Current Month Highlight Card
        _CurrentMonthCard(
          monthLabel: currentMonthLabel,
          orderValue: currentOrderValue,
          deliveredValue: currentDeliveredValue,
          orderQty: currentOrderQty,
          deliveredQty: currentDeliveredQty,
          orderGrowth: orderGrowth,
          deliveredGrowth: deliveredGrowth,
        ),
        const SizedBox(height: 24),

        // Section: All-time Totals
        // const _SectionHeader(title: 'All-time Totals'),
        // const SizedBox(height: 12),
        // LayoutBuilder(
        //   builder: (context, constraints) {
        //     final width = (constraints.maxWidth - 12) / 2;
        //     return Wrap(
        //       spacing: 12,
        //       runSpacing: 12,
        //       children: [
        //         _SummaryCard(
        //           width: width,
        //           title: 'Total Order Value',
        //           value: _formatWithComma(totalOrderValue),
        //           icon: Icons.shopping_bag_outlined,
        //           color: const Color(0xFF4F46E5),
        //         ),
        //         _SummaryCard(
        //           width: width,
        //           title: 'Total Delivered',
        //           value: _formatWithComma(totalDeliveredValue),
        //           icon: Icons.local_shipping_outlined,
        //           color: const Color(0xFF059669),
        //         ),
        //         _SummaryCard(
        //           width: width,
        //           title: 'Order Quantity',
        //           value: _formatWithComma(totalOrderQty),
        //           icon: Icons.inventory_2_outlined,
        //           color: const Color(0xFF0284C7),
        //         ),
        //         _SummaryCard(
        //           width: width,
        //           title: 'Delivered Qty',
        //           value: _formatWithComma(totalDeliveredQty),
        //           icon: Icons.check_circle_outline,
        //           color: const Color(0xFFD97706),
        //         ),
        //       ],
        //     );
        //   },
        // ),
        // const SizedBox(height: 24),

        // Monthly Chart
        _MonthlyChart(sales: monthly),
        const SizedBox(height: 24),

        // Order Tracking Section
        _buildStatusSection('Order vs Invoice', dashboard.orderVsInvoice ?? []),
        _buildStatusSection(
          'Order vs Delivery',
          dashboard.orderVsDelivery ?? [],
        ),
        _buildStatusSection('PI vs LC', dashboard.piVsLc ?? []),

        // Sales by Team
        _buildSectionWithHeader(
          'Sales by RBO',
          _labelValues<RboWiseSales>(
            '',
            (dashboard.rboWiseSales ?? []).take(8).toList(),
            (row) => row.label,
            (row) => row.value,
          ),
        ),
        _buildSectionWithHeader(
          'Sales by Customer Service',
          _labelValues<CsWiseSales>(
            '',
            (dashboard.csWiseSales ?? []).take(8).toList(),
            (row) => row.label,
            (row) => row.value,
          ),
        ),
        _buildSectionWithHeader(
          'Sales by Person',
          (dashboard.personWiseSales ?? [])
              .map(
                (row) => _DataRow(
                  label: row.salesPerson?.trim().isNotEmpty == true
                      ? row.salesPerson!.trim()
                      : 'Sales person',
                  value: _formatWithComma(
                    (row.htl ?? 0) +
                        (row.pfl ?? 0) +
                        (row.tag ?? 0) +
                        (row.woven ?? 0),
                  ),
                ),
              )
              .toList(),
        ),

        // Daily Sales (recent)
        if (daily.isNotEmpty) ...[
          const SizedBox(height: 24),
          _DataPanel(
            title: 'Recent Daily Sales',
            rows: daily.reversed
                .take(8)
                .map(
                  (row) => _DataRow(
                    label: row.salesDate?.trim().isNotEmpty == true
                        ? row.salesDate!.trim()
                        : 'Daily sales',
                    value:
                        '${_formatWithComma(row.salesValue ?? 0)}  •  ${_formatWithComma(row.salesQty ?? 0)} pcs',
                  ),
                )
                .toList(),
          ),
        ],

        // Categories
        _buildSectionWithHeader(
          'Top Customers (Category A)',
          _labelValues<CategoryA>(
            '',
            (dashboard.categoryA ?? []).take(8).toList(),
            (row) => row.label,
            (row) => row.value,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusSection(String title, List<dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _StatusCard(title: title, items: data),
    );
  }

  Widget _buildSectionWithHeader(String title, List<_DataRow> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _DataPanel(title: title, rows: rows),
    );
  }

  List<_DataRow> _labelValues<T>(
    String prefix,
    List<T> values,
    String? Function(T) getLabel,
    num? Function(T) getValue,
  ) {
    return values
        .map(
          (row) => _DataRow(
            label:
                '$prefix${getLabel(row)?.trim().isNotEmpty == true ? getLabel(row) : ''}',
            value: _formatWithComma(getValue(row) ?? 0),
          ),
        )
        .toList();
  }
}

// ============ CURRENT MONTH HIGHLIGHT CARD ============
class _CurrentMonthCard extends StatelessWidget {
  const _CurrentMonthCard({
    required this.monthLabel,
    required this.orderValue,
    required this.deliveredValue,
    required this.orderQty,
    required this.deliveredQty,
    required this.orderGrowth,
    required this.deliveredGrowth,
  });

  final String monthLabel;
  final num orderValue;
  final num deliveredValue;
  final num orderQty;
  final num deliveredQty;
  final double orderGrowth;
  final double deliveredGrowth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT MONTH',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MonthMetric(
                  label: 'Order Value',
                  value: _formatWithComma(orderValue),
                  growth: orderGrowth,
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MonthMetric(
                  label: 'Sales Value',
                  value: _formatWithComma(deliveredValue),
                  growth: deliveredGrowth,
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MonthMetric(
                  label: 'Order Qty',
                  value: _formatWithComma(orderQty),
                  growth: 0,
                  icon: Icons.inventory_2_outlined,
                  showGrowth: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MonthMetric(
                  label: 'Sales Qty',
                  value: _formatWithComma(deliveredQty),
                  growth: 0,
                  icon: Icons.check_circle_outline,
                  showGrowth: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthMetric extends StatelessWidget {
  const _MonthMetric({
    required this.label,
    required this.value,
    required this.growth,
    required this.icon,
    this.showGrowth = true,
  });

  final String label;
  final String value;
  final double growth;
  final IconData icon;
  final bool showGrowth;

  @override
  Widget build(BuildContext context) {
    final isPositive = growth >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (showGrowth && growth != 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isPositive
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFF87171),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '${growth.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFF87171),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'vs last month',
                  style: TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============ SECTION HEADER ============
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============ STATUS CARD (Order vs Invoice etc.) ============
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final doneItems = items.where((item) => item.label == 'Done');
    final pendingItems = items.where((item) => item.label == 'Pending');
    final doneVal = doneItems.isEmpty ? 0 : doneItems.first.value ?? 0;
    final pendingVal = pendingItems.isEmpty ? 0 : pendingItems.first.value ?? 0;
    final total = doneVal + pendingVal;
    final donePercent = total > 0 ? (doneVal / total) * 100 : 0.0;

    return _CardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatWithComma(doneVal),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Pending',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatWithComma(pendingVal),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: donePercent / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${donePercent.toStringAsFixed(1)}% completed',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ MONTHLY CHART ============
class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.sales});

  final List<MonthlySales> sales;

  @override
  Widget build(BuildContext context) {
    final points = sales.length > 8 ? sales.sublist(sales.length - 8) : sales;

    var maxValue = 1.0;
    for (final item in points) {
      maxValue = [
        maxValue,
        (item.orderValue ?? 0).toDouble(),
        (item.deliveredValue ?? 0).toDouble(),
      ].reduce((a, b) => a > b ? a : b);
    }

    return _CardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Trend',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last ${points.length} months',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (points.isEmpty)
            const SizedBox(
              height: 130,
              child: Center(
                child: Text(
                  'No monthly sales data available.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue * 1.2 / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final month = points[index].orderYrMn ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              month.length >= 7 ? month.substring(5) : month,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: points.asMap().entries.map((entry) {
                    final item = entry.value;
                    return BarChartGroupData(
                      x: entry.key,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: (item.orderValue ?? 0).toDouble(),
                          width: 8,
                          color: const Color(0xFF4F46E5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: (item.deliveredValue ?? 0).toDouble(),
                          width: 8,
                          color: const Color(0xFF10B981),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: Color(0xFF4F46E5), label: 'Order Value'),
              SizedBox(width: 20),
              _Legend(color: Color(0xFF10B981), label: 'Delivered Value'),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ SUMMARY CARD ============
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ DATA PANEL ============
class _DataPanel extends StatelessWidget {
  const _DataPanel({required this.title, required this.rows});

  final String title;
  final List<_DataRow> rows;

  @override
  Widget build(BuildContext context) {
    return _CardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.asMap().entries.map(
            (entry) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Color(0xFF4F46E5),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.value.value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.key < rows.length - 1)
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;
}

// ============ CARD PANEL ============
class _CardPanel extends StatelessWidget {
  const _CardPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============ LEGEND ============
class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============ FORMAT HELPERS ============
String _formatNumber(num value) {
  final roundedValue = value.round().toString();
  return roundedValue.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}

String _formatWithComma(num value) {
  return value.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
  );
}
/// Compact format: 1,031,046 -> 1.03M
// String _formatCompact(num value) {
//   final absValue = value.abs();
//   if (absValue >= 1000000000) {
//     return '${(value / 1000000000).toStringAsFixed(2)}B';
//   } else if (absValue >= 1000000) {
//     return '${(value / 1000000).toStringAsFixed(2)}M';
//   } else if (absValue >= 1000) {
//     return '${(value / 1000).toStringAsFixed(1)}K';
//   }
//   return value.round().toString();
// }
