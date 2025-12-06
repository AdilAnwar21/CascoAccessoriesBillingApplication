import 'package:hive/hive.dart';
import 'bill_item.dart';

part 'bill.g.dart';

@HiveType(typeId: 1)
class Bill {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String customerEmail;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final List<BillItem> items;

  @HiveField(5)
  final double gstPercent;

  @HiveField(6)
  final double sgstPercent;

  @HiveField(7)
  final String whatsappNumber;

  Bill({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.date,
    required this.items,
    required this.gstPercent,
    required this.sgstPercent,
    required this.whatsappNumber,
  });

  double get subtotal => items.fold(0.0, (s, it) => s + it.total);
  double get gstAmount => subtotal * gstPercent / 100.0;
  double get sgstAmount => subtotal * sgstPercent / 100.0;
  double get total => subtotal + gstAmount + sgstAmount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toMap()).toList(),
        'gstPercent': gstPercent,
        'sgstPercent': sgstPercent,
        'whatsappNumber': whatsappNumber,
        'subtotal': subtotal,
        'gstAmount': gstAmount,
        'sgstAmount': sgstAmount,
        'total': total,
      };
}
