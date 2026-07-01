import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardCubit>().loadDashboardData();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text('نظام المندوب', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('لوحة التحكم'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('العملاء'),
              onTap: () {
                Navigator.pop(context);
                context.push('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('المنتجات والمخزون'),
              onTap: () {
                Navigator.pop(context);
                context.push('/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check),
              title: const Text('جرد المخزون'),
              onTap: () {
                Navigator.pop(context);
                context.push('/products/inventory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('المبيعات'),
              onTap: () {
                Navigator.pop(context);
                context.push('/invoices');
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('المصروفات'),
              onTap: () {
                Navigator.pop(context);
                context.push('/expenses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('التحصيلات'),
              onTap: () {
                Navigator.pop(context);
                context.push('/collections');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.store_mall_directory),
              title: const Text('المخازن'),
              onTap: () {
                Navigator.pop(context);
                context.push('/warehouses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('التقارير'),
              onTap: () {
                Navigator.pop(context);
                context.push('/reports');
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('النسخ الاحتياطي'),
              onTap: () {
                Navigator.pop(context);
                context.push('/backup');
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            final now = DateTime.now();
            final monthNames = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
            final currentMonthName = '${monthNames[now.month - 1]} ${now.year}';

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DashboardCubit>().loadDashboardData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Today's Sales quick view
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مبيعات اليوم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          NumberUtils.formatCurrency(state.todaySales),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('ملخص شهر $currentMonthName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildStatCard(context, title: 'مبيعات الشهر', amount: state.monthlySales, icon: Icons.storefront, color: AppColors.primary);
                      } else if (index == 1) {
                        return _buildStatCard(context, title: 'تحصيلات الشهر', amount: state.monthlyCash, icon: Icons.payments, color: AppColors.primary);
                      } else if (index == 2) {
                        return _buildStatCard(context, title: 'مصروفات الشهر', amount: state.monthlyExpenses, icon: Icons.money_off, color: AppColors.error);
                      } else if (index == 3) {
                        return _buildStatCard(context, title: 'صافي الشهر', amount: state.monthlyNetResult, icon: Icons.account_balance_wallet, color: state.monthlyNetResult >= 0 ? Colors.green : Colors.red);
                      } else {
                        return _buildStatCard(context, title: 'إجمالي المديونيات', amount: state.totalDebts, icon: Icons.warning_amber_rounded, color: AppColors.error);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('إجراءات سريعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionBtn(context, 'فاتورة جديدة', Icons.add_shopping_cart, () => context.push('/invoices/new')),
                      _buildActionBtn(context, 'فاتورة مرتجع', Icons.keyboard_return, () => context.push('/invoices/new-return')),
                      _buildActionBtn(context, 'إضافة مصروف', Icons.money_off, () => context.push('/expenses/new')),
                      _buildActionBtn(context, 'إضافة عميل', Icons.person_add, () => context.push('/customers/edit/0')),
                      _buildActionBtn(context, 'إضافة مخزون', Icons.add_box, () => context.push('/stock/entry')),
                      _buildActionBtn(context, 'مرتجع للمخزن', Icons.assignment_return, () => context.push('/stock/return')),
                    ],
                  ),

                  if (state.previousMonths.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text('الأشهر السابقة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...state.previousMonths.map((month) {
                      final parts = month.yearMonth.split('-');
                      final mIndex = int.parse(parts[1]) - 1;
                      final mName = '${monthNames[mIndex]} ${parts[0]}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                            child: const Icon(Icons.calendar_month, color: AppColors.secondary),
                          ),
                          title: Text(mName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('المبيعات: ${NumberUtils.formatCurrency(month.sales)} | المصروفات: ${NumberUtils.formatCurrency(month.expenses)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('الصافي', style: TextStyle(fontSize: 12)),
                              Text(
                                NumberUtils.formatCurrency(month.netResult),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: month.netResult >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            context.push('/dashboard/month/${month.yearMonth}');
                          },
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          } else if (state is DashboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required double amount, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberUtils.formatCurrency(amount),
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
