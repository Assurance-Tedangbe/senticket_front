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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: isLoading || !isFormValid ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid && !isLoading
              ? kPrimaryColor
              : greyBorderColor,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? CustomCircularProgressIndicator()
            : const Text('Valider', style: TextStyle(color: kSecondColor)),
      ),
    );
  }
}

/* Impl. sans dynamisation:
class DebitValidateBtn extends StatefulWidget {
  const DebitValidateBtn({super.key});

  @override
  State<DebitValidateBtn> createState() => _DebitValidateBtnState();
}

class _DebitValidateBtnState extends State<DebitValidateBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: () => print('validate pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Valider'),
      ),
    );
  }
} */
