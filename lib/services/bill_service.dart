import 'package:hive/hive.dart';
import '../models/bill.dart';

class BillService {
  static const String _boxName = 'billsBox';

  Future<Box<Bill>> get _box async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Bill>(_boxName);
    } else {
      return await Hive.openBox<Bill>(_boxName);
    }
  }

  Future<void> addBill(Bill bill) async {
    final box = await _box;
    await box.put(bill.id, bill);
  }

  Future<void> updateBill(Bill bill) async {
    final box = await _box;
    await box.put(bill.id, bill);
  }

  Future<void> deleteBill(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<List<Bill>> getAllBills() async {
    final box = await _box;
    return box.values.toList();
  }
}
