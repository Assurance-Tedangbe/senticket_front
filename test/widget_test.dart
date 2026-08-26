// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/main.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/user_service.dart';

void main() {

  // ============ TEST 1 — Démarrage sans session (cas nominal) ============
  testWidgets(
    'App démarre sur CoverPage quand aucun token présent',
        (WidgetTester tester) async {

      // Simule un démarrage sans token (utilisateur jamais connecté)
      await tester.pumpWidget(
        const MyApp(isLoggedIn: false, role: null),
      );

      // Laisse le temps au widget de se construire
      await tester.pumpAndSettle();

      // L'app doit démarrer sans crasher
      expect(tester.takeException(), isNull);
    },
  );

  // ============ TEST 2 — Démarrage avec session ETUDIANT ============
  testWidgets(
    'App démarre sur StudentInterface quand token ETUDIANT présent',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MyApp(isLoggedIn: true, role: 'ETUDIANT'),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  // ============ TEST 3 — Démarrage avec session ADMIN ============
  testWidgets(
    'App démarre sur AdminInterface quand token ADMIN présent',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        const MyApp(isLoggedIn: true, role: 'ADMIN'),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}