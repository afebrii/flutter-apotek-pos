import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../widgets/history_phone_layout.dart';
import '../widgets/history_tablet_layout.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(
        datasource: TransactionRemoteDatasource(),
      )..add(TransactionFetch()),
      child: const ResponsiveLayout(
        phone: HistoryPhoneLayout(),
        tablet: HistoryTabletLayout(),
      ),
    );
  }
}
