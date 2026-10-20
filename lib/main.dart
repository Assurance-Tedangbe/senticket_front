import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'package:senticket_front/UI/pages/qrcode/scanqr.dart';
import 'package:senticket_front/UI/pages/settings.dart';
import 'package:senticket_front/UI/pages/signup.dart';
import 'package:senticket_front/UI/pages/studentInterface.dart';
import 'package:senticket_front/UI/pages/updateProfile.dart';
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
import 'UI/pages/profil_page.dart';
import 'UI/pages/qrcode/qr_display_page.dart';
import 'UI/pages/splash_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ensureInitialized pour que flutter_secure_storage fonctionne correctement sur Android
  // ✅ Initialiser Firebase
  await Firebase.initializeApp();
  //await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider : injecte tous les providers globaux de l'app
    // Ordre important : les providers qui dépendent d'autres doivent
    // être déclarés après leurs dépendances
    return MultiProvider(
      providers: [
        // Providers métier
        ChangeNotifierProvider<RoleProvider>(create: (_) => RoleProvider(RoleApiService()),),
        // UserApiService utilise AuthHttpClient qui lit le token
        // automatiquement → le provider est prêt dès le démarrage
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(UserApiService()),),
        ChangeNotifierProvider<TicketProvider>(create: (_) => TicketProvider(TicketApiService()),),
        // Global car le flux de paiement peut être déclenché dep8 +sieurs écrans (achat de ticket, etc.)
        ChangeNotifierProvider<PaymentProvider>(create: (_) => PaymentProvider(PaymentApiService()),)],
      child: SenticketApp(),
    );
  }
}

/// Widget MaterialApp principal.
/// Séparé de MyApp pour pouvoir accéder aux providers via context
/// (MultiProvider doit être un ancêtre de MaterialApp).
/// role: injecter les providers et passer à un widget enfant qui contient MaterialApp.
class SenticketApp extends StatelessWidget {
  const SenticketApp({ super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: kPrimaryColor),
      // permet de naviguer depuis AuthHttpClient (gestion 401) sans BuildContext
      navigatorKey: NavigationService.navigatorKey,
      navigatorObservers: [routeObserver],
      home: const SplashScreen(), // ← toujours SplashScreen au démarrage
      routes: {
        '/cover':            (_) => const CoverPage(),
        '/home':             (_) => const RootV(),
        '/login':            (_) => const LoginPage(),
        '/sign-up':          (_) => const SignUpPage(),
        '/log-out':          (_) => const LogOut(),
        '/student':          (_) => const StudentInterface(),
        '/ticket':           (_) => const BuyTicket(),
        '/transfert-ticket': (_) => const TransfertTicket(),
        '/consult-account':  (_) => const ConsultAccount(),
        '/update-profile':   (_) => const UpdateProfile(),
        '/admin':            (_) => const AdminInterface(),
        '/manage-students':  (_) => const ManageStudent(),
        '/manage-agents':    (_) => const ManageAgent(),
        '/manage-porters':   (_) => const ManagePorter(),
        '/porter':           (_) => const PorterInterface(),
        '/debit-account':    (_) => const DebitAccount(),
        '/settings':         (_) => const SettingsPage(),
        '/qr-display': (_) => const QrDisplayPage(),
        '/scan-qr':    (_) => const ScanQR(),
        '/profile': (_) => const ProfilePage(),
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
      },
      initialRoute: "/cover",
    );
  }
}*/

