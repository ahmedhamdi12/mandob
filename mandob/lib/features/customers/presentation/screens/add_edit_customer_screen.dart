import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/customer_cubit.dart';
import '../../domain/entities/customer.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/datasources/customer_local_datasource.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final int? id;

  const AddEditCustomerScreen({super.key, this.id});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadCustomerData();
    }
  }

  Future<void> _loadCustomerData() async {
    final dataSource = sl<CustomerLocalDataSource>();
    final customer = await dataSource.getCustomerById(widget.id!);
    if (customer != null && mounted) {
      setState(() {
        _nameController.text = customer.name;
        _phoneController.text = customer.phone;
        _addressController.text = customer.address;
        _balanceController.text = customer.currentBalance.toString();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: isEdit ? widget.id! : 0,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        currentBalance: double.tryParse(_balanceController.text.trim()) ?? 0.0,
        createdAt: AppDateUtils.getCurrentIso(),
      );

      if (isEdit) {
        context.read<CustomerCubit>().updateCustomer(customer);
      } else {
        context.read<CustomerCubit>().addCustomer(customer);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل بيانات العميل' : 'إضافة عميل جديد'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل'),
              validator: InputValidators.required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'الرصيد الافتتاحي (أو الحالي)',
                hintText: 'قيمة سالبة تعني أن العميل مدين لك',
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              enabled: !isEdit,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('حفظ البيانات'),
            ),
          ],
        ),
      ),
    );
  }
}
