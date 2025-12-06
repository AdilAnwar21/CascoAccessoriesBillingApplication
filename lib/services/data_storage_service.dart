import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/bill.dart';
import '../models/user_model.dart';

class DataStorageService {
  static const String billsBoxName = 'billsBox';
  static const String userBoxName = 'userBox';

  /// Export all data to a JSON file
  Future<String> exportData() async {
    try {
      // Get all bills
      final billsBox = await Hive.openBox<Bill>(billsBoxName);
      final bills = billsBox.values.toList();

      // Get all users
      final usersBox = await Hive.openBox<UserModel>(userBoxName);
      final users = usersBox.values.toList();

      // Create export data structure
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'bills': bills.map((bill) => bill.toJson()).toList(),
        'users': users.map((user) => user.toJson()).toList(),
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create file name with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'casco_billing_backup_$timestamp.json';
      final filePath = '${directory!.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import data from a JSON file
  Future<Map<String, int>> importData() async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('Invalid file path');
      }

      // Read the file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate the data structure
      if (!data.containsKey('bills') || !data.containsKey('users')) {
        throw Exception('Invalid backup file format');
      }

      // Import bills
      final billsBox = await Hive.openBox<Bill>(billsBoxName);
      final billsList = data['bills'] as List;
      int billsImported = 0;

      for (var billJson in billsList) {
        try {
          final bill = Bill.fromJson(billJson as Map<String, dynamic>);
          await billsBox.put(bill.id, bill);
          billsImported++;
        } catch (e) {
          // Skip invalid bills
          continue;
        }
      }

      // Import users
      final usersBox = await Hive.openBox<UserModel>(userBoxName);
      final usersList = data['users'] as List;
      int usersImported = 0;

      for (var userJson in usersList) {
        try {
          final user = UserModel.fromJson(userJson as Map<String, dynamic>);
          await usersBox.put(user.email, user);
          usersImported++;
        } catch (e) {
          // Skip invalid users
          continue;
        }
      }

      return {
        'bills': billsImported,
        'users': usersImported,
      };
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Erase all data from the app
  Future<void> eraseAllData() async {
    try {
      // Clear bills
      final billsBox = await Hive.openBox<Bill>(billsBoxName);
      await billsBox.clear();

      // Clear users
      final usersBox = await Hive.openBox<UserModel>(userBoxName);
      await usersBox.clear();
    } catch (e) {
      throw Exception('Failed to erase data: $e');
    }
  }

  /// Get data statistics
  Future<Map<String, int>> getDataStats() async {
    try {
      final billsBox = await Hive.openBox<Bill>(billsBoxName);
      final usersBox = await Hive.openBox<UserModel>(userBoxName);

      return {
        'bills': billsBox.length,
        'users': usersBox.length,
      };
    } catch (e) {
      return {'bills': 0, 'users': 0};
    }
  }
}
