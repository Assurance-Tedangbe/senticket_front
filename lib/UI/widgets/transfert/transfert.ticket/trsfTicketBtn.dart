import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TransfertTicketBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const TransfertTicketBtn({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 340,
      height: 95,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          /*  backgroundColor:
                  userProvider.isConsultFormValid &&
                      !userProvider.isConsultingUser
                  ? kPrimaryColor
                  : greyBorderColor, */
          backgroundColor: isLoading ? greyBorderColor : kPrimaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kSecondColor),
                ),
              )
            : const Text(
                'Transférer ticket(s)',
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

/* class TransfertTicketBtn extends StatefulWidget {
  const TransfertTicketBtn({super.key});

  @override
  State<TransfertTicketBtn> createState() => _TransfertTicketBtnState();
}

class _TransfertTicketBtnState extends State<TransfertTicketBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 330,
      height: 95,
      child: ElevatedButton(
        onPressed: () => print('pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text(
          'Transférer ticket(s)',
          style: TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} */
