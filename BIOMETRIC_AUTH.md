# Biometric & PIN Authentication

This document describes the biometric and PIN authentication features added to the CASCO Accessories Billing Application.

## Features

### 1. **Biometric Authentication**
- Support for **Face ID** (iOS)
- Support for **Touch ID/Fingerprint** (iOS & Android)
- Support for **Iris scanning** (Android devices with iris scanners)
- Automatic detection of available biometric methods on the device

### 2. **PIN Authentication**
- 4-6 digit PIN code support
- Custom PIN keypad interface
- Secure PIN storage using Flutter Secure Storage

### 3. **Security Settings**
- Easy toggle to enable/disable biometric login
- Easy toggle to enable/disable PIN login
- Settings accessible from the main Settings screen
- Automatic cleanup of authentication data on logout

## How It Works

### First Time Setup

1. **Login with Email & Password**: Users must first login using their email and password
2. **Enable Quick Login**: After logging in, users can navigate to:
   - Settings → Security → Enable Biometric or PIN login
3. **Biometric Setup**: 
   - Toggle "Biometric Login" 
   - Authenticate once with biometric to confirm
4. **PIN Setup**:
   - Toggle "PIN Login"
   - Enter a 4-6 digit PIN
   - Confirm the PIN

### Subsequent Logins

Once biometric or PIN is enabled:
- The app will show the **Biometric Login Screen** instead of the regular login screen
- Users can:
  - Use their fingerprint/face to login instantly
  - Enter their PIN using the custom keypad
  - Fall back to email & password if needed

### Security Features

- **Secure Storage**: All authentication preferences and PINs are stored using `flutter_secure_storage`
- **Auto-Cleanup**: When users logout, all biometric/PIN data is automatically cleared
- **Email Verification**: The app verifies that the user account still exists before granting access
- **Fallback Option**: Users can always use email & password if biometric/PIN fails

## Technical Implementation

### Dependencies Added

```yaml
dependencies:
  local_auth: ^2.3.0          # Biometric authentication
  flutter_secure_storage: ^4.2.1  # Secure data storage
```

### New Files Created

1. **`lib/services/biometric_service.dart`**
   - Handles all biometric and PIN operations
   - Manages secure storage of preferences
   - Provides methods for authentication

2. **`lib/screens/biometric_login_screen.dart`**
   - Beautiful login screen with PIN keypad
   - Biometric authentication button
   - Fallback to regular login

3. **`lib/screens/biometric_settings_screen.dart`**
   - Settings UI for enabling/disabling features
   - PIN setup dialog with custom keypad
   - Device capability detection

### Modified Files

1. **`lib/main.dart`**
   - Added logic to check for biometric/PIN on app start
   - Routes to appropriate login screen

2. **`lib/screens/login_screen.dart`**
   - Saves user email after successful login

3. **`lib/screens/settings_screen.dart`**
   - Added Security card with navigation to biometric settings

4. **`lib/providers/app_provider.dart`**
   - Added `loginWithEmail()` method for biometric/PIN flow
   - Updated `signOut()` to clear biometric data

5. **Platform Configuration**:
   - `ios/Runner/Info.plist` - Added Face ID usage description
   - `android/app/src/main/AndroidManifest.xml` - Added biometric permission

## User Experience Flow

```
App Launch
    ↓
Check if biometric/PIN enabled?
    ↓
YES → Show Biometric Login Screen
    ↓
    ├─→ Use Biometric → Authenticate → Home Screen
    ├─→ Enter PIN → Verify → Home Screen
    └─→ Use Email/Password → Regular Login Screen
    
NO → Show Regular Login Screen
    ↓
Login with Email/Password
    ↓
Home Screen
    ↓
Settings → Security → Enable Biometric/PIN
```

## Platform Support

### iOS
- ✅ Face ID
- ✅ Touch ID
- ✅ PIN Login
- Requires iOS 8.0+

### Android
- ✅ Fingerprint
- ✅ Face Unlock (device dependent)
- ✅ Iris Scanner (device dependent)
- ✅ PIN Login
- Requires Android API 23+

## Testing

To test the biometric features:

1. **iOS Simulator**:
   - Face ID can be simulated
   - Go to Features → Face ID → Enrolled
   - Use Hardware → Face ID → Matching Face

2. **Android Emulator**:
   - Settings → Security → Fingerprint
   - Enroll a fingerprint in the emulator

3. **Physical Devices**:
   - Best tested on actual devices with biometric hardware

## Security Considerations

1. **Data Encryption**: All sensitive data is stored using platform-specific secure storage
2. **No Password Storage**: User passwords are never stored; only email is saved
3. **Session Validation**: Each biometric/PIN login validates the user account still exists
4. **Logout Cleanup**: All biometric data is cleared on logout
5. **Optional Feature**: Users can choose not to enable quick login

## Future Enhancements

Potential improvements:
- [ ] Biometric authentication for sensitive actions (e.g., deleting invoices)
- [ ] PIN change functionality
- [ ] Failed attempt tracking and lockout
- [ ] Biometric authentication timeout settings
- [ ] Multiple user support with separate biometric profiles

## Troubleshooting

### Biometric not available
- Ensure device has biometric hardware
- Check that biometric is enrolled in device settings
- Verify app permissions are granted

### PIN not working
- Try disabling and re-enabling PIN
- Ensure you're entering the correct PIN
- Check that secure storage is working properly

### App crashes on biometric
- Check platform permissions are correctly set
- Verify dependencies are properly installed
- Check device compatibility

## Support

For issues or questions about biometric authentication:
1. Check device compatibility
2. Verify permissions in device settings
3. Try disabling and re-enabling the feature
4. Fall back to email/password login
