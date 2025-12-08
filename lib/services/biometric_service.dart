import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _userPinKey = 'user_pin';
  static const String _lastLoggedInEmailKey = 'last_logged_in_email';

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access CASCO Accessories',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Enable/disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Check if PIN login is enabled
  Future<bool> isPinEnabled() async {
    final value = await _secureStorage.read(key: _pinEnabledKey);
    return value == 'true';
  }

  /// Enable/disable PIN login
  Future<void> setPinEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _pinEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Set user PIN
  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _userPinKey, value: pin);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _userPinKey);
    return storedPin == pin;
  }

  /// Get stored PIN (for verification purposes)
  Future<String?> getStoredPin() async {
    return await _secureStorage.read(key: _userPinKey);
  }

  /// Save last logged in email
  Future<void> saveLastLoggedInEmail(String email) async {
    await _secureStorage.write(key: _lastLoggedInEmailKey, value: email);
  }

  /// Get last logged in email
  Future<String?> getLastLoggedInEmail() async {
    return await _secureStorage.read(key: _lastLoggedInEmailKey);
  }

  /// Clear all biometric/PIN data
  Future<void> clearAllData() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
    await _secureStorage.delete(key: _pinEnabledKey);
    await _secureStorage.delete(key: _userPinKey);
    await _secureStorage.delete(key: _lastLoggedInEmailKey);
  }

  /// Check if any quick login method is enabled
  Future<bool> isQuickLoginEnabled() async {
    final biometric = await isBiometricEnabled();
    final pin = await isPinEnabled();
    return biometric || pin;
  }
}
