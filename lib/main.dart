import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubit_theme/theme_cubit.dart';
import 'core/utils/app_router.dart';
import 'core/utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Auth App',
            theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}