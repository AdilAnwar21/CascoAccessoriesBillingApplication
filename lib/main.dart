import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/biometric_login_screen.dart';
import 'screens/home_screen.dart';
import 'services/biometric_service.dart';

import 'models/user_model.dart';
import 'models/bill.dart';
import 'models/bill_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(BillItemAdapter());

  // Open boxes (Ensure adapters registered FIRST)
  try {
    await Hive.openBox<UserModel>('userBox');
    await Hive.openBox<Bill>('billsBox');
  } catch (e) {
    // Schema conflict? Wipe data for dev purposes.
    await Hive.deleteBoxFromDisk('userBox');
    await Hive.deleteBoxFromDisk('billsBox');
    await Hive.openBox<UserModel>('userBox');
    await Hive.openBox<Bill>('billsBox');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CASCO Accessories',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const Root(),
          );
        },
      ),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  final BiometricService _biometricService = BiometricService();
  bool _checkingBiometric = true;
  bool _showBiometricLogin = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final quickLoginEnabled = await _biometricService.isQuickLoginEnabled();
    final lastEmail = await _biometricService.getLastLoggedInEmail();

    setState(() {
      _showBiometricLogin = quickLoginEnabled && lastEmail != null;
      _checkingBiometric = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    if (prov.isLoading || _checkingBiometric) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If user is logged in, show home screen
    if (prov.user != null) {
      return const HomeScreen();
    }

    // If biometric/PIN is enabled, show biometric login
    if (_showBiometricLogin) {
      return const BiometricLoginScreen();
    }

    // Otherwise show regular login
    return const LoginScreen();
  }
}
