import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/invoice_cubit.dart';
import '../cubit/invoice_state.dart';
import '../widgets/invoice_card.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDate; // Could be used for day if user uses the day picker
  String? _selectedMonth; // Used for the default month view

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadData();
  }

  void _loadData() {
    // If a specific day is selected, use it. Otherwise use the month.
    context.read<InvoiceCubit>().loadInvoices(
      query: _searchController.text,
      date: _selectedDate ?? _selectedMonth, 
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _loadData();
    }
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    final initialDate = _selectedMonth != null 
        ? DateTime.parse('$_selectedMonth-01') 
        : now;
        
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = null; // Clear day filter if month is picked
        _selectedMonth = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
      _loadData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      // We don't clear the month, we want it to fallback to the month.
      // But we can clear the month too if we want to show all time. Let's just fallback to selected month.
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المبيعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
            tooltip: 'تصفية بالشهر',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sale') {
                context.push('/invoices/new').then((_) {
                  if (context.mounted) _loadData();
                });
              } else if (value == 'return') {
                context.push('/invoices/new-return').then((_) {
                  if (context.mounted) _loadData();
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sale',
                child: Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('فاتورة مبيعات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'return',
                child: Row(
                  children: [
                    Icon(Icons.assignment_return, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('فاتورة مرتجع'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'بحث (رقم الفاتورة، العميل، الهاتف)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadData();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => _loadData(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: _selectedDate != null ? Theme.of(context).primaryColor : null,
                  ),
                  onPressed: _selectDate,
                  tooltip: 'تصفية بالتاريخ',
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: _clearDateFilter,
                    tooltip: 'إلغاء التصفية',
                  ),
              ],
            ),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  label: Text('التاريخ: $_selectedDate'),
                  onDeleted: _clearDateFilter,
                ),
              ),
            ),
          Expanded(
            child: BlocConsumer<InvoiceCubit, InvoiceState>(
              listener: (context, state) {
                if (state is InvoiceOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is InvoiceError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is InvoiceLoading) {
                  return const LoadingWidget();
                } else if (state is InvoicesLoaded) {
                  if (state.invoices.isEmpty) {
                    return const EmptyStateWidget(
                      iconData: Icons.receipt_long,
                      message: 'لا يوجد فواتير مطابقة',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8).copyWith(bottom: 80),
                    itemCount: state.invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = state.invoices[index];
                      return InvoiceCard(
                        invoice: invoice,
                        onTap: () {
                          context.push('/invoices/details/${invoice.id}').then((_) {
                            if (context.mounted) {
                              _loadData();
                            }
                          });
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt, color: Colors.blue),
                    title: const Text('فاتورة مبيعات جديدة'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/invoices/new').then((_) {
                        if (context.mounted) _loadData();
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment_return, color: Colors.red),
                    title: const Text('فاتورة مرتجع للعميل'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/invoices/new-return').then((_) {
                        if (context.mounted) _loadData();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('فاتورة جديدة'),
      ),
    );
  }
}
