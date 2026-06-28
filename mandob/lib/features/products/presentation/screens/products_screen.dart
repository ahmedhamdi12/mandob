import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../widgets/product_card.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/products/add').then((_) {
                if (context.mounted) context.read<ProductCubit>().loadProducts();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AppSearchBar(
            hintText: 'ابحث عن منتج...',
            onChanged: (query) {
              context.read<ProductCubit>().loadProducts(query: query);
            },
          ),
          Expanded(
            child: BlocConsumer<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is ProductOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is ProductError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingWidget();
                } else if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return const EmptyStateWidget(
                      iconData: Icons.inventory_2_outlined,
                      message: 'لا توجد منتجات',
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.push('/products/details/${product.id}').then((_) {
                            if (context.mounted) context.read<ProductCubit>().loadProducts();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/products/add').then((_) {
            if (context.mounted) context.read<ProductCubit>().loadProducts();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
