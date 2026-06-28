import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/collection_cubit.dart';
import '../cubit/collection_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/theme/app_colors.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollectionCubit>().loadCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحصيلات'),
      ),
      body: BlocConsumer<CollectionCubit, CollectionState>(
        listener: (context, state) {
          if (state is CollectionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CollectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const LoadingWidget();
          } else if (state is CollectionsLoaded) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.success.withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      const Text('إجمالي التحصيلات', style: TextStyle(fontSize: 16)),
                      Text(
                        NumberUtils.formatCurrency(state.totalAmount),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.collections.isEmpty
                      ? const EmptyStateWidget(
                          iconData: Icons.payments_outlined,
                          message: 'لا يوجد تحصيلات مسجلة',
                        )
                      : ListView.builder(
                          itemCount: state.collections.length,
                          itemBuilder: (context, index) {
                            final collection = state.collections[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                  child: const Icon(Icons.payments, color: AppColors.success),
                                ),
                                title: Text(collection.customerName ?? 'عميل #${collection.customerId}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (collection.invoiceNumber != null)
                                      Text('فاتورة: ${collection.invoiceNumber}'),
                                    Text(AppDateUtils.formatToDate(collection.collectDate)),
                                    if (collection.notes != null && collection.notes!.isNotEmpty)
                                      Text(
                                        collection.notes!,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  NumberUtils.formatCurrency(collection.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/collections/new').then((_) {
            if (context.mounted) {
              context.read<CollectionCubit>().loadCollections();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('تسجيل تحصيل'),
      ),
    );
  }
}
