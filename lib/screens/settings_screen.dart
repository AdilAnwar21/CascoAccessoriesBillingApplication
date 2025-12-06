import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/data_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _gst = TextEditingController();
  final _sgst = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<AppProvider>(context, listen: false);
    if (prov.user != null) {
      _gst.text = prov.user!.gst.toString();
      _sgst.text = prov.user!.sgst.toString();
    }
  }

  @override
  void dispose() {
    _gst.dispose();
    _sgst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Toggle Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primaryOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDark
                              ? 'Switch to light theme'
                              : 'Switch to dark theme',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: AppTheme.primaryOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Business Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: AppTheme.primaryOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prov.user?.name ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.email_outlined, 'Email', prov.user?.email ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.badge_outlined, 'Role',
                      prov.user?.role.toUpperCase() ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tax Configuration Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calculate_outlined,
                          color: AppTheme.primaryOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tax Configuration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Set default tax rates for invoices',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _gst,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CGST % (Central Tax)',
                      hintText: 'e.g., 9',
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sgst,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SGST % (State Tax)',
                      hintText: 'e.g., 9',
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _handleSave,
                      icon: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label:
                          Text(_loading ? 'Saving...' : 'Save Configuration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Storage Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storage_outlined,
                          color: AppTheme.primaryOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Storage',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage your application data',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Export Data Section
                  _buildDataStorageSection(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    description:
                        'Download all your bills and settings as a backup file',
                    buttonText: 'Export Data',
                    buttonColor: Colors.blue,
                    onPressed: _handleExportData,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Import Data Section
                  _buildDataStorageSection(
                    icon: Icons.upload_outlined,
                    title: 'Import Data',
                    description:
                        'Restore data from a previously exported backup file',
                    buttonText: 'Import Data',
                    buttonColor: Colors.green,
                    onPressed: _handleImportData,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Erase All Data Section
                  _buildEraseDataSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textLight),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() => _loading = true);
    try {
      final gst = double.tryParse(_gst.text.trim()) ?? 0.0;
      final sgst = double.tryParse(_sgst.text.trim()) ?? 0.0;

      final prov = Provider.of<AppProvider>(context, listen: false);
      await prov.updateSettings(gst, sgst);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildDataStorageSection({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEraseDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.delete_forever_outlined,
                size: 20, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Erase All Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Permanently delete all bills and user data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _showEraseDataDialog,
            icon: const Icon(Icons.delete_forever_outlined, size: 20),
            label: const Text('Erase All Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleExportData() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exporting data...'),
                ],
              ),
            ),
          ),
        ),
      );

      final dataService = DataStorageService();
      final filePath = await dataService.exportData();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Export Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your data has been exported successfully!'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  filePath,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if open

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleImportData() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing data...'),
                ],
              ),
            ),
          ),
        ),
      );

      final dataService = DataStorageService();
      final stats = await dataService.importData();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Refresh the app data
      final prov = Provider.of<AppProvider>(context, listen: false);
      await prov.fetchBills();

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Import Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data imported successfully!'),
              const SizedBox(height: 12),
              Text('Bills imported: ${stats['bills']}'),
              Text('Users imported: ${stats['users']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if open

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEraseDataDialog() {
    showDialog(
      context: context,
      builder: (context) => const EraseDataDialog(),
    );
  }
}

// Custom widget for the erase data dialog with long-press animation
class EraseDataDialog extends StatefulWidget {
  const EraseDataDialog({super.key});

  @override
  State<EraseDataDialog> createState() => _EraseDataDialogState();
}

class _EraseDataDialogState extends State<EraseDataDialog>
    with SingleTickerProviderStateMixin {
  bool _isDeleting = false;
  double _progress = 0.0;
  bool _longPressStarted = false;

  void _startLongPress() {
    setState(() {
      _longPressStarted = true;
      _progress = 0.0;
    });

    // Animate progress over 2 seconds
    const duration = Duration(milliseconds: 2000);
    const steps = 50;
    final stepDuration =
        Duration(milliseconds: duration.inMilliseconds ~/ steps);

    int currentStep = 0;
    Future.doWhile(() async {
      await Future.delayed(stepDuration);
      if (!_longPressStarted || !mounted) return false;

      currentStep++;
      setState(() {
        _progress = currentStep / steps;
      });

      if (currentStep >= steps) {
        _handleEraseData();
        return false;
      }
      return true;
    });
  }

  void _cancelLongPress() {
    setState(() {
      _longPressStarted = false;
      _progress = 0.0;
    });
  }

  Future<void> _handleEraseData() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final dataService = DataStorageService();
      await dataService.eraseAllData();

      if (!mounted) return;

      // Clear app state
      final prov = Provider.of<AppProvider>(context, listen: false);
      await prov.signOut();

      Navigator.of(context).pop(); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data has been erased successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
        _longPressStarted = false;
        _progress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to erase data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Text('Erase All Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action cannot be undone!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'All your bills, customers, and settings will be permanently deleted.',
          ),
          const SizedBox(height: 24),
          const Text(
            'To confirm, press and hold the button below:',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onLongPressStart: (_) => _startLongPress(),
            onLongPressEnd: (_) => _cancelLongPress(),
            onLongPressCancel: _cancelLongPress,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Stack(
                children: [
                  // Progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: MediaQuery.of(context).size.width * _progress,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Button content
                  Center(
                    child: _isDeleting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color:
                                    _progress > 0.5 ? Colors.white : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _longPressStarted
                                    ? 'Hold to Delete...'
                                    : 'Press & Hold to Delete',
                                style: TextStyle(
                                  color: _progress > 0.5
                                      ? Colors.white
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
