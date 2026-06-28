import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';
import '../../../../shared/widgets/loading_widget.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي'),
      ),
      body: BlocConsumer<BackupCubit, BackupState>(
        listener: (context, state) {
          if (state is BackupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), duration: const Duration(seconds: 4)),
            );
          } else if (state is BackupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is RestoreSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('تمت الاستعادة بنجاح'),
                content: const Text('يرجى إعادة تشغيل التطبيق لتطبيق البيانات الجديدة.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // We don't have a direct way to restart flutter app programmatically safely,
                      // so we just tell the user to restart it manually.
                      Navigator.pop(ctx);
                    },
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BackupLoading) {
            return const LoadingWidget();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(Icons.cloud_sync, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'يمكنك أخذ نسخة احتياطية من جميع بيانات التطبيق أو استعادتها. للحفاظ على بياناتك آمنة، يُنصح بأخذ نسخة احتياطية ومشاركتها على Google Drive أو Telegram.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: () => context.read<BackupCubit>().backupDatabase(),
                icon: const Icon(Icons.download),
                label: const Text('حفظ نسخة احتياطية في الجهاز'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => context.read<BackupCubit>().shareDatabase(),
                icon: const Icon(Icons.share),
                label: const Text('مشاركة النسخة (واتساب/تيليجرام/درايف)'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
              const SizedBox(height: 32),

              OutlinedButton.icon(
                onPressed: () => _confirmRestore(context),
                icon: const Icon(Icons.upload, color: Colors.red),
                label: const Text('استعادة نسخة احتياطية', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تنبيه: استعادة نسخة احتياطية ستقوم بمسح جميع البيانات الحالية واستبدالها ببيانات النسخة المحددة!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الاستعادة', style: TextStyle(color: Colors.red)),
        content: const Text('هل أنت متأكد من استعادة النسخة؟ ستفقد أي بيانات جديدة غير موجودة في النسخة المراد استعادتها.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BackupCubit>().restoreDatabase();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
