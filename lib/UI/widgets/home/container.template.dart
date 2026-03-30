import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/constants.dart';

class ContainerTemplate extends StatelessWidget {
  final String servicename;
  final Function() press;
  final String imagepath;

  const ContainerTemplate({
    super.key,
    required this.press,
    required this.servicename,
    required this.imagepath,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height * 0.2,
      width: size.width * 0.23,
      decoration: BoxDecoration(
        color: textContainerColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2)),
        ],
        border: Border.all(color: kPrimaryColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 250, 250, 250),
              elevation: 1.0,
            ),
            onPressed: press,
            child: SizedBox(
              height: size.height * 0.08,
              width: size.width * 0.3,
              child: Image.asset(imagepath, width: 55.0, height: 65.0),
            ),
          ),

          const SizeboxTemplate(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Text(
              servicename,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
