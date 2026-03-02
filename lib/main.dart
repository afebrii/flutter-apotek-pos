import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/colors.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/shift_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/category_remote_datasource.dart';
import 'data/datasources/sale_remote_datasource.dart';
import 'data/datasources/customer_remote_datasource.dart';
import 'data/datasources/dashboard_remote_datasource.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/auth/bloc/logout/logout_bloc.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'presentation/shift/bloc/shift_bloc.dart';
import 'presentation/pos/bloc/product/product_bloc.dart';
import 'presentation/pos/bloc/category/category_bloc.dart';
import 'presentation/pos/bloc/checkout/checkout_bloc.dart';
import 'presentation/pos/bloc/sale/sale_bloc.dart';
import 'presentation/customer/bloc/customer_bloc.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ShiftBloc(ShiftRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ProductBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(CategoryRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CheckoutBloc(),
        ),
        BlocProvider(
          create: (context) => SaleBloc(datasource: SaleRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CustomerBloc(datasource: CustomerRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DashboardBloc(datasource: DashboardRemoteDatasource()),
        ),
      ],
      child: MaterialApp(
        title: 'Apotek POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            error: AppColors.error,
            surface: AppColors.surface,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.quicksandTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.card,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.divider,
            thickness: 1,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
