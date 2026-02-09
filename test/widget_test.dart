// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pass_manager/main.dart';
import 'package:pass_manager/data/datasources/database_helper.dart';
import 'package:pass_manager/data/repositories/password_repository_impl.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize test database
    final databaseHelper = DatabaseHelper.instance;
    final passwordRepository = PasswordRepositoryImpl(databaseHelper);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(passwordRepository: passwordRepository));

    // Verify that the app loads
    expect(find.text('Halo, User'), findsOneWidget);
  });
}
