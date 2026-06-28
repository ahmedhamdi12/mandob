import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/product_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_unit.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../widgets/unit_input_widget.dart';

class AddEditProductScreen extends StatefulWidget {
  final int? id; // null for add, int for edit

  const AddEditProductScreen({super.key, this.id});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _baseUnitController = TextEditingController(text: 'قطعة');
  final _lowStockThresholdController = TextEditingController(text: '10');

  final List<Map<String, TextEditingController>> _unitsControllers = [];

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    final dataSource = sl<ProductLocalDataSource>();
    final product = await dataSource.getProductById(widget.id!);
    if (product != null && mounted) {
      setState(() {
        _nameController.text = product.name;
        _baseUnitController.text = product.baseUnit;
        _lowStockThresholdController.text = product.lowStockThreshold.toString();
      });

      final units = await dataSource.getProductUnits(widget.id!);
      if (mounted) {
        setState(() {
          for (var unit in units) {
            _unitsControllers.add({
              'name': TextEditingController(text: unit.unitName),
              'factor': TextEditingController(text: unit.conversionFactor.toString()),
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUnitController.dispose();
    _lowStockThresholdController.dispose();
    for (var unit in _unitsControllers) {
      unit['name']?.dispose();
      unit['factor']?.dispose();
    }
    super.dispose();
  }

  void _addUnit() {
    setState(() {
      _unitsControllers.add({
        'name': TextEditingController(),
        'factor': TextEditingController(),
      });
    });
  }

  void _removeUnit(int index) {
    setState(() {
      _unitsControllers[index]['name']?.dispose();
      _unitsControllers[index]['factor']?.dispose();
      _unitsControllers.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: isEdit ? widget.id! : 0,
        name: _nameController.text.trim(),
        baseUnit: _baseUnitController.text.trim(),
        lowStockThreshold: int.parse(_lowStockThresholdController.text.trim()),
        createdAt: AppDateUtils.getCurrentIso(),
      );

      final units = _unitsControllers.map((controllers) {
        return ProductUnit(
          id: 0,
          productId: product.id,
          unitName: controllers['name']!.text.trim(),
          conversionFactor: int.parse(controllers['factor']!.text.trim()),
        );
      }).toList();

      if (isEdit) {
        context.read<ProductCubit>().updateProduct(product, units);
      } else {
        context.read<ProductCubit>().addProduct(product, units);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل منتج' : 'إضافة منتج'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المنتج'),
              validator: InputValidators.required,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseUnitController,
                    decoration: const InputDecoration(labelText: 'الوحدة الأساسية (أصغر وحدة)'),
                    validator: InputValidators.required,
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lowStockThresholdController,
                    decoration: const InputDecoration(labelText: 'حد النواقص'),
                    keyboardType: TextInputType.number,
                    validator: InputValidators.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'الوحدات الكبرى (اختياري)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._unitsControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controllers = entry.value;
              return UnitInputWidget(
                nameController: controllers['name']!,
                factorController: controllers['factor']!,
                onRemove: () => _removeUnit(index),
                baseUnit: _baseUnitController.text.isEmpty ? 'قطعة' : _baseUnitController.text,
              );
            }),
            TextButton.icon(
              onPressed: _addUnit,
              icon: const Icon(Icons.add),
              label: const Text('إضافة وحدة أخرى'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
