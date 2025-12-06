import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

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
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CASCO Billing',
        theme: AppTheme.lightTheme,
        home: const Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    if (prov.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // LOCAL login check (not Firebase anymore)
    return prov.user == null ? const LoginScreen() : const HomeScreen();
  }
}
