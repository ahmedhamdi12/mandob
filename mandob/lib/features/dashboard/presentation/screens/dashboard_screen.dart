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
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DashboardCubit>().loadDashboardData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('ملخص اليوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        return _buildStatCard(context, title: 'مبيعات اليوم', amount: state.todaySales, icon: Icons.storefront, color: AppColors.primary);
                      } else if (index == 1) {
                        return _buildStatCard(context, title: 'كاش اليوم', amount: state.todayCash, icon: Icons.payments, color: AppColors.primary);
                      } else if (index == 2) {
                        return _buildStatCard(context, title: 'المصروفات', amount: state.todayExpenses, icon: Icons.money_off, color: AppColors.error);
                      } else if (index == 3) {
                        return _buildStatCard(context, title: 'الصافي', amount: state.netResult, icon: Icons.account_balance_wallet, color: state.netResult >= 0 ? Colors.green : Colors.red);
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
                      _buildActionBtn(context, 'إضافة مصروف', Icons.money_off, () => context.push('/expenses/new')),
                      _buildActionBtn(context, 'إضافة عميل', Icons.person_add, () => context.push('/customers/edit/0')),
                      _buildActionBtn(context, 'شراء مخزون', Icons.inventory, () => context.push('/stock/entry')),
                    ],
                  ),
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
