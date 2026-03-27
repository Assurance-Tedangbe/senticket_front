import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/home/homebloctitle.dart';
import 'package:senticket_front/UI/widgets/home/imageasset.template.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/home/stat.label.dart';
import 'package:senticket_front/constants.dart';

import '../../../provider/ticket_provider.dart';
import '../../../provider/user_provider.dart' show UserProvider;

class StatisticsStudent extends StatefulWidget {
  const StatisticsStudent({super.key});

  @override
  State<StatisticsStudent> createState() => _StatisticsStudentState();
}

class _StatisticsStudentState extends State<StatisticsStudent> {

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  Future<void> _loadStatistics() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      // load statistics for connected user
      await ticketProvider.loadTicketStatistics(userId: currentUser.userId);
    } else {
      // Si pas d'utilisateur connecté, charger les stats globales
      await ticketProvider.loadTicketStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final userStats = ticketProvider.currentUserStats;
    final isLoading = ticketProvider.isLoadingStatistics;
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Homebloctitle(text: "Statistiques")],
        ),
        const SizeboxHeightSession(),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (userStats == null)
          const Center(
            child: Text(
              "Aucune statistique disponible",
              style: TextStyle(color: greyBorderColor),
            ),
          )
        else
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                /// Total tickets achetés et debités par l'utilisateur connecté
                Container(
                  width: size.width / 3.0,
                  height: size.height / 13.0,
                  decoration: BoxDecoration(
                    color: textContainerColor,
                    borderRadius: const BorderRadius.all(Radius.circular(17.0)),
                    boxShadow: const [
                      BoxShadow(
                        color: boxshadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: kPrimaryColor, width: 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size.width / 20.0,
                                height: size.height / 50.0,
                                child: const ImageAsset(
                                  iconpath: "images/increase.JPG",
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(
                                  6.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                ),
                                child: StatisticsLabel(label: "Total tickets"),
                              ),
                            ],
                          ),
                          //const SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Text(
                              userStats.totalTicketsCount.toString(),
                              style: TextStyle(
                                color: kThirdColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            /// Tickets achetés et débités par l'utilisateur connecté
            Stack(
              children: [
                Container(
                  width: size.width / 1.9,
                  height: size.height / 13.0,
                  decoration: BoxDecoration(
                    color: textContainerColor,
                    borderRadius: const BorderRadius.all(Radius.circular(17.0)),
                    boxShadow: const [
                      BoxShadow(
                        color: boxshadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: kPrimaryColor, width: 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// Tickets achetés par l'utilisateur connecté
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width / 25.0,
                                height: size.height / 30.0,
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
                                child: StatisticsLabel(label: "Achétés"),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 4),
                           Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Text(
                              userStats.purchasedTicketsCount.toString(),
                              style: TextStyle(
                                color: kThirdColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Séparateur vertical
                      Container(
                        width: 1,
                        height: 40,
                        color: kPrimaryColor,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width / 25.0,
                                  height: size.height / 30.0,
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
                                  child: StatisticsLabel(label: "Debités"),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                              child: Text(
                                userStats.debitedTicketsCount.toString(),
                                style: TextStyle(
                                  color: kThirdColor,
                                  fontSize: 12.0,
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
          ],
        ),
      ],
    );
  }
}
