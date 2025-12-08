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

  @HiveField(8)
  final String invoiceNumber;

  Bill({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.date,
    required this.items,
    required this.gstPercent,
    required this.sgstPercent,
    required this.whatsappNumber,
    required this.invoiceNumber,
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
        'invoiceNumber': invoiceNumber,
        'subtotal': subtotal,
        'gstAmount': gstAmount,
        'sgstAmount': sgstAmount,
        'total': total,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'gstPercent': gstPercent,
        'sgstPercent': sgstPercent,
        'whatsappNumber': whatsappNumber,
        'invoiceNumber': invoiceNumber,
      };

  static Bill fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List?)
              ?.map((item) => BillItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      gstPercent: (json['gstPercent'] ?? 0.0).toDouble(),
      sgstPercent: (json['sgstPercent'] ?? 0.0).toDouble(),
      whatsappNumber: json['whatsappNumber'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
    );
  }
}
