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

List<ChangeNotifierProvider> getProviders() {
  return [
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
    /* ChangeNotifierProvider<AccountProvider>(
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
  ];
}
