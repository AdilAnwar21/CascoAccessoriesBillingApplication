import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/bill_service.dart';
import '../services/biometric_service.dart';
import '../models/user_model.dart';
import '../models/bill.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final BillService _billService = BillService();

  UserModel? user;
  List<Bill> bills = [];
  bool isLoading = true;

  AppProvider() {
    _init();
  }

  void _init() async {
    // Check if we have a persisted user session?
    // For now, let's just finish loading.
    // If we want auto-login, we'd check a "current_user_email" setting.
    // Let's assume we start at Login screen.
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final success = await _auth.signIn(email, password);
    if (success) {
      user = await _auth.getUser(email);
      await fetchBills();
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  /// Login with email only (for biometric/PIN authentication)
  Future<bool> loginWithEmail(String email) async {
    isLoading = true;
    notifyListeners();

    user = await _auth.getUser(email);
    if (user != null) {
      await fetchBills();
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(UserModel newUser, String password) async {
    isLoading = true;
    notifyListeners();

    final success = await _auth.register(newUser, password);
    if (success) {
      user = newUser;
      await fetchBills();
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> fetchBills() async {
    bills = await _billService.getAllBills();
    // Sort by date desc?
    bills.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await _billService.addBill(bill);
    await fetchBills();
  }

  Future<void> updateBill(Bill bill) async {
    await _billService.updateBill(bill);
    await fetchBills();
  }

  Future<void> deleteBill(String billId) async {
    await _billService.deleteBill(billId);
    await fetchBills();
  }

  Future<void> updateSettings(double gst, double sgst) async {
    if (user == null) return;
    final newUser = UserModel(
      uid: user!.uid,
      name: user!.name,
      email: user!.email,
      role: user!.role,
      gst: gst,
      sgst: sgst,
    );
    await _auth.updateUser(newUser);
    user = newUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();

    // Clear biometric/PIN data for security
    final biometricService = BiometricService();
    await biometricService.clearAllData();

    user = null;
    bills = [];
    notifyListeners();
  }
}
