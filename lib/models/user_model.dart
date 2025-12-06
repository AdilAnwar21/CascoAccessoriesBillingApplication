import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role; // 'admin' or 'employee'

  @HiveField(4)
  final double gst;

  @HiveField(5)
  final double sgst;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.gst,
    required this.sgst,
  });
}
