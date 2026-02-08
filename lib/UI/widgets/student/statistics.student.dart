import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/home/homebloctitle.dart';
import 'package:senticket_front/UI/widgets/home/imageasset.template.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/home/stat.label.dart';
import 'package:senticket_front/constants.dart';

class StatisticsStudent extends StatefulWidget {
  const StatisticsStudent({super.key});

  @override
  State<StatisticsStudent> createState() => _StatisticsStudentState();
}

class _StatisticsStudentState extends State<StatisticsStudent> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Homebloctitle(text: "Statistiques")],
        ),
        const SizeboxHeightSession(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
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
                          const Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Text(
                              "20",
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
                    children: [
                      Column(
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
                                child: StatisticsLabel(label: "Non utilisés"),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Text(
                              "10",
                              style: TextStyle(
                                color: kThirdColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
                                  child: StatisticsLabel(label: "Utilisés"),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                              child: Text(
                                "10",
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
