import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senticket_front/UI/pages/activateAccount.dart';
import 'package:senticket_front/UI/pages/adminInterface.dart';
import 'package:senticket_front/UI/pages/agentInterface.dart';
import 'package:senticket_front/UI/pages/buyTicket.dart';
import 'package:senticket_front/UI/pages/cancelRecharge.dart';
import 'package:senticket_front/UI/pages/cancelTransfertCredit.dart';
import 'package:senticket_front/UI/pages/cancelTransfertTicket.dart';
import 'package:senticket_front/UI/pages/consultAccount.dart';
import 'package:senticket_front/UI/pages/creditAccount.dart';
import 'package:senticket_front/UI/pages/deactivateAccount.dart';
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
import 'package:senticket_front/UI/pages/transfertCredit.dart';
import 'package:senticket_front/UI/pages/updateProfile.dart';
import 'package:senticket_front/bloc/historic.bloc.dart';
import 'package:senticket_front/bloc/services.bloc.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/account_provider.dart';
import 'package:senticket_front/provider/consulter_menu_provider.dart';
import 'package:senticket_front/provider/credit_provider.dart';
import 'package:senticket_front/provider/debit_provider.dart';
import 'package:senticket_front/provider/menu_provider.dart';
import 'package:senticket_front/provider/role_privider.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/account_service.dart';
import 'package:senticket_front/services/consulter_menu_service.dart';
import 'package:senticket_front/services/credit_service.dart';
import 'package:senticket_front/services/debit_service.dart';
import 'package:senticket_front/services/menu_service.dart';
import 'package:senticket_front/services/role_service.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:senticket_front/services/user_service.dart';
import 'package:provider/provider.dart';

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
        /* ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(AuthService()),
    ), */
        ChangeNotifierProvider<RoleProvider>(
          create: (context) => RoleProvider(RoleApiService()),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(UserApiService()),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (context) => TicketProvider(TicketApiService()),
        ),
        /*  ChangeNotifierProvider<AccountProvider>(
        create: (context) => AccountProvider(AccountApiService()),
      ), */
        ChangeNotifierProvider<MenuProvider>(
          create: (context) => MenuProvider(MenuApiService()),
        ),
        ChangeNotifierProvider<ConsulterMenuProvider>(
          create: (context) => ConsulterMenuProvider(ConsulterMenuApiService()),
        ),
        ChangeNotifierProvider<DebitProvider>(
          create: (context) => DebitProvider(DebitApiService()),
        ),
        ChangeNotifierProvider<CreditProvider>(
          create: (context) => CreditProvider(CreditApiService()),
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
        //  "/activate-account": (context) => const ActivateAccount(),
        //  "/deactivate-account": (context) => const DeactivateAccount(),
        "/student": (context) => const StudentInterface(),
        "/ticket": (context) => const BuyTicket(),
        "/transfert-ticket": (context) => const TransfertTicket(),
        "/transfert-credit": (context) => const TransfertCredit(),
        "/cancel-transfert-ticket": (context) => const CancelTrsfTicket(),
        "/cancel-transfert-credit": (context) => const CancelTrsfCredit(),
        "/consult-account": (context) => const ConsultAccount(),
        "/update-profile": (context) => const UpdateProfile(),
        "/porter": (context) => const PorterInterface(),
        "/debit-account": (context) => const DebitAccount(),
        "/agent": (context) => const AgentInterface(),
        "/credit-account": (context) => const CreditAccount(),
        "/cancel-recharge": (context) => const CancelRecharge(),
        "/settings": (context) => const SettingsPage(),
        "/log-out": (context) => const LogOut(),
      },
      initialRoute: "/cover",
    );
  }
}

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
