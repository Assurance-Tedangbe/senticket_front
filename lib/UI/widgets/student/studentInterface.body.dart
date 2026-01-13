import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/home/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/home/soldeSection.dart';
import 'package:senticket_front/UI/widgets/student/statistics.student.dart';
import 'package:senticket_front/UI/widgets/student/student.services.dart';

class StudentBody extends StatelessWidget {
  const StudentBody({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: const Column(children: [
            SoldeSection(),
            SizeboxHeightSession(),
            StudentServices(),
            SizeboxHeightSession(),
            StatisticsStudent()
          ]),
        ),
      ),
    );
  }
}
