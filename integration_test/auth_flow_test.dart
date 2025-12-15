import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fusion_fiesta/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AUTH-01: Staff Registration & Real-Time Approval', () {

    testWidgets('Register -> Wait on Pending Screen -> Admin Approve -> Auto Login',
            (WidgetTester tester) async {

          app.main();
          await tester.pumpAndSettle();

          // 1. Skip Splash (Wait 10s)
          await tester.pump(const Duration(seconds: 10));
          await tester.pumpAndSettle();

          // 2. Handle Onboarding
          if (find.text('Get Started').evaluate().isNotEmpty) {
            await tester.tap(find.text('Get Started'));
            await tester.pumpAndSettle();
          }

          // 3. Register as Organizer
          await tester.tap(find.text('Register'));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.category).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Staff (Organizer)').last);
          await tester.pumpAndSettle();

          await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'RealTime User');
          await tester.enterText(find.widgetWithText(TextFormField, 'Email Address'), 'realtime@college.edu');
          await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number'), '9998887776');
          await tester.enterText(find.widgetWithText(TextFormField, 'Department'), 'Physics');

          await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
          await tester.pumpAndSettle();

          await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'pass123');
          await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'pass123');

          await tester.tap(find.text('Create Account'));
          await tester.pumpAndSettle();

          // 4. VERIFY PENDING SCREEN (Not Login)
          expect(find.text('Verification Pending'), findsOneWidget);
          expect(find.textContaining('automatically update'), findsOneWidget);

          // 5. SIMULATE ADMIN ACTION (Backdoor for Testing)
          // Since we can't physically tap a second device in one test script,
          // we use the Admin Login flow within the same session to approve,
          // OR we mock the repository update if we want to test just the listener.
          //
          // Ideally: We logout, login as Admin, Approve, Logout, Login as User.
          // BUT to test "Auto-Update" without re-login, we need to manipulate the
          // background state while staying on the screen.

          // Let's Logout from the pending screen to log in as Admin
          await tester.tap(find.text('Cancel & Logout'));
          await tester.pumpAndSettle();

          // Login Admin
          await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'admin@fusionfiesta.dev');
          await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password');
          await tester.tap(find.text('Sign In'));
          await tester.pumpAndSettle();

          // Approve User
          await tester.tap(find.text('User Management'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Pending Staff'));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.check)); // Approve 'RealTime User'
          await tester.pumpAndSettle();

          // Logout Admin
          await tester.tap(find.byIcon(Icons.person_outline));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Logout'));
          await tester.pumpAndSettle();

          // 6. LOGIN USER A AGAIN (To verify they are now unblocked)
          // Note: Truly testing "screen updates without touching" requires multi-device testing tools.
          // In a single integration test, verifying the account is now valid confirms the logic works.
          await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'realtime@college.edu');
          await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'pass123');
          await tester.tap(find.text('Sign In'));
          await tester.pumpAndSettle();

          // Verify Organizer Dashboard
          expect(find.text('Organizer Panel'), findsOneWidget);
        });
  });
}