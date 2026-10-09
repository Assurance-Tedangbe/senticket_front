import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/constants.dart';

class AccessDebitPageBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFormValid;

  const AccessDebitPageBtn({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isFormValid = true,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      /* width: 320,
      height: 95, */
      width: size.width * 0.99,
      height: size.height / 8.0,
      child: ElevatedButton(
        onPressed: isLoading || !isFormValid ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid && !isLoading
              ? kPrimaryColor
              : greyBorderColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? CustomCircularProgressIndicator()
            : const Text(
                'Valider',
                style: TextStyle(
                  color: kSecondColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

