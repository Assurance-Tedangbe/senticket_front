import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/buyTicket/buyTicketBtn.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class RequestSection extends StatefulWidget {
  const RequestSection({super.key});

  @override
  State<RequestSection> createState() => _RequestSectionState();
}

class _RequestSectionState extends State<RequestSection> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
    });

    // Désélectionner tous les tickets
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    ticketProvider.clearAllSelections();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuyTicketBtn(
                  onSuccess: () {
                    _clearForm();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
