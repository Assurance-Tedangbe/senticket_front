import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/widgets/customWidgets/custom.circular.progress.indicator.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/transaction_type.dart';
import 'package:senticket_front/model/transaction_history_model.dart';
import 'package:senticket_front/provider/transaction_history_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

/// Liste de l'historique des transactions, selon le rôle :
///  - ETUDIANT : ses achats, débits et transferts
///  - PORTIER  : uniquement les débits qu'il a effectués
///  - ADMIN    : toutes les transactions
/// Filtres : type et dates. Chargement infini au scroll.
class HistoricBody extends StatefulWidget {
  const HistoricBody({super.key});

  @override
  State<HistoricBody> createState() => _HistoricBodyState();
}

class _HistoricBodyState extends State<HistoricBody> {
  // ==================== ÉTATS ====================
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedTransactionType = 'ALL';
  List<Map<String, String>> _filterOptions = [];

  int? _currentUserId;
  bool _isAuthenticated = false;
  String _userRole = '';

  static const _allTypes = [
    {'value': 'ALL', 'label': 'Toutes les transactions'},
    {'value': 'PURCHASE', 'label': 'Achats de tickets'},
    {'value': 'DEBIT', 'label': 'Débits de compte'},
    {'value': 'TRANSFER', 'label': 'Transferts de tickets'},
  ];

  // ==================== CYCLE DE VIE ====================
  @override
  void initState() {
    super.initState();
    _initFromCurrentUser();
    _scrollController.addListener(_onScroll);
    if (_isAuthenticated) {
      // Après le premier build : évite notifyListeners() pendant la construction
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetch(reset: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _startDateController.dispose();
    _endDateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Lit l'utilisateur connecté et prépare les filtres (sans setState : appelé dans initState)
  void _initFromCurrentUser() {
    final user = context.read<UserProvider>().currentUser;
    _isAuthenticated = user != null;
    if (user == null) return;

    _userRole = user.role.name.toUpperCase();
    _currentUserId = user.userId;

    if (_userRole == 'PORTIER') {
      _filterOptions = [
        {'value': 'DEBIT', 'label': 'Débits de compte'},
      ];
      _selectedTransactionType = 'DEBIT';
    } else {
      // ETUDIANT et ADMIN
      _filterOptions = List<Map<String, String>>.from(_allTypes);
    }
  }

  // ==================== CHARGEMENT ====================

  /// Détecte l'arrivée en bas de liste (marge de 200 px)
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = context.read<TransactionHistoryProvider>();
    final nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom && !provider.isLoading && provider.hasMore) {
      _fetch(reset: false);
    }
  }

  /// Point d'entrée unique de chargement, selon le rôle.
  /// reset = true : première page (filtres appliqués, rafraîchissement)
  /// reset = false : page suivante
  Future<void> _fetch({required bool reset}) async {
    final provider = context.read<TransactionHistoryProvider>();
    final start = _getStartDate();
    final end = _getEndDate();

    switch (_userRole) {
      case 'ETUDIANT':
        await provider.loadTransactionsForUser(
          transactionType: _selectedTransactionType,
          startDate: start,
          endDate: end,
          userId: _currentUserId,
          reset: reset,
        );
        break;
      case 'PORTIER':
        await provider.loadTransactionsForUser(
          transactionType: 'DEBIT',
          startDate: start,
          endDate: end,
          userId: _currentUserId,
          reset: reset,
        );
        break;
      case 'ADMIN':
        await provider.loadTransactions(
          transactionType: _selectedTransactionType,
          startDate: start,
          endDate: end,
          reset: reset,
        );
        break;
    }
  }

  Future<void> _applyFilters() => _fetch(reset: true);

  // ==================== DATES ====================

  DateTime? _getStartDate() => _parseDate(_startDateController.text);
  DateTime? _getEndDate() => _parseDate(_endDateController.text);

  /// Lecture tolérante : une saisie invalide donne null au lieu de planter
  DateTime? _parseDate(String text) =>
      text.isEmpty ? null : DateTime.tryParse(text);

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    });
    _applyFilters();
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionHistoryProvider>();
    final transactions = provider.transactions;
    final isLoading = provider.isLoading;
    final error = provider.error;

    // Non authentifié
    if (!_isAuthenticated) {
      return _buildEmptyHistory(
        message: "Veuillez vous connecter pour voir l'historique",
        icon: Icons.lock_outline,
        showLoginButton: true,
      );
    }

    return Column(
      children: [
        _buildTypeFilter(),
        _buildDateFilters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _applyFilters,
            child: _buildList(transactions, isLoading, error),
          ),
        ),
      ],
    );
  }

  /// Corps de liste : toujours scrollable pour que le "tirer pour rafraîchir"
  /// fonctionne aussi en cas d'erreur ou de liste vide
  Widget _buildList(
      List<TransactionHistoryDTO> transactions,
      bool isLoading,
      String error,
      ) {
    // Erreur
    if (error.isNotEmpty) {
      return _scrollableCenter(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error,
              style: const TextStyle(color: redErrorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: kSecondColor),
              ),
            ),
          ],
        ),
      );
    }

    // Premier chargement
    if (isLoading && transactions.isEmpty) {
      return _scrollableCenter(const CustomCircularProgressIndicator());
    }

    // Aucune transaction
    if (transactions.isEmpty) {
      return _scrollableCenter(
        _buildEmptyHistory(
          message: 'Aucun historique trouvé',
          icon: Icons.history,
          subtitle: 'Les transactions que vous effectuerez apparaîtront ici',
        ),
      );
    }

    // Liste normale
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: transactions.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == transactions.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CustomCircularProgressIndicator()),
          );
        }
        return _buildTransactionCard(transactions[index]);
      },
    );
  }

  Widget _scrollableCenter(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(child: child),
        ),
      ),
    );
  }

  // ==================== FILTRES ====================

  Widget _buildTypeFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTransactionType,
        decoration: const InputDecoration(
          labelText: 'Type de transaction',
          border: OutlineInputBorder(),
        ),
        items: _filterOptions
            .map(
              (o) => DropdownMenuItem<String>(
            value: o['value'],
            child: Text(o['label']!),
          ),
        )
            .toList(),
        // Le portier n'a qu'une option : dropdown désactivé
        onChanged: _userRole == 'PORTIER'
            ? null
            : (String? value) {
          if (value == null) return;
          setState(() => _selectedTransactionType = value);
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildDateFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
      child: Row(
        children: [
          Expanded(
            child: _dateField(_startDateController, 'Date de début'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dateField(_endDateController, 'Date de fin'),
          ),
        ],
      ),
    );
  }

  Widget _dateField(TextEditingController controller, String placeholder) {
    final isEmpty = controller.text.isEmpty;
    return GestureDetector(
      onTap: () => _selectDate(controller),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: secondColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: kPrimaryColor, width: 1),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.calendar_month, color: dateColor, size: 18),
            ),
            Expanded(
              child: Text(
                isEmpty ? placeholder : controller.text,
                style: TextStyle(
                  color: isEmpty ? dateColor : kThirdColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ÉCRAN VIDE ====================

  Widget _buildEmptyHistory({
    required String message,
    required IconData icon,
    String? subtitle,
    bool showLoginButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: greyBorderColor),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: greyBorderColor),
              textAlign: TextAlign.center,
            ),
          ],
          if (showLoginButton) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
              icon: const Icon(Icons.login),
              label: const Text('Se connecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kSecondColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== CARTE D'UNE TRANSACTION ====================

  Widget _buildTransactionCard(TransactionHistoryDTO transaction) {
    final summary = transaction.ticketSummary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type et date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTransactionColor(transaction.transactionType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.getTransactionLabel(),
                      style: const TextStyle(
                        color: kSecondColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                    style: const TextStyle(color: dateColor, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Acteurs de la transaction
              Text(
                transaction.getTransactionDetails(),
                style: const TextStyle(fontSize: 13, color: kThirdColor),
              ),
              const SizedBox(height: 4),

              // Nombre de tickets, résumé par type et montant
              Row(
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    size: 14,
                    color: greyBorderColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${transaction.ticketsCount} ticket(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kThirdColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (summary != null && summary.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.label, size: 14, color: greyBorderColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        summary,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: greyBorderColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Transfert annulé
              if (transaction.transactionType == TransactionType.transfer &&
                  transaction.transferCanceled == true)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Transfert annulé',
                    style: TextStyle(
                      fontSize: 11,
                      color: dateColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DÉTAILS (DIALOGUE) ====================

  void _showTransactionDetails(TransactionHistoryDTO transaction) {
    final summary = transaction.ticketSummary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.getTransactionLabel()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', transaction.id.toString()),
              _buildDetailRow(
                'Date',
                DateFormat('dd/MM/yyyy HH:mm:ss').format(transaction.date),
              ),
              _buildDetailRow(
                'Nombre de tickets',
                transaction.ticketsCount.toString(),
              ),
              _buildDetailRow(
                'IDs des tickets',
                transaction.ticketIds.join(', '),
              ),
              _buildDetailRow(
                'Détail',
                (summary == null || summary.isEmpty) ? '-' : summary,
              ),
              if (transaction.amount != null)
                _buildDetailRow(
                  'Montant',
                  '${transaction.amount!.toInt()} FCFA',
                ),
              const Divider(),
              _buildDetailRow('Détails', transaction.getTransactionDetails()),
              if (transaction.transactionType == TransactionType.transfer)
                _buildDetailRow(
                  'Statut',
                  transaction.transferCanceled == true ? 'Annulé' : 'Effectué',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return kPrimaryColor;
      case TransactionType.debit:
        return blueOfImages;
      case TransactionType.transfer:
        return kPrimaryColor;
    }
  }
}