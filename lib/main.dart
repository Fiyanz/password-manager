import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/viewmodels/password_viewmodel.dart';
import 'data/repositories/password_repository_impl.dart';
import 'data/datasources/database_helper.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseHelper = DatabaseHelper.instance;

  // Create repository instance
  final passwordRepository = PasswordRepositoryImpl(databaseHelper);

  runApp(MyApp(passwordRepository: passwordRepository));
}

class MyApp extends StatelessWidget {
  final PasswordRepositoryImpl passwordRepository;

  const MyApp({super.key, required this.passwordRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PasswordViewModel(passwordRepository)..loadPasswords(),
        ),
      ],
      child: MaterialApp(
        title: 'Password Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
