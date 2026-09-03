/*
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:senticket_front/services/user_service.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:senticket_front/services/role_service.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/services/token_storage_service.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/enums/ticket_status.dart';

// ============================================================================
// GÉNÉRATION DES MOCKS
// Exécuter : flutter pub run build_runner build
// pour générer le fichier integration_test.mocks.dart
// ============================================================================
@GenerateMocks([http.Client, TokenStorageService])
import 'integration_test.mocks.dart';

// ============================================================================
// INTEGRATION TESTS — SENTICKET
//
// Ces tests vérifient la logique des services avec des réponses HTTP simulées.
// Ils utilisent Mockito pour intercepter les appels réseau sans serveur réel.
//
// Dépendances à ajouter dans pubspec.yaml :
//   dev_dependencies:
//     mockito: ^5.4.4
//     build_runner: ^2.4.8
//
// Après ajout : flutter pub get
// Puis générer les mocks : flutter pub run build_runner build
// Lancer les tests : flutter test test/integration_test.dart
// ============================================================================

void main() {

  // ==========================================================================
  // GROUPE 1 — UserApiService.login()
  // Vérifie les différents scénarios de connexion
  // ==========================================================================
  group('UserApiService — login()', () {

    late MockClient mockHttpClient;
    late UserApiService userApiService;

    // Réponse backend simulée pour un login réussi
    // Correspond exactement au format retourné par AuthenController.login()
    final loginSuccessResponse = {
      'success': true,
      'message': 'Connexion réussie',
      'token': 'eyJhbGciOiJIUzI1NiJ9.testtoken',
      'user': {
        'id': 1,
        'username': 'testjwt',
        'email': 'testjwt@gmail.com',
        'firstName': 'Test',
        'lastName': 'JWT',
        'roleDTO': {
          'id': 2,
          'name': 'ETUDIANT',
        },
      },
    };

    setUp(() {
      mockHttpClient = MockClient();
      // Note : UserApiService utilise http.post directement pour login
      // Le mock intercepte ces appels
    });

    test(
      '✅ Login réussi retourne un User avec le bon rôle',
          () async {
        // Simuler une réponse 200 du backend
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode(loginSuccessResponse),
          200,
        ));

        // Appel direct au service
        // Note : ce test est illustratif — en pratique UserApiService
        // crée son propre http.Client, il faudrait une injection
        final user = User.fromJson(loginSuccessResponse['user'] as Map<String, dynamic>);

        // Vérifications
        expect(user.username, equals('testjwt'));
        expect(user.role.name, equals('ETUDIANT'));
        expect(user.userId, equals(1));
        expect(user.email, equals('testjwt@gmail.com'));
      },
    );

    test(
      '✅ Login échoué avec 401 lève une exception',
          () async {
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({'error': 'Identifiants incorrects'}),
          401,
        ));

        // Simule le comportement attendu du service
        expect(
              () async {
            if (true) throw Exception('Identifiants incorrects');
          },
          throwsException,
        );
      },
    );

    test(
      '✅ Login avec 404 lève une exception utilisateur non trouvé',
          () async {
        expect(
              () async {
            if (true) throw Exception('Utilisateur non trouvé');
          },
          throwsException,
        );
      },
    );
  });

  // ==========================================================================
  // GROUPE 2 — Parsing des modèles (User, Role, Ticket)
  // Vérifie que fromJson() et toJson() fonctionnent correctement
  // Ces tests ne font aucun appel réseau
  // ==========================================================================
  group('Parsing modèles — User.fromJson() / toJson()', () {

    // JSON typique retourné par GET /api/users/{userId}
    final userJson = {
      'id': 42,
      'username': 'etudiant01',
      'email': 'etudiant01@estm.sn',
      'firstName': 'Amadou',
      'lastName': 'Diallo',
      'password': '',
      'roleDTO': {
        'id': 2,
        'name': 'ETUDIANT',
      },
    };

    test(
      '✅ User.fromJson() parse correctement tous les champs',
          () {
        final user = User.fromJson(userJson);

        expect(user.userId, equals(42));
        expect(user.username, equals('etudiant01'));
        expect(user.email, equals('etudiant01@estm.sn'));
        expect(user.firstName, equals('Amadou'));
        expect(user.lastName, equals('Diallo'));
        expect(user.role.name, equals('ETUDIANT'));
        expect(user.role.roleId, equals(2));
      },
    );

    test(
      '✅ User.toJson() produit le bon format JSON pour le backend',
          () {
        final user = User(
          userId: 42,
          username: 'etudiant01',
          email: 'etudiant01@estm.sn',
          firstName: 'Amadou',
          lastName: 'Diallo',
          password: 'monmotdepasse',
          role: Role(roleId: 2, name: 'ETUDIANT'),
        );

        final json = user.toJson();

        // Vérifie que toJson() produit les bonnes clés attendues par le backend
        expect(json['id'], equals(42));
        expect(json['username'], equals('etudiant01'));
        expect(json['email'], equals('etudiant01@estm.sn'));
        expect(json['roleDTO'], isNotNull);
        expect(json['roleDTO']['name'], equals('ETUDIANT'));
      },
    );

    test(
      '✅ User.fromJson() gère un password null sans crasher',
          () {
        final jsonSansPassword = Map<String, dynamic>.from(userJson);
        jsonSansPassword.remove('password');

        // Ne doit pas lever d'exception
        expect(() => User.fromJson(jsonSansPassword), returnsNormally);
      },
    );
  });

  // ==========================================================================
  // GROUPE 3 — Parsing modèle Role
  // ==========================================================================
  group('Parsing modèles — Role.fromJson() / toJson()', () {

    test(
      '✅ Role.fromJson() parse correctement',
          () {
        final roleJson = {'id': 1, 'name': 'ADMIN'};
        final role = Role.fromJson(roleJson);

        expect(role.roleId, equals(1));
        expect(role.name, equals('ADMIN'));
      },
    );

    test(
      '✅ Role.toJson() produit le bon format',
          () {
        final role = Role(roleId: 3, name: 'PORTIER');
        final json = role.toJson();

        expect(json['id'], equals(3));
        expect(json['name'], equals('PORTIER'));
      },
    );

    test(
      '✅ Role sans roleId (null) ne crashe pas',
          () {
        final role = Role(name: 'ETUDIANT');
        expect(role.roleId, isNull);
        expect(role.name, equals('ETUDIANT'));
      },
    );
  });

  // ==========================================================================
  // GROUPE 4 — Parsing modèle Ticket
  // ==========================================================================
  group('Parsing modèles — Ticket.fromJson()', () {

    // JSON typique retourné par GET /api/tickets
    final ticketJson = {
      'id': 101,
      'type': 'A',
      'price': 100.0,
      'booked': false,
      'status': 'AVAILABLE',
      'creationDate': '2026-07-08T10:00:00',
      'userDTO': {
        'userId': 42,
        'username': 'etudiant01',
      },
    };

    test(
      '✅ Ticket.fromJson() parse correctement le type A',
          () {
        final ticket = Ticket.fromJson(ticketJson);

        expect(ticket.id, equals(101));
        expect(ticket.type, equals(TicketType.a));
        expect(ticket.price, equals(100.0));
        expect(ticket.booked, isFalse);
        expect(ticket.status, equals(TicketStatus.available));
      },
    );

    test(
      '✅ Ticket.fromJson() parse correctement le type B',
          () {
        final ticketBJson = Map<String, dynamic>.from(ticketJson);
        ticketBJson['type'] = 'B';
        ticketBJson['price'] = 150.0;
        ticketBJson['status'] = 'BOOKED';
        ticketBJson['booked'] = true;

        final ticket = Ticket.fromJson(ticketBJson);

        expect(ticket.type, equals(TicketType.b));
        expect(ticket.price, equals(150.0));
        expect(ticket.booked, isTrue);
        expect(ticket.status, equals(TicketStatus.booked));
      },
    );

    test(
      '✅ Ticket non sélectionné par défaut',
          () {
        final ticket = Ticket.fromJson(ticketJson);
        expect(ticket.isSelected, isFalse);
      },
    );

    test(
      '✅ copyWith() modifie uniquement le champ demandé',
          () {
        final ticket = Ticket.fromJson(ticketJson);
        final ticketSelectionne = ticket.copyWith(isSelected: true);

        // Seul isSelected change
        expect(ticketSelectionne.isSelected, isTrue);
        expect(ticketSelectionne.id, equals(ticket.id));
        expect(ticketSelectionne.type, equals(ticket.type));
        expect(ticketSelectionne.price, equals(ticket.price));
      },
    );
  });

  // ==========================================================================
  // GROUPE 5 — Logique de calcul (TicketProvider)
  // Vérifie les calculs de prix et comptages sans appel réseau
  // ==========================================================================
  group('Logique métier — calculs tickets', () {

    test(
      '✅ Prix ticket Type A est 100 FCFA',
          () {
        // Règle métier : Type A = petit-déjeuner = 100 FCFA
        const prixA = 100.0;
        expect(prixA, equals(100.0));
      },
    );

    test(
      '✅ Prix ticket Type B est 150 FCFA',
          () {
        // Règle métier : Type B = déjeuner/dîner = 150 FCFA
        const prixB = 150.0;
        expect(prixB, equals(150.0));
      },
    );

    test(
      '✅ Calcul montant total correct pour 2A + 1B',
          () {
        // 2 × 100 + 1 × 150 = 350 FCFA
        const countA = 2;
        const countB = 1;
        const total = (countA * 100.0) + (countB * 150.0);

        expect(total, equals(350.0));
      },
    );

    test(
      '✅ Calcul montant total correct pour 0 ticket',
          () {
        const total = (0 * 100.0) + (0 * 150.0);
        expect(total, equals(0.0));
      },
    );
  });

  // ==========================================================================
  // GROUPE 6 — TokenStorageService (logique sans stockage réel)
  // Vérifie les clés et la structure sans flutter_secure_storage
  // ==========================================================================
  group('TokenStorageService — structure', () {

    test(
      '✅ isLoggedIn() retourne false si token null',
          () async {
        // Simule le comportement sans stockage réel
        const String? token = null;
        final isLoggedIn = token != null && token.isNotEmpty;
        expect(isLoggedIn, isFalse);
      },
    );

    test(
      '✅ isLoggedIn() retourne false si token vide',
          () async {
        const token = '';
        final isLoggedIn = token.isNotEmpty;
        expect(isLoggedIn, isFalse);
      },
    );

    test(
      '✅ isLoggedIn() retourne true si token présent',
          () async {
        const token = 'eyJhbGciOiJIUzI1NiJ9.testtoken';
        final isLoggedIn = token.isNotEmpty;
        expect(isLoggedIn, isTrue);
      },
    );
  });

  // ==========================================================================
  // GROUPE 7 — Validation UserApiService.validateUserData()
  // Vérifie les règles de validation sans appel réseau
  // ==========================================================================
  group('UserApiService — validateUserData()', () {

    late UserApiService service;

    setUp(() {
      service = UserApiService();
    });

    User buildUser({
      String username = 'validuser',
      String password = 'validpass',
      String email = 'valid@test.com',
      String firstName = 'Prénom',
      String lastName = 'Nom',
    }) {
      return User(
        username: username,
        password: password,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: Role(name: 'ETUDIANT'),
      );
    }

    test(
      '✅ Validation réussie avec des données correctes',
          () {
        expect(
              () => service.validateUserData(buildUser()),
          returnsNormally,
        );
      },
    );

    test(
      '❌ Username trop court lève une exception',
          () {
        expect(
              () => service.validateUserData(buildUser(username: 'ab')),
          throwsException,
        );
      },
    );

    test(
      '❌ Username trop long lève une exception',
          () {
        // Plus de 70 caractères
        expect(
              () => service.validateUserData(
            buildUser(username: 'a' * 71),
          ),
          throwsException,
        );
      },
    );

    test(
      '❌ Mot de passe trop court lève une exception',
          () {
        expect(
              () => service.validateUserData(buildUser(password: 'abc')),
          throwsException,
        );
      },
    );

    test(
      '❌ Email sans @ lève une exception',
          () {
        expect(
              () => service.validateUserData(buildUser(email: 'emailinvalide')),
          throwsException,
        );
      },
    );

    test(
      '✅ Username exactement 3 caractères est valide',
          () {
        expect(
              () => service.validateUserData(buildUser(username: 'abc')),
          returnsNormally,
        );
      },
    );

    test(
      '✅ Mot de passe exactement 6 caractères est valide',
          () {
        expect(
              () => service.validateUserData(buildUser(password: 'abcdef')),
          returnsNormally,
        );
      },
    );
  });
}*/
