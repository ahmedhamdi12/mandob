import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/cubit/product_state.dart';

class ProductSelectorSheet extends StatefulWidget {
  final ValueChanged<Product> onProductSelected;

  const ProductSelectorSheet({super.key, required this.onProductSelected});

  @override
  State<ProductSelectorSheet> createState() => _ProductSelectorSheetState();
}

class _ProductSelectorSheetState extends State<ProductSelectorSheet> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'اختر المنتج',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن منتج...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    context.read<ProductCubit>().loadProducts(query: val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state is ProductsLoaded) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text('لا يوجد منتجات'));
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.inventory_2),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              'الكمية المتاحة: ${product.stockQty} ${product.baseUnit}',
                            ),
                            onTap: () {
                              widget.onProductSelected(product);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
