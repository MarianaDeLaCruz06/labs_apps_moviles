import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:icesi_beats/main.dart';
import 'package:icesi_beats/components/app_top_bar.dart';

void main() {
  Future<void> typeIn(WidgetTester tester, int index, String text) async {
    await tester.enterText(find.byType(TextField).at(index), text);
    await tester.pump();
  }

  Future<void> tapOn(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('full onboarding, bottom nav and profile editing', (
    tester,
  ) async {
    await tester.pumpWidget(const IcesiBeatsApp());

    await typeIn(tester, 0, 'mzamudio@icesi.edu.co');
    await typeIn(tester, 1, 'loquesea');
    await tapOn(tester, find.text('Entrar'));

    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    await typeIn(tester, 0, 'María Alejandra Zamudio');
    await typeIn(tester, 1, 'alejandra.zamudio');
    await tapOn(tester, find.text('Continuar'));

    expect(find.text('¿Qué te mueve?'), findsOneWidget);
    await typeIn(tester, 0, 'Karol G');

    await tester.tap(find.text('Chill'));
    await tester.pump();
    expect(
      find.text('Karol G'),
      findsOneWidget,
      reason: 'picking a mood must not clear the text field',
    );

    await tapOn(tester, find.text('Continuar'));

    expect(find.text('Tu primera playlist'), findsOneWidget);
    await typeIn(tester, 0, 'Mi mix de estudio');

    await tester.tap(find.text('Previsualizar'));
    await tester.pump();
    expect(find.text('Mi mix de estudio'), findsOneWidget);

    await tapOn(tester, find.text('Continuar'));

    expect(find.text('Así te vamos a conocer'), findsOneWidget);
    expect(find.text('mzamudio@icesi.edu.co'), findsOneWidget);
    expect(find.text('@alejandra.zamudio'), findsOneWidget);
    expect(find.text('Karol G'), findsOneWidget);

    await tapOn(tester, find.text('Empezar a escuchar'));

    expect(find.text('Hola, María'), findsOneWidget);

    Finder topBarTitle(String text) => find.descendant(
          of: find.byType(AppTopBar),
          matching: find.text(text),
        );
    expect(topBarTitle('Inicio'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(navigator.canPop(), isFalse);

    await tester.tap(find.text('Playlist').last);
    await tester.pumpAndSettle();
    expect(topBarTitle('Tu playlist'), findsOneWidget);
    expect(find.text('Inspirada en'), findsOneWidget);

    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();
    expect(topBarTitle('Perfil'), findsOneWidget);
    expect(find.text('María Alejandra Zamudio'), findsOneWidget);

    await tapOn(tester, find.text('Editar perfil'));
    expect(find.text('Editar perfil'), findsOneWidget);

    await typeIn(tester, 0, 'Alejandra Z');
    await tapOn(tester, find.text('Guardar'));

    expect(find.text('Alejandra Z'), findsOneWidget);

    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();
    expect(find.text('Hola, Alejandra'), findsOneWidget);

    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Cerrar sesión'));

    expect(find.text('Tu música, a tu manera'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('the onboarding arrow moves between pages, not screens', (
    tester,
  ) async {
    await tester.pumpWidget(const IcesiBeatsApp());

    await typeIn(tester, 0, 'mzamudio@icesi.edu.co');
    await typeIn(tester, 1, 'loquesea');
    await tapOn(tester, find.text('Entrar'));

    await typeIn(tester, 0, 'María Alejandra Zamudio');
    await typeIn(tester, 1, 'alejandra.zamudio');
    await tapOn(tester, find.text('Continuar'));
    expect(find.text('¿Qué te mueve?'), findsOneWidget);

    await tapOn(tester, find.byIcon(Icons.arrow_back));
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(navigator.canPop(), isTrue);

    await tapOn(tester, find.byIcon(Icons.arrow_back));
    expect(find.text('Icesi Beats'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });
}
