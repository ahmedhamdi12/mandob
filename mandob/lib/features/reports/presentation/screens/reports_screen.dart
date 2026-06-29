import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/theme/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadReports();
  }

  void _changePeriod(ReportPeriod period) {
    context.read<ReportsCubit>().loadReports(period: period);
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final startStr = picked.start.toIso8601String().split('T').first;
      final endStr = picked.end.toIso8601String().split('T').first;
      context.read<ReportsCubit>().loadReports(
        period: ReportPeriod.custom,
        start: startStr,
        end: endStr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const LoadingWidget();
          } else if (state is ReportsError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is ReportsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Period Selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('اليوم', ReportPeriod.today),
                      const SizedBox(width: 8),
                      _buildFilterChip('هذا الشهر', ReportPeriod.thisMonth),
                      const SizedBox(width: 8),
                      _buildFilterChip('كل الوقت', ReportPeriod.allTime),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('تاريخ مخصص'),
                        selected: context.read<ReportsCubit>().currentPeriod == ReportPeriod.custom,
                        onSelected: (selected) {
                          if (selected) {
                            _pickDateRange();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (state.dateRangeLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.dateRangeLabel == 'فترة مخصصة' 
                      ? 'من: ${context.read<ReportsCubit>().customStartDate} إلى: ${context.read<ReportsCubit>().customEndDate}'
                      : state.dateRangeLabel,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Profit Summary
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ملخص الأرباح (${state.dateRangeLabel})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        _buildSummaryRow('إجمالي المبيعات:', state.profitReport.totalSales, AppColors.primary),
                        _buildSummaryRow('التكلفة والمصروفات:', state.profitReport.totalCosts, AppColors.error),
                        const Divider(),
                        _buildSummaryRow('صافي الربح:', state.profitReport.netProfit, state.profitReport.netProfit >= 0 ? AppColors.success : AppColors.error, isTotal: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Products
                const Text('المنتجات الأكثر مبيعاً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (state.topProducts.isEmpty)
                  const Text('لا توجد بيانات مبيعات في هذه الفترة')
                else
                  ...state.topProducts.map((p) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                        child: Text('${p.totalQtySold.toInt()}'),
                      ),
                      title: Text(p.productName),
                      trailing: Text(
                        NumberUtils.formatCurrency(p.totalRevenue),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  )),
                  
                const SizedBox(height: 16),

                // Top Customers
                const Text('العملاء الأكثر شراءً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (state.topCustomers.isEmpty)
                  const Text('لا توجد بيانات عملاء في هذه الفترة')
                else
                  ...state.topCustomers.map((c) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(c.customerName),
                      trailing: Text(
                        NumberUtils.formatCurrency(c.totalPurchases),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  )),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, ReportPeriod period) {
    final currentPeriod = context.read<ReportsCubit>().currentPeriod;
    final isSelected = currentPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _changePeriod(period);
      },
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberUtils.formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
