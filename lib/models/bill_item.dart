import 'package:hive/hive.dart';

part 'bill_item.g.dart';

@HiveType(typeId: 2)
class BillItem {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int qty;

  @HiveField(2)
  final double price;

  BillItem({required this.name, required this.qty, required this.price});

  double get total => qty * price;

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'price': price,
        'total': total,
      };

  static BillItem fromMap(Map<String, dynamic> m) {
    return BillItem(
      name: m['name'] ?? '',
      qty: (m['qty'] ?? 1) as int,
      price: (m['price'] ?? 0.0).toDouble(),
    );
  }
}
