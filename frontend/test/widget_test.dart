import 'package:flutter_test/flutter_test.dart';

import 'package:cacaolens/main.dart';

void main() {
  testWidgets('shows login screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const CacaoLensApp());

    expect(find.text('Iniciar sesion'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
    expect(find.text('Entrar como invitado'), findsOneWidget);
  });
}
