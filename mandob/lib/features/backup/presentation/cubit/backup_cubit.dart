import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/backup_service.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  final BackupService backupService;

  BackupCubit({required this.backupService}) : super(BackupInitial());

  Future<void> backupDatabase() async {
    emit(BackupLoading());
    try {
      final path = await backupService.backupDatabase();
      if (path != null) {
        emit(BackupSuccess('تم حفظ النسخة بنجاح في:\n$path'));
      } else {
        emit(BackupInitial()); // Canceled
      }
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  Future<void> restoreDatabase() async {
    emit(BackupLoading());
    try {
      final success = await backupService.restoreDatabase();
      if (success) {
        emit(const RestoreSuccess());
      } else {
        emit(BackupInitial()); // Canceled
      }
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  Future<void> shareDatabase() async {
    emit(BackupLoading());
    try {
      await backupService.shareDatabase();
      emit(BackupInitial());
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }
}
