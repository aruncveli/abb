import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abb/main.dart';

void main() {
  testWidgets('Launch ABB App', (WidgetTester tester) async {
    HttpOverrides.global = null;
    await tester.pumpWidget(AbbApp());

    expect(find.text('Asianet Broadband Usage'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(find.text('Set Subscriber ID'), findsOneWidget);
    expect(find.text('SUBMIT'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'TR47400');
    await tester.tap(find.text('SUBMIT'));
    await tester.pump();
  });
}
