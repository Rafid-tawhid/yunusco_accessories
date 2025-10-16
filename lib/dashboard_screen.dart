import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;
  final String userRole;

  const DashboardScreen({
    Key? key,
    required this.userName,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50]!,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          _buildHeader(context),

          // Dashboard Grid Menu
          Expanded(
            child: _buildDashboardGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5530),
            Color(0xFF4A7C59),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            userName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userRole,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    List<DashboardItem> menuItems = _getMenuItems(context);

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return _buildMenuCard(menuItems[index], context);
        },
      ),
    );
  }

  Widget _buildMenuCard(DashboardItem item, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              if (item.subtitle != null)
                Text(
                  item.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<DashboardItem> _getMenuItems(BuildContext context) {
    return [
      DashboardItem(
        title: 'Accessories\nManagement',
        subtitle: 'View & Manage Products',
        icon: Icons.inventory_2_rounded,
        color: Colors.blue,
        onTap: () {
          Navigator.pushNamed(context, '/accessories');
        },
      ),
      DashboardItem(
        title: 'User\nManagement',
        subtitle: 'Manage Users & Roles',
        icon: Icons.people_alt_rounded,
        color: Colors.green,
        onTap: () {
          Navigator.pushNamed(context, '/users');
        },
      ),
      DashboardItem(
        title: 'Roles &\nPermissions',
        subtitle: 'Configure Access',
        icon: Icons.admin_panel_settings_rounded,
        color: Colors.orange,
        onTap: () {
          Navigator.pushNamed(context, '/roles');
        },
      ),
      DashboardItem(
        title: 'Costing &\nPricing',
        subtitle: 'Calculate Costs',
        icon: Icons.calculate_rounded,
        color: Colors.purple,
        onTap: () {
          Navigator.pushNamed(context, '/costing');
        },
      ),
      DashboardItem(
        title: 'Signature\nPad',
        subtitle: 'Digital Signatures',
        icon: Icons.draw_rounded,
        color: Colors.red,
        onTap: () {
          Navigator.pushNamed(context, '/signature');
        },
      ),
      DashboardItem(
        title: 'Reports &\nAnalytics',
        subtitle: 'View Reports',
        icon: Icons.analytics_rounded,
        color: Colors.teal,
        onTap: () {
          Navigator.pushNamed(context, '/reports');
        },
      ),
      DashboardItem(
        title: 'Orders &\nSales',
        subtitle: 'Manage Orders',
        icon: Icons.shopping_cart_rounded,
        color: Colors.indigo,
        onTap: () {
          Navigator.pushNamed(context, '/orders');
        },
      ),
      DashboardItem(
        title: 'Settings',
        subtitle: 'App Configuration',
        icon: Icons.settings_rounded,
        color: Colors.grey,
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    ];
  }
}

class DashboardItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  DashboardItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}