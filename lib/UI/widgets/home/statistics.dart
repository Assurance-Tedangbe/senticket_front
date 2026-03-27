import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/UI/widgets/home/bloctitle.dart';
import 'package:senticket_front/UI/widgets/home/imageasset.template.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/home/stat.label.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

import '../../../provider/ticket_provider.dart' show TicketProvider;

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  Future<void> _loadStatistics() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    // Charger les statistiques globales sans userId
    await ticketProvider.loadTicketStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final globalStats = ticketProvider.globalStats;
    final availableStats = ticketProvider.availableStats;
    final isLoading = ticketProvider.isLoadingStatistics;
    Size size = MediaQuery.of(context).size;

    // Vérifier si l'utilisateur est connecté et a le rôle ADMIN
    final isAuthenticatedAdmin = currentUser != null &&
        currentUser.role.name.toUpperCase() == 'ADMIN';

    // Déterminer les valeurs à afficher
    // Si l'utilisateur est authentifié admin, utiliser les vraies stats
    // Sinon, afficher 0 pour toutes les valeurs
    final totalPurchased = (isAuthenticatedAdmin && globalStats != null)
        ? globalStats.totalPurchasedTickets
        : 0;
    final totalDebited = (isAuthenticatedAdmin && globalStats != null)
        ? globalStats.totalDebitedTickets
        : 0;
    final typeAAvailable = (isAuthenticatedAdmin && availableStats != null)
        ? availableStats.typeATicketsAvailable
        : 0;
    final typeBAvailable = (isAuthenticatedAdmin && availableStats != null)
        ? availableStats.typeBTicketsAvailable
        : 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [BlocTitle(text: "Statistiques globales des tickets")],
        ),
        const SizeboxHeightSession(),
        if (isLoading)
          const Center(child: CustomCircularProgressIndicator())
        /*else if (globalStats == null)
          const Center(
            child: Text(
              "Aucune statistique disponible",
              style: TextStyle(color: greyBorderColor),
            ),
          )*/
        else
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                /// Total global achetés et débités
                Container(
                  width: size.width / 1.5,
                  height: size.height / 13.0,
                  decoration: BoxDecoration(
                    color: ticketSectionColor,
                    borderRadius: const BorderRadius.all(Radius.circular(17.0)),
                    boxShadow: const [
                      BoxShadow(
                        color: boxshadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: kPrimaryColor, width: 0.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// Total global achetés
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size.width / 20.0,
                                height: size.height / 50.0,
                                child: const ImageAsset(
                                  iconpath: "images/ticket_icon.JPG",
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(
                                  6.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                ),
                                child: StatisticsLabel(label: "Total achetés"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                           Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Text(
                              totalPurchased.toString(),
                              style: TextStyle(
                                color: kThirdColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Séparateur vertical
                      Container(
                        width: 1,
                        height: 50,
                        color: kPrimaryColor,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      // just added
                      /// Total global débités
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width / 20.0,
                                  height: size.height / 50.0,
                                  child: const ImageAsset(
                                    iconpath: "images/ticket_icon.JPG",
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    6.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  child: StatisticsLabel(label: "Total debités"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                              child: Text(
                                totalDebited.toString(),
                                style: TextStyle(
                                  color: kThirdColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //const SizeboxHeightSession(),
            Stack(
              children: [
                /// Tickets disponibles (Type A et Type B)
                if (availableStats != null)
                Container(
                  width: size.width / 1.5,
                  height: size.height / 12.0,
                  decoration: BoxDecoration(
                    color: ticketSectionColor,
                    borderRadius: const BorderRadius.all(Radius.circular(17.0)),
                    boxShadow: const [
                      BoxShadow(
                        color: boxshadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: kPrimaryColor, width: 0.5),
                  ),
                child:
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// Type A disponibles
                      Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: size.width / 25.0,
                                height: size.height / 30.0,
                                child: const ImageAsset(
                                  iconpath: "images/breakfast.JPG",
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(
                                  6.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                ),
                                child: StatisticsLabel(label: "A dispo."),
                              ),
                            ],
                          ),
                           Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Text(
                              typeAAvailable.toString(),
                              style: TextStyle(
                                color: kThirdColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Séparateur vertical
                      Container(
                        width: 1,
                        height: 50,
                        color: kPrimaryColor,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),

                      /// Type B disponibles
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.food_bank),
                                StatisticsLabel(label: "B dispo."),
                              ],
                            ),
                            //const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                              child: Text(
                                typeBAvailable.toString(),
                                style: const TextStyle(
                                  color: kThirdColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
