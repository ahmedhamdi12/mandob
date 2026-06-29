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
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<InvoiceCubit>().loadInvoices(
      query: _searchController.text,
      date: _selectedDate,
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

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المبيعات'),
        actions: [
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
