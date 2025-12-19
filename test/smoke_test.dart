import 'package:flutter_test/flutter_test.dart';

import 'package:fusion_fiesta/app/app.dart';
import 'package:fusion_fiesta/app/di/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupLocator();
  });

  testWidgets('FusionFiestaApp renders', (tester) async {
    await tester.pumpWidget(const FusionFiestaApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  });
}
