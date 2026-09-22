// screens/simple_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:yunusco_accessories/screens/show_costing_items.dart';
import 'package:yunusco_accessories/theme/app_theme.dart';
import 'package:yunusco_accessories/widgets/fade_slide_in.dart';
import 'document_submit.dart';
import 'chalan_qr_scanner.dart';
import 'item_list_screen.dart';
import 'requested_customer_screen.dart';

class _DashboardModule {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final WidgetBuilder builder;

  const _DashboardModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.builder,
  });
}

class SimpleDashboardScreen extends StatelessWidget {
  const SimpleDashboardScreen({super.key});

  List<_DashboardModule> get _modules => [
        _DashboardModule(
          title: 'Costing',
          description: 'Calculate accessory pricing and costs',
          icon: Icons.calculate_rounded,
          gradient: AppColors.moduleGradients[0],
          builder: (_) => ItemsListScreen(),
        ),
        _DashboardModule(
          title: 'Accessories',
          description: 'Manage garment accessories',
          icon: Icons.inventory_2_rounded,
          gradient: AppColors.moduleGradients[1],
          builder: (_) => const ViewAccessoriesScreen(),
        ),
        _DashboardModule(
          title: 'Chalan Report',
          description: 'Upload and manage chalan reports',
          icon: Icons.qr_code_scanner_rounded,
          gradient: AppColors.moduleGradients[2],
          builder: (_) => const ChalanScanScreen(),
        ),
        _DashboardModule(
          title: 'Document Submit',
          description: 'Send updated info via WhatsApp',
          icon: Icons.send_and_archive_rounded,
          gradient: AppColors.moduleGradients[3],
          builder: (_) => DocumentSubmitScreen(),
        ),
        _DashboardModule(
          title: 'Requested Customer',
          description: 'Review and confirm customer requests',
          icon: Icons.person_add_alt_1_rounded,
          gradient: AppColors.moduleGradients[4],
          builder: (_) => const RequestedCustomerScreen(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final modules = _modules;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Accessories Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: Colors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16, bottom: 56),
                    child: Icon(Icons.dashboard_customize_rounded,
                        color: Colors.white24, size: 72),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = modules[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: FadeSlideIn.staggered(
                      index: index,
                      child: _ModuleCard(module: module),
                    ),
                  );
                },
                childCount: modules.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _DashboardModule module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () {
        Navigator.push(context, AppTheme.pageRoute(Builder(builder: module.builder)));
      },
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
                      color: module.gradient.first.withOpacity(0.35),
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
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
