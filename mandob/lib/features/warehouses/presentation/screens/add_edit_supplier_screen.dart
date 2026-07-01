import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../../domain/entities/supplier.dart';
import '../../../../core/utils/date_utils.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final int? id;
  const AddEditSupplierScreen({super.key, this.id});

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  
  bool _isEdit = false;
  Supplier? _supplierToEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.id != null;
    if (_isEdit) {
      _loadSupplierData();
    }
  }

  void _loadSupplierData() {
    final state = context.read<WarehouseCubit>().state;
    if (state is! WarehouseLoaded) return;
    
    try {
      _supplierToEdit = state.suppliers.firstWhere((s) => s.id == widget.id);
      _nameController.text = _supplierToEdit!.name;
      _phoneController.text = _supplierToEdit!.phone;
      _addressController.text = _supplierToEdit!.address;
      _notesController.text = _supplierToEdit!.notes ?? '';
      _balanceController.text = _supplierToEdit!.currentBalance.toString();
    } catch (e) {
      // Handle not found
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: _supplierToEdit?.id ?? 0,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        notes: _notesController.text,
        currentBalance: double.tryParse(_balanceController.text) ?? 0.0,
        createdAt: _supplierToEdit?.createdAt ?? AppDateUtils.getCurrentIso(),
      );

      if (_isEdit) {
        context.read<WarehouseCubit>().updateSupplier(supplier);
      } else {
        context.read<WarehouseCubit>().addSupplier(supplier);
      }
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل مورد' : 'إضافة مورد جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المورد', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم التليفون', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: 'رصيد افتتاحي (موجب = لنا / سالب = علينا)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                enabled: !_isEdit, // Usually balance is only set on creation
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
