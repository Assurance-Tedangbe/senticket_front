import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senticket_front/UI/pages/adminInterface.dart';
import 'package:senticket_front/UI/pages/buyTicket.dart';
import 'package:senticket_front/UI/pages/consultAccount.dart';
import 'package:senticket_front/UI/pages/debitAccount.dart';
import 'package:senticket_front/UI/pages/coverPage.dart';
import 'package:senticket_front/UI/pages/rootView.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/pages/logout.dart';
import 'package:senticket_front/UI/pages/porterInterface.dart';
import 'package:senticket_front/UI/pages/transfert.ticket.dart';
import 'package:senticket_front/UI/widgets/admin/agent.mgmt.dart/manage.agent.dart';
import 'package:senticket_front/UI/widgets/admin/porter.mgmt.dart/manage.porter.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/manage.student.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';
import 'package:senticket_front/UI/pages/settings.dart';
import 'package:senticket_front/UI/pages/signup.dart';
import 'package:senticket_front/UI/pages/studentInterface.dart';
import 'package:senticket_front/UI/pages/updateProfile.dart';
import 'package:senticket_front/bloc/historic.bloc.dart';
import 'package:senticket_front/bloc/services.bloc.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/payment_provider.dart';
import 'package:senticket_front/provider/role_privider.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/payment_service.dart';
import 'package:senticket_front/services/role_service.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:senticket_front/services/user_service.dart';
import 'package:provider/provider.dart';

import 'package:senticket_front/navigation/navigation_service.dart';
import 'package:senticket_front/services/token_storage_service.dart';


/// Point d'entrée de l'application Senticket.
///
/// Séquence de démarrage :
///   1. Initialisation Flutter (obligatoire avant tout appel async)
///   2. Lecture du token JWT depuis le stockage sécurisé
///   3. Détermination de la route initiale selon l'état de connexion
///   4. Lancement de l'app avec les providers et la route correcte
void main() async {
  // ① Obligatoire avant tout appel async dans main()
  // Garantit que les bindings Flutter sont prêts avant d'accéder
  // au stockage sécurisé (flutter_secure_storage)
  WidgetsFlutterBinding.ensureInitialized();

  // ② Vérifier si un token JWT valide existe déjà en mémoire sécurisée
  // Cas nominal : l'utilisateur avait déjà ouvert l'app et s'était connecté
  // → on ne le force pas à se reconnecter à chaque ouverture
  final tokenStorage = TokenStorageService();
  final isLoggedIn = await tokenStorage.isLoggedIn();
  final role = await tokenStorage.getRole();

  print('[main] isLoggedIn: $isLoggedIn — role: $role');

  // ③ Lancer l'app en passant l'état de session détecté
  runApp(MyApp(isLoggedIn: isLoggedIn, role: role));
}

/// Widget racine de l'application.
/// Reçoit l'état de session détecté au démarrage pour
/// déterminer la route initiale correcte.
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    // MultiProvider : injecte tous les providers globaux de l'app
    // Ordre important : les providers qui dépendent d'autres doivent
    // être déclarés après leurs dépendances
    return MultiProvider(
      providers: [
        // ── BLoCs ─────────────────────────────────────────────────────
        BlocProvider(create: (_) => ServicesBloc()),
        BlocProvider(create: (_) => HistoricBloc()),

        // ── Providers métier ──────────────────────────────────────────
        ChangeNotifierProvider<RoleProvider>(
          create: (_) => RoleProvider(RoleApiService()),
        ),
        ChangeNotifierProvider<UserProvider>(
          // UserApiService utilise AuthHttpClient qui lit le token
          // automatiquement → le provider est prêt dès le démarrage
          create: (_) => UserProvider(UserApiService()),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (_) => TicketProvider(TicketApiService()),
        ),

        // ── Provider Paiement PayDunya ─────────────────────────────────
        // Global car le flux de paiement peut être déclenché depuis
        // plusieurs écrans (achat de ticket, etc.)
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(PaymentApiService()),
        ),
      ],
      child: SenticketApp(isLoggedIn: isLoggedIn, role: role),
    );
  }
}

/// Widget MaterialApp principal.
/// Séparé de MyApp pour pouvoir accéder aux providers via context
/// (MultiProvider doit être un ancêtre de MaterialApp).
class SenticketApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? role;

  const SenticketApp({
    super.key,
    required this.isLoggedIn,
    this.role,
  });

  @override
  State<SenticketApp> createState() => _SenticketAppState();
}

class _SenticketAppState extends State<SenticketApp> {

  @override
  void initState() {
    super.initState();

    // ④ Restaurer la session en mémoire si un token existe
    // Appelé après le premier frame pour avoir accès au context
    // et donc aux providers via Provider.of<UserProvider>
    if (widget.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Recharge currentUser depuis le backend avec le token existant
        // Si le token est expiré, UserProvider.restoreSession() appelle logout()
        // et redirige vers /login via NavigationService
        Provider.of<UserProvider>(context, listen: false).restoreSession();
      });
    }
  }

  /// Détermine la route initiale selon l'état de connexion et le rôle.
  ///
  /// Logique :
  ///   - Pas de token        → /cover  (écran d'accueil / non connecté)
  ///   - Token + ETUDIANT   → /student
  ///   - Token + ADMIN      → /admin
  ///   - Token + PORTIER    → /porter
  ///   - Token + rôle inconnu → /cover (sécurité)
  String _getInitialRoute() {
    if (!widget.isLoggedIn || widget.role == null) {
      return '/cover';
    }

    switch (widget.role!.toUpperCase()) {
      case 'ETUDIANT':
        return '/student';
      case 'ADMIN':
        return '/admin';
      case 'PORTIER':
        return '/porter';
      default:
      // Rôle inconnu ou corrompu → retour à l'accueil par sécurité
        return '/cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: kPrimaryColor),

      // ⑤ Clé de navigation globale
      // Permet à NavigationService de naviguer depuis AuthHttpClient
      // (gestion du 401 sans BuildContext)
      navigatorKey: NavigationService.navigatorKey,

      // ⑥ Route initiale déterminée dynamiquement
      initialRoute: _getInitialRoute(),

      // ── Toutes les routes de l'application ────────────────────────
      routes: {
        // Accueil (non connecté)
        '/cover': (_) => const CoverPage(),
        '/home': (_) => const RootV(),

        // Authentification
        '/login': (_) => const LoginPage(),
        '/sign-up': (_) => const SignUpPage(),
        '/log-out': (_) => const LogOut(),

        // Interface ETUDIANT
        '/student': (_) => const StudentInterface(),
        '/ticket': (_) => const BuyTicket(),
        '/transfert-ticket': (_) => const TransfertTicket(),
        '/consult-account': (_) => const ConsultAccount(),
        '/scanQR': (_) => const ScanQR(),
        '/update-profile': (_) => const UpdateProfile(),

        // Interface ADMIN
        '/admin': (_) => const AdminInterface(),
        '/manage-students': (_) => const ManageStudent(),
        '/manage-agents': (_) => const ManageAgent(),
        '/manage-porters': (_) => const ManagePorter(),

        // Interface PORTIER
        '/porter': (_) => const PorterInterface(),
        '/debit-account': (_) => const DebitAccount(),

        // Commun
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (context) => ServicesBloc()),
        BlocProvider(create: (context) => HistoricBloc()),
        *//* ChangeNotifierProvider<AuthProvider>(
           create: (context) => AuthProvider(AuthService()),
        ), *//*
        ChangeNotifierProvider<RoleProvider>(
          create: (context) => RoleProvider(RoleApiService()),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(UserApiService()),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (context) => TicketProvider(TicketApiService()),
        ),
        // PROVIDER PAIEMENT PAYDUNYA
        // Enregistré au niveau global pour être accessible partout dans l'app
        // PaymentApiService est injecté par le constructeur (Dependency Injection)
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(PaymentApiService()),
        ),
      ],
      child: const RootView(),
    );
  }
}

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: kPrimaryColor),
      routes: {
        "/cover": (context) => const CoverPage(),
        "/home": (context) => const RootV(),
        "/login": (context) => const LoginPage(),
        "/sign-up": (context) => const SignUpPage(),
        "/admin": (context) => const AdminInterface(),
        "/manage-students": (context) => const ManageStudent(),
        "/manage-agents": (context) => const ManageAgent(),
        "/manage-porters": (context) => const ManagePorter(),
        "/scanQR": (context) => const ScanQR(),
        "/student": (context) => const StudentInterface(),
        "/ticket": (context) => const BuyTicket(),
        "/transfert-ticket": (context) => const TransfertTicket(),
        "/consult-account": (context) => const ConsultAccount(),
        "/update-profile": (context) => const UpdateProfile(),
        "/porter": (context) => const PorterInterface(),
        "/debit-account": (context) => const DebitAccount(),
        "/settings": (context) => const SettingsPage(),
        "/log-out": (context) => const LogOut(),
      },
      initialRoute: "/cover",
    );
  }
}*/

/* 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fournit le Service combiné (Service + Repository)
        Provider(create: (context) => UserService()),
        
        // Fournit le Provider avec dépendance vers le Service
        ChangeNotifierProvider(
          create: (context) => UserProvider(context.read<UserService>()),
        ),
      ],
      child: MaterialApp(
    );
  }
}
 */
