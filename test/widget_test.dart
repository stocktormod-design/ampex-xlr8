import 'package:ampex_mobile/app.dart';
import 'package:ampex_mobile/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('viser melding når .env mangler', (tester) async {
    await tester.pumpWidget(const AmpexApp());
    await tester.pumpAndSettle();

    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.textContaining('Supabase-konfigurasjon'), findsOneWidget);
  });
}
