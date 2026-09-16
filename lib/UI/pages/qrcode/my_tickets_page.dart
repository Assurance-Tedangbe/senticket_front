import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/qr/qr_ticket_widget.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/ticket_status.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/ticket_service.dart';

/// Page affichant les tickets achetés (status=BOOKED) de l'étudiant connecté.
/// Chaque ticket a un bouton QR → le portier peut scanner et débiter
/// ce ticket précis sans sélection manuelle.
class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userId = userProvider.currentUser?.userId;
    if (userId == null) return;

    // Charger les tickets Type A et Type B en parallèle
    await Future.wait([
      ticketProvider.getPurchasedTicketsByUser(
        studentId: userId,
        type: TicketType.a,
      ),
      ticketProvider.getPurchasedTicketsByUser(
        studentId: userId,
        type: TicketType.b,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tickets'),
        backgroundColor: kPrimaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kSecondColor,
          labelColor: kSecondColor,
          unselectedLabelColor: kSecondColor.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Type A — Petit-déj.'),
            Tab(text: 'Type B — Déj./Dîner'),
          ],
        ),
      ),
      body: Consumer2<UserProvider, TicketProvider>(
        builder: (context, userProvider, ticketProvider, _) {
          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Non connecté'));
          }
          if (ticketProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTicketList(ticketProvider.studentTicketsForDebit
                  .where((t) => t.type == TicketType.a).toList(), user, TicketType.a),
              _buildTicketList(ticketProvider.studentTicketsForDebit
                  .where((t) => t.type == TicketType.b).toList(), user, TicketType.b),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets, user, TicketType type) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 60, color: greyBorderColor),
            const SizedBox(height: 12),
            Text(
              'Aucun ticket ${type == TicketType.a ? 'A' : 'B'} disponible',
              style: const TextStyle(color: greyBorderColor, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(ticket, user);
      },
    );
  }

  Widget _buildTicketCard(Ticket ticket, user) {
    final isTypeA = ticket.type == TicketType.a;
    final color = isTypeA ? kPrimaryColor : cyanColor;
    final label = isTypeA ? 'Type A — Petit-déjeuner' : 'Type B — Déj./Dîner';
    final price = isTypeA ? '100 FCFA' : '150 FCFA';

    return Container(
      decoration: BoxDecoration(
        color: textContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
        boxShadow: const [
          BoxShadow(color: boxshadowColor, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Pastille de couleur
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),

            // Infos ticket
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: kThirdColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID #${ticket.id} — $price',
                    style: TextStyle(
                      fontSize: 12,
                      color: kThirdColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Bouton QR — affiche le QR de ce ticket
            TextButton.icon(
              onPressed: () => _showTicketQr(ticket, user),
              icon: Icon(Icons.qr_code, color: color, size: 18),
              label: Text(
                'QR',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketQr(Ticket ticket, user) {
    showDialog(
      context: context,
      builder: (_) => QrTicketWidget(ticket: ticket, owner: user),
    );
  }
}