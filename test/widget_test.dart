import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_music_player/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MyApp(),
    );
    // Verifica que la pantalla principal carga sin errores
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
