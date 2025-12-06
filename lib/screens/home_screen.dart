import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'invoices_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const AnalyticsScreen(),
      const InvoicesScreen(),
      const SettingsScreen(),
      _buildLogoutScreen(context, prov),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGrey,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CASCO ACCESSORIES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.primaryOrange,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              prov.user?.name ?? 'Dashboard',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        elevation: 0,
      ),
      body: _selectedIndex == 3
          ? _buildLogoutScreen(context, prov)
          : screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 3) {
              // Logout tab - show confirmation dialog
              _showLogoutDialog(context, prov);
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          selectedItemColor: AppTheme.primaryOrange,
          unselectedItemColor:
              isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              activeIcon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutScreen(BuildContext context, AppProvider prov) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                size: 80,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Ready to logout?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You can always sign back in anytime',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, prov),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppProvider prov) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              prov.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
