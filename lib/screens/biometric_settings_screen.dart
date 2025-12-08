import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';
import '../theme/app_theme.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final available = await _biometricService.isBiometricAvailable();
    final biometrics = await _biometricService.getAvailableBiometrics();
    final biometricEnabled = await _biometricService.isBiometricEnabled();
    final pinEnabled = await _biometricService.isPinEnabled();

    setState(() {
      _biometricAvailable = available;
      _availableBiometrics = biometrics;
      _biometricEnabled = biometricEnabled;
      _pinEnabled = pinEnabled;
      _loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Verify biometric before enabling
      final authenticated =
          await _biometricService.authenticateWithBiometrics();
      if (authenticated) {
        await _biometricService.setBiometricEnabled(true);
        setState(() => _biometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric login enabled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      await _biometricService.setBiometricEnabled(false);
      setState(() => _biometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric login disabled')),
        );
      }
    }
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      // Show PIN setup dialog
      _showPinSetupDialog();
    } else {
      await _biometricService.setPinEnabled(false);
      setState(() => _pinEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN login disabled')),
        );
      }
    }
  }

  void _showPinSetupDialog() {
    String pin = '';
    String confirmPin = '';
    bool isConfirming = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isConfirming ? 'Confirm PIN' : 'Set PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isConfirming
                      ? 'Re-enter your PIN to confirm'
                      : 'Enter a 4-6 digit PIN',
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.textLight),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <
                                (isConfirming ? confirmPin.length : pin.length)
                            ? AppTheme.primaryOrange
                            : AppTheme.lightGrey,
                        border: Border.all(
                          color: AppTheme.primaryOrange.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDialogKeypad(
                  onNumberPressed: (number) {
                    setDialogState(() {
                      if (isConfirming) {
                        if (confirmPin.length < 6) {
                          confirmPin += number;
                          // Auto-verify when length matches
                          if (confirmPin.length >= 4 &&
                              confirmPin.length == pin.length) {
                            _verifyAndSavePin(pin, confirmPin, context);
                          }
                        }
                      } else {
                        if (pin.length < 6) {
                          pin += number;
                          // Auto-move to confirm when 4-6 digits entered
                          if (pin.length >= 4) {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              setDialogState(() => isConfirming = true);
                            });
                          }
                        }
                      }
                    });
                  },
                  onBackspace: () {
                    setDialogState(() {
                      if (isConfirming) {
                        if (confirmPin.isNotEmpty) {
                          confirmPin =
                              confirmPin.substring(0, confirmPin.length - 1);
                        }
                      } else {
                        if (pin.isNotEmpty) {
                          pin = pin.substring(0, pin.length - 1);
                        }
                      }
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (isConfirming)
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      isConfirming = false;
                      confirmPin = '';
                    });
                  },
                  child: const Text('Back'),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _verifyAndSavePin(
      String pin, String confirmPin, BuildContext dialogContext) async {
    if (pin == confirmPin) {
      await _biometricService.setPin(pin);
      await _biometricService.setPinEnabled(true);
      setState(() => _pinEnabled = true);

      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN login enabled'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PINs do not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(dialogContext);
      }
    }
  }

  Widget _buildDialogKeypad({
    required Function(String) onNumberPressed,
    required VoidCallback onBackspace,
  }) {
    return Column(
      children: [
        // Row 1-3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3']
              .map((n) => _buildDialogKeypadButton(n, onNumberPressed))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Row 4-6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6']
              .map((n) => _buildDialogKeypadButton(n, onNumberPressed))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Row 7-9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9']
              .map((n) => _buildDialogKeypadButton(n, onNumberPressed))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Row 0 and backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 48),
            _buildDialogKeypadButton('0', onNumberPressed),
            InkWell(
              onTap: onBackspace,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryOrange.withOpacity(0.2),
                  ),
                ),
                child: const Icon(Icons.backspace_outlined, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDialogKeypadButton(String number, Function(String) onPressed) {
    return InkWell(
      onTap: () => onPressed(number),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryOrange.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _getBiometricTypeText() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      backgroundColor: AppTheme.lightGrey,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Biometric Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          '${_getBiometricTypeText()} Login',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          _biometricAvailable
                              ? 'Use ${_getBiometricTypeText().toLowerCase()} to quickly access the app'
                              : 'Not available on this device',
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: _biometricEnabled,
                        onChanged:
                            _biometricAvailable ? _toggleBiometric : null,
                        activeColor: AppTheme.primaryOrange,
                        secondary: Icon(
                          _availableBiometrics.contains(BiometricType.face)
                              ? Icons.face
                              : Icons.fingerprint,
                          color: _biometricAvailable
                              ? AppTheme.primaryOrange
                              : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // PIN Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'PIN Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text(
                      'Use a PIN code to quickly access the app',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _pinEnabled,
                    onChanged: _togglePin,
                    activeColor: AppTheme.primaryOrange,
                    secondary: const Icon(
                      Icons.pin,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryOrange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Quick login methods allow you to access the app faster after your initial login.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textDark.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
