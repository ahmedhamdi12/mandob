import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  final String dbName = 'app.db';

  Future<String> get _dbPath async {
    final dbFolder = await getDatabasesPath();
    return join(dbFolder, dbName);
  }

  /// Backup database to a user-selected folder
  Future<String?> backupDatabase() async {
    try {
      final dbFile = File(await _dbPath);
      if (!await dbFile.exists()) {
        throw Exception('قاعدة البيانات غير موجودة');
      }

      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory == null) {
        return null; // User canceled
      }

      final String backupFileName = 'mandob_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.db';
      final String fullBackupPath = join(selectedDirectory, backupFileName);

      await dbFile.copy(fullBackupPath);
      return fullBackupPath;
    } catch (e) {
      throw Exception('فشل النسخ الاحتياطي: $e');
    }
  }

  /// Restore database from a user-selected file
  Future<bool> restoreDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Android allows .db usually, iOS might be strict
      );

      if (result != null && result.files.single.path != null) {
        final File backupFile = File(result.files.single.path!);
        
        if (!backupFile.path.endsWith('.db')) {
          throw Exception('الملف المختار ليس قاعدة بيانات صالحة');
        }

        final File currentDb = File(await _dbPath);
        
        // Close DB connections before overwriting might be needed in a real app,
        // but for sqflite replacing the file directly usually works if we restart or reload the app.
        // It's safer to just overwrite it and prompt user to restart.
        
        await backupFile.copy(currentDb.path);
        return true;
      }
      return false; // User canceled
    } catch (e) {
      throw Exception('فشل استعادة النسخة: $e');
    }
  }

  /// Share the database file via apps (WhatsApp, Email, etc.)
  Future<void> shareDatabase() async {
    try {
      final String path = await _dbPath;
      final File dbFile = File(path);
      
      if (!await dbFile.exists()) {
        throw Exception('قاعدة البيانات غير موجودة');
      }

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)], text: 'نسخة احتياطية لتطبيق المندوب');
    } catch (e) {
      throw Exception('فشل المشاركة: $e');
    }
  }
}
