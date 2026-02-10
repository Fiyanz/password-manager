import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/viewmodels/password_viewmodel.dart';
import 'data/repositories/password_repository_impl.dart';
import 'data/datasources/database_helper.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'presentation/pages/autofill_selection_page.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseHelper = DatabaseHelper.instance;

  // Create repository instance
  final passwordRepository = PasswordRepositoryImpl(databaseHelper);

  AutofillMetadata? autofillMetadata;
  try {
    autofillMetadata = await AutofillService().autofillMetadata;
  } catch (e) {
    debugPrint('Autofill check failed: $e');
  }

  runApp(MyApp(
    passwordRepository: passwordRepository,
    autofillMetadata: autofillMetadata,
  ));
}

class MyApp extends StatelessWidget {
  final PasswordRepositoryImpl passwordRepository;
  final AutofillMetadata? autofillMetadata;

  const MyApp({
    super.key,
    required this.passwordRepository,
    this.autofillMetadata,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PasswordViewModel(passwordRepository)..loadPasswords(),
        ),
      ],
      child: MaterialApp(
        title: 'PassGuard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        home: autofillMetadata != null
            ? AutofillSelectionPage(metadata: autofillMetadata!)
            : const SplashPage(),
      ),
    );
  }
}
