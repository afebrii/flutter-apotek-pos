import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../bloc/product_management_bloc.dart';
import '../bloc/product_management_event.dart';
import '../widgets/product_phone_layout.dart';
import '../widgets/product_tablet_layout.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductManagementBloc(
        datasource: ProductRemoteDatasource(),
      )..add(ProductManagementFetch()),
      child: const ResponsiveLayout(
        phone: ProductPhoneLayout(),
        tablet: ProductTabletLayout(),
      ),
    );
  }
}
