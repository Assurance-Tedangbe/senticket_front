import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';
import 'package:senticket_front/constants.dart';

class ContainerTemplate extends StatelessWidget {
  final String servicename;
  final Function() press;
  final String imagepath;

  const ContainerTemplate(
      {super.key,
      required this.press,
      required this.servicename,
      required this.imagepath});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height * 0.2,
      width: size.width * 0.2,
      decoration: BoxDecoration(
          color: textContainerColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
          ],
          border: Border.all(color: textContainerColor, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 250, 250, 250),
                elevation: 0.0),
            onPressed: press,
            child: Image.asset(imagepath, width: 55.0, height: 55.0),
          ),
          const SizeboxTemplate(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              servicename,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
