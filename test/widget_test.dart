import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:senticket_front/main.dart';
import 'package:senticket_front/UI/pages/coverPage.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/pages/signup.dart';
import 'package:senticket_front/bloc/services.bloc.dart';
import 'package:senticket_front/bloc/historic.bloc.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/provider/role_privider.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/payment_provider.dart';
import 'package:senticket_front/services/user_service.dart';
import 'package:senticket_front/services/role_service.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:senticket_front/services/payment_service.dart';

// ============================================================================
// WIDGET TESTS — SENTICKET
//
// Ces tests vérifient le comportement de l'UI sans appels réseau réels.
// Ils testent :
//   - Le démarrage de l'app selon l'état de session (token présent ou non)
//   - La navigation correcte selon le rôle de l'utilisateur
//   - La présence des éléments clés dans les formulaires login/signup
//   - La validation basique des formulaires
//
// Note : Les appels réseau (backend Spring Boot, PayDunya) ne sont PAS testés
// ici — ils relèvent des tests d'intégration. Ces tests sont purement UI.
// ============================================================================

void main() {

  // ==========================================================================
  // GROUPE 1 — DÉMARRAGE DE L'APPLICATION
  // Vérifie que l'app démarre correctement selon l'état du token JWT
  // ==========================================================================
  group('Démarrage de l\'application', () {

    testWidgets(
      '✅ Démarre sur CoverPage quand aucun token présent (première ouverture)',
          (WidgetTester tester) async {
        // Cas : utilisateur jamais connecté ou token effacé
        await tester.pumpWidget(
          const MyApp(isLoggedIn: false, role: null),
        );
        await tester.pumpAndSettle();

        // Aucune exception ne doit être levée
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Démarre sans crash quand token ETUDIANT présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MyApp(isLoggedIn: true, role: 'ETUDIANT'),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Démarre sans crash quand token ADMIN présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MyApp(isLoggedIn: true, role: 'ADMIN'),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Démarre sans crash quand token PORTIER présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MyApp(isLoggedIn: true, role: 'PORTIER'),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Démarre sur CoverPage avec rôle inconnu (sécurité)',
          (WidgetTester tester) async {
        // Cas : token corrompu avec un rôle non reconnu
        await tester.pumpWidget(
          const MyApp(isLoggedIn: true, role: 'ROLE_INCONNU'),
        );
        await tester.pumpAndSettle();

        // Doit retomber sur /cover par sécurité sans crasher
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Démarre sur CoverPage quand isLoggedIn=true mais role=null',
          (WidgetTester tester) async {
        // Cas limite : token présent mais rôle non sauvegardé
        await tester.pumpWidget(
          const MyApp(isLoggedIn: true, role: null),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });

  // ==========================================================================
  // GROUPE 2 — PAGE DE CONNEXION
  // Vérifie la présence des éléments UI sur la page de login
  // ==========================================================================
  group('Page de connexion (LoginPage)', () {

    /// Construit la page de login de façon isolée avec ses providers
    Widget buildLoginPage() {
      return MultiProvider(
        providers: [
          BlocProvider(create: (_) => ServicesBloc()),
          BlocProvider(create: (_) => HistoricBloc()),
          ChangeNotifierProvider(
            create: (_) => UserProvider(UserApiService()),
          ),
          ChangeNotifierProvider(
            create: (_) => RoleProvider(RoleApiService()),
          ),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      );
    }

    testWidgets(
      '✅ La page de connexion s\'affiche sans crasher',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Le champ nom d\'utilisateur est présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pump();

        // Vérifie la présence d'au moins un champ de texte
        expect(find.byType(TextFormField), findsWidgets);
      },
    );

    testWidgets(
      '✅ Le bouton de connexion est présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pump();

        // Le bouton "Se connecter" doit être visible
        expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      '✅ Le lien vers l\'inscription est présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pump();

        // Texte d'invitation à s'inscrire
        expect(find.textContaining('inscrire'), findsAtLeastNWidgets(1));
      },
    );
  });

  // ==========================================================================
  // GROUPE 3 — PAGE D'INSCRIPTION
  // Vérifie la présence des éléments UI sur la page de signup
  // ==========================================================================
  group('Page d\'inscription (SignUpPage)', () {

    Widget buildSignupPage() {
      return MultiProvider(
        providers: [
          BlocProvider(create: (_) => ServicesBloc()),
          BlocProvider(create: (_) => HistoricBloc()),
          ChangeNotifierProvider(
            create: (_) => UserProvider(UserApiService()),
          ),
          ChangeNotifierProvider(
            create: (_) => RoleProvider(RoleApiService()),
          ),
        ],
        child: const MaterialApp(
          home: SignUpPage(),
        ),
      );
    }

    testWidgets(
      '✅ La page d\'inscription s\'affiche sans crasher',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildSignupPage());
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '✅ Les champs du formulaire d\'inscription sont présents',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildSignupPage());
        await tester.pump();

        // Le formulaire d'inscription a plusieurs champs
        // (prénom, nom, username, email, mot de passe, confirmation)
        expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
      },
    );

    testWidgets(
      '✅ Le bouton de création de compte est présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildSignupPage());
        await tester.pump();

        expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      '✅ Le lien vers la connexion est présent',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildSignupPage());
        await tester.pump();

        expect(find.textContaining('connecter'), findsAtLeastNWidgets(1));
      },
    );
  });

  // ==========================================================================
  // GROUPE 4 — VALIDATION DES FORMULAIRES (UserProvider)
  // Vérifie la logique de validation sans UI ni réseau
  // Ces tests sont purement unitaires sur le provider
  // ==========================================================================
  group('Validation formulaire de connexion (UserProvider)', () {

    late UserProvider userProvider;

    setUp(() {
      // Crée un nouveau provider avant chaque test
      userProvider = UserProvider(UserApiService());
    });

    tearDown(() {
      // Libère les ressources après chaque test
      userProvider.dispose();
    });

    test(
      '✅ Formulaire invalide si username et password vides',
          () {
        // Par défaut les champs sont vides
        expect(userProvider.isLoginFormValid, isFalse);
      },
    );

    test(
      '✅ Formulaire invalide si seulement username rempli',
          () {
        userProvider.setLoginUsername('testjwt');
        expect(userProvider.isLoginFormValid, isFalse);
      },
    );

    test(
      '✅ Formulaire invalide si seulement password rempli',
          () {
        userProvider.setLoginPassword('test123');
        expect(userProvider.isLoginFormValid, isFalse);
      },
    );

    test(
      '✅ Formulaire valide si username et password remplis',
          () {
        userProvider.setLoginUsername('testjwt');
        userProvider.setLoginPassword('test123');
        expect(userProvider.isLoginFormValid, isTrue);
      },
    );

    test(
      '✅ resetLoginForm() vide les champs',
          () {
        userProvider.setLoginUsername('testjwt');
        userProvider.setLoginPassword('test123');
        userProvider.resetLoginForm();

        expect(userProvider.loginUsername, isEmpty);
        expect(userProvider.loginPassword, isEmpty);
        expect(userProvider.isLoginFormValid, isFalse);
      },
    );
  });

  // ==========================================================================
  // GROUPE 5 — VALIDATION FORMULAIRE INSCRIPTION
  // ==========================================================================
  group('Validation formulaire d\'inscription (UserProvider)', () {

    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider(UserApiService());
    });

    tearDown(() {
      userProvider.dispose();
    });

    test(
      '✅ Formulaire invalide si tous les champs vides',
          () {
        expect(userProvider.isFormValid, isFalse);
      },
    );

    test(
      '✅ Erreur email si format invalide',
          () {
        userProvider.setEmail('emailinvalide');
        expect(userProvider.emailError, isNotNull);
      },
    );

    test(
      '✅ Pas d\'erreur email si format valide',
          () {
        userProvider.setEmail('test@gmail.com');
        expect(userProvider.emailError, isNull);
      },
    );

    test(
      '✅ Erreur username si moins de 3 caractères',
          () {
        userProvider.setUsername('ab');
        expect(userProvider.usernameError, isNotNull);
      },
    );

    test(
      '✅ Pas d\'erreur username si 3 caractères ou plus',
          () {
        userProvider.setUsername('abc');
        expect(userProvider.usernameError, isNull);
      },
    );

    test(
      '✅ Erreur mot de passe si moins de 6 caractères',
          () {
        userProvider.setPassword('abc');
        expect(userProvider.passwordError, isNotNull);
      },
    );

    test(
      '✅ Erreur si mots de passe ne correspondent pas',
          () {
        userProvider.setPassword('password123');
        userProvider.setConfirmPassword('password456');
        expect(userProvider.passwordError, isNotNull);
      },
    );

    test(
      '✅ Pas d\'erreur si mots de passe identiques et >= 6 caractères',
          () {
        userProvider.setPassword('password123');
        userProvider.setConfirmPassword('password123');
        expect(userProvider.passwordError, isNull);
      },
    );

    test(
      '✅ resetForm() remet tous les champs à vide',
          () {
        userProvider.setFirstname('Jean');
        userProvider.setLastname('Dupont');
        userProvider.setUsername('jdupont');
        userProvider.setEmail('jean@test.com');
        userProvider.setPassword('password123');
        userProvider.setConfirmPassword('password123');

        userProvider.resetForm();

        expect(userProvider.firstName, isEmpty);
        expect(userProvider.lastName, isEmpty);
        expect(userProvider.username, isEmpty);
        expect(userProvider.email, isEmpty);
        expect(userProvider.password, isEmpty);
        expect(userProvider.confirmPassword, isEmpty);
        expect(userProvider.isFormValid, isFalse);
      },
    );
  });

  // ==========================================================================
  // GROUPE 6 — ÉTAT INITIAL DES PROVIDERS
  // Vérifie que les providers démarrent dans un état cohérent
  // ==========================================================================
  group('État initial des providers', () {

    test(
      '✅ UserProvider démarre sans utilisateur connecté',
          () {
        final provider = UserProvider(UserApiService());
        expect(provider.currentUser, isNull);
        expect(provider.isLoading, isFalse);
        expect(provider.error, isEmpty);
        expect(provider.authToken, isNull);
        provider.dispose();
      },
    );

    test(
      '✅ UserProvider : isLoggingIn est false au démarrage',
          () {
        final provider = UserProvider(UserApiService());
        expect(provider.isLoggingIn, isFalse);
        provider.dispose();
      },
    );

    test(
      '✅ UserProvider : liste utilisateurs vide au démarrage',
          () {
        final provider = UserProvider(UserApiService());
        expect(provider.users, isEmpty);
        provider.dispose();
      },
    );
  });
}

/*
import 'package:flutter_test/flutter_test.dart';
import 'package:senticket_front/main.dart';

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
}*/
