import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthService {
  static const String userBoxName = "userBox";

  String? get currentUserId {
    // For local app, not strictly needed unless we support multiple users.
    return null; 
  }

  Future<UserModel?> getUser(String email) async {
    final box = Hive.box<UserModel>(userBoxName); 
    return box.get(email);
  }

  Future<bool> register(UserModel user, String password) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    if (box.containsKey(user.email)) return false;
    await box.put(user.email, user);
    return true;
  }

  Future<void> updateUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    await box.put(user.email, user);
  }

  Future<bool> signIn(String email, String password) async {
     final box = await Hive.openBox<UserModel>(userBoxName);
     // simplistic check: if user exists, allow. 
     return box.containsKey(email);
  }

  Future<void> signOut() async {
    // nothing required for local login
  }
}
