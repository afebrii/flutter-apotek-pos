import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../data/datasources/customer_remote_datasource.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../widgets/customer_phone_layout.dart';
import '../widgets/customer_tablet_layout.dart';

class CustomerListPage extends StatelessWidget {
  final bool selectionMode;

  const CustomerListPage({
    super.key,
    this.selectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc(
        datasource: CustomerRemoteDatasource(),
      )..add(CustomerFetch()),
      child: ResponsiveLayout(
        phone: CustomerPhoneLayout(selectionMode: selectionMode),
        tablet: CustomerTabletLayout(selectionMode: selectionMode),
      ),
    );
  }
}
