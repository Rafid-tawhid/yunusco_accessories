import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yunusco_accessories/helper_class/api_service_class.dart';
import 'package:yunusco_accessories/helper_class/user_data.dart';
import 'package:yunusco_accessories/models/monthly_sales_model.dart';
import 'package:yunusco_accessories/screens/show_costing_items.dart';
import 'package:yunusco_accessories/theme/app_theme.dart';
import 'package:yunusco_accessories/widgets/fade_slide_in.dart';

import 'chalan_qr_scanner.dart';
import 'document_submit.dart';
import 'item_list_screen.dart';
import 'item_requisitions_screen.dart';
import 'management_dashboard_screen.dart';
import 'requested_customer_screen.dart';

class SimpleDashboardScreen extends StatefulWidget {
  const SimpleDashboardScreen({super.key});

  @override
  State<SimpleDashboardScreen> createState() => _SimpleDashboardScreenState();
}

class _SimpleDashboardScreenState extends State<SimpleDashboardScreen> {
  late Future<List<MonthlySalesModel>> _monthlySalesFuture;

  final List<_DashboardModule> _modules = [
    // _DashboardModule(
    //   title: 'Costing',
    //   description: 'Calculate accessory pricing and costs',
    //   icon: Icons.calculate_rounded,
    //   gradient: AppColors.moduleGradients[0],
    //   builder: (_) => ItemsListScreen(),
    // ),
    // _DashboardModule(
    //   title: 'Accessories',
    //   description: 'Manage garment accessories',
    //   icon: Icons.inventory_2_rounded,
    //   gradient: AppColors.moduleGradients[1],
    //   builder: (_) => const ViewAccessoriesScreen(),
    // ),
    // _DashboardModule(
    //   title: 'Chalan Report',
    //   description: 'Upload and manage chalan reports',
    //   icon: Icons.qr_code_scanner_rounded,
    //   gradient: AppColors.moduleGradients[2],
    //   builder: (_) => const ChalanScanScreen(),
    // ),
    // _DashboardModule(
    //   title: 'Document Submit',
    //   description: 'Send updated info via WhatsApp',
    //   icon: Icons.send_and_archive_rounded,
    //   gradient: AppColors.moduleGradients[3],
    //   builder: (_) => DocumentSubmitScreen(),
    // ),
    _DashboardModule(
      title: 'Pending Customer',
      description: 'Review and confirm customer requests',
      icon: Icons.person_add_alt_1_rounded,
      gradient: AppColors.moduleGradients[4],
      builder: (_) => const RequestedCustomerScreen(),
    ),
    _DashboardModule(
      title: 'Item Requisitions',
      description: 'Review material requisitions',
      icon: Icons.inventory_2_rounded,
      gradient: AppColors.moduleGradients[4],
      builder: (_) => const ItemRequisitionsScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _monthlySalesFuture = ApiService().getMonthlySalesNew(mons: 12);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
              title: const Text(
                'Accessories Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16, bottom: 56),
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: Colors.white24,
                      size: 72,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final module = _modules[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FadeSlideIn.staggered(
                    index: index,
                    child: _ModuleCard(
                      module: module,
                      onTap: () => _openModule(module),
                    ),
                  ),
                );
              }, childCount: _modules.length),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    final user = UserData.user;
    final name = user.userName?.trim().isNotEmpty == true
        ? user.userName!.trim()
        : user.loginName?.trim().isNotEmpty == true
        ? user.loginName!.trim()
        : 'Yunusco team member';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.userEmail?.trim().isNotEmpty == true
                        ? user.userEmail!.trim()
                        : 'Yunusco Accessories',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WORKSPACE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _DrawerTile(
                    icon: Icons.dashboard_rounded,
                    title: 'Accessories Dashboard',
                    selected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerTile(
                    icon: Icons.analytics_rounded,
                    title: 'Management Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        AppTheme.pageRoute(const ManagementDashboardScreen()),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  for (final module in _modules)
                    _DrawerTile(
                      icon: module.icon,
                      title: module.title,
                      onTap: () => _openModule(module, closeDrawer: true),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.business_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Yunusco T&A BD',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openModule(_DashboardModule module, {bool closeDrawer = false}) {
    if (closeDrawer) Navigator.pop(context);
    Navigator.of(
      context,
    ).push(AppTheme.pageRoute(Builder(builder: module.builder)));
  }

  String _initials(String name) {
    if (name == 'Yunusco team member') return 'Y';
    return name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard({required this.sales});

  final List<MonthlySalesModel> sales;

  @override
  Widget build(BuildContext context) {
    final limitedSales = sales.take(6).toList();
    final totalOrderValue = sales.fold<num>(
      0,
      (sum, item) => sum + (item.orderValue ?? 0),
    );
    final totalDeliveredValue = sales.fold<num>(
      0,
      (sum, item) => sum + (item.deliveredValue ?? 0),
    );

    var maxValue = 1.0;
    for (final item in limitedSales) {
      maxValue = [
        maxValue,
        (item.orderValue ?? 0).toDouble(),
        (item.deliveredValue ?? 0).toDouble(),
      ].reduce((a, b) => a > b ? a : b);
    }
    maxValue = maxValue == 0 ? 100 : maxValue * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Monthly Sales Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Last 12 months',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Order Value',
                  value: totalOrderValue.toStringAsFixed(0),
                  color: const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Delivered Value',
                  value: totalDeliveredValue.toStringAsFixed(0),
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                barTouchData: BarTouchData(enabled: true),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1),
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
                        if (index < 0 || index >= limitedSales.length) {
                          return const SizedBox.shrink();
                        }
                        final month = limitedSales[index].orderYrMn ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            month.length >= 7 ? month.substring(5) : month,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: limitedSales.asMap().entries.map((entry) {
                  final item = entry.value;
                  return BarChartGroupData(
                    x: entry.key,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: (item.orderValue ?? 0).toDouble(),
                        width: 8,
                        color: const Color(0xFF4F46E5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: (item.deliveredValue ?? 0).toDouble(),
                        width: 8,
                        color: const Color(0xFF10B981),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Legend(color: Color(0xFF4F46E5), label: 'Order'),
              SizedBox(width: 16),
              _Legend(color: Color(0xFF10B981), label: 'Delivered'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final _DashboardModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: module.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: module.gradient.first.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(module.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      module.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesMessage extends StatelessWidget {
  const _SalesMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              tooltip: 'Retry',
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        selected: selected,
        selectedTileColor: const Color(0xFFEFF3FF),
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final WidgetBuilder builder;
}
