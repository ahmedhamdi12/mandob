import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../sales/domain/usecases/get_total_sales.dart';
import '../../../expenses/domain/usecases/get_total_expenses.dart';
import '../../../sales/domain/usecases/get_invoices.dart';
import '../../../expenses/domain/usecases/get_expenses.dart';
import '../../../collections/domain/usecases/get_collections.dart';
import '../../../sales/domain/entities/invoice.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../../core/services/service_locator.dart';
import '../../../sales/presentation/widgets/invoice_card.dart';

class MonthDetailsScreen extends StatefulWidget {
  final String yearMonth;

  const MonthDetailsScreen({super.key, required this.yearMonth});

  @override
  State<MonthDetailsScreen> createState() => _MonthDetailsScreenState();
}

class _MonthDetailsScreenState extends State<MonthDetailsScreen> {
  bool _isLoading = true;
  double _sales = 0.0;
  double _expenses = 0.0;
  List<Invoice> _invoices = [];
  List<Expense> _expenseList = [];
  List<Collection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final getTotalSales = sl<GetTotalSales>();
      final getTotalExpenses = sl<GetTotalExpenses>();
      final getInvoices = sl<GetInvoices>();
      final getExpenses = sl<GetExpenses>();
      final getCollections = sl<GetCollections>();

      _sales = await getTotalSales(date: widget.yearMonth);
      _expenses = await getTotalExpenses(date: widget.yearMonth);

      _invoices = await getInvoices(date: widget.yearMonth);
      _expenseList = await getExpenses(startDate: '${widget.yearMonth}-01', endDate: '${widget.yearMonth}-31');
      _collections = await getCollections(date: widget.yearMonth);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _monthName {
    final parts = widget.yearMonth.split('-');
    if (parts.length != 2) return widget.yearMonth;
    final monthNames = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final mIndex = int.parse(parts[1]) - 1;
    return '${monthNames[mIndex]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل شهر $_monthName'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  
                  _buildExpandableSection(
                    title: 'الفواتير (${_invoices.length})',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    content: _invoices.isEmpty
                        ? const Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد فواتير'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _invoices.length,
                            itemBuilder: (context, index) {
                              return InvoiceCard(
                                invoice: _invoices[index],
                                onTap: () => context.push('/invoices/details/${_invoices[index].id}'),
                              );
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpandableSection(
                    title: 'المصروفات (${_expenseList.length})',
                    icon: Icons.money_off,
                    color: AppColors.error,
                    content: _expenseList.isEmpty
                        ? const Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد مصروفات'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _expenseList.length,
                            itemBuilder: (context, index) {
                              final expense = _expenseList[index];
                              return ListTile(
                                leading: const Icon(Icons.receipt, color: AppColors.error),
                                title: Text(expense.title),
                                subtitle: Text(expense.category),
                                trailing: Text(
                                  NumberUtils.formatCurrency(expense.amount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildExpandableSection(
                    title: 'التحصيلات (${_collections.length})',
                    icon: Icons.payments,
                    color: AppColors.success,
                    content: _collections.isEmpty
                        ? const Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد تحصيلات'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _collections.length,
                            itemBuilder: (context, index) {
                              final collection = _collections[index];
                              return ListTile(
                                leading: const Icon(Icons.payments, color: AppColors.success),
                                title: Text(collection.customerName ?? 'عميل'),
                                subtitle: Text(collection.collectDate.split('T').first),
                                trailing: Text(
                                  NumberUtils.formatCurrency(collection.amount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final netResult = _sales - _expenses;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي المبيعات', style: TextStyle(fontSize: 16)),
                Text(NumberUtils.formatCurrency(_sales), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي المصروفات', style: TextStyle(fontSize: 16)),
                Text(NumberUtils.formatCurrency(_expenses), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('صافي الشهر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  NumberUtils.formatCurrency(netResult), 
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: netResult >= 0 ? AppColors.success : AppColors.error
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({required String title, required IconData icon, required Color color, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Container(
            color: Colors.grey.shade50,
            child: content,
          ),
        ],
      ),
    );
  }
}
