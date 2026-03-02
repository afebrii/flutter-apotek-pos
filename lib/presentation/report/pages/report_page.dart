import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../data/datasources/report_remote_datasource.dart';
import '../bloc/report_bloc.dart';
import '../widgets/report_phone_layout.dart';
import '../widgets/report_tablet_layout.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportBloc(
        datasource: ReportRemoteDatasource(),
      ),
      child: const ResponsiveLayout(
        phone: ReportPhoneLayout(),
        tablet: ReportTabletLayout(),
      ),
    );
  }
}
