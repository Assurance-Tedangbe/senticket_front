import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/transaction_type.dart';
import 'package:senticket_front/model/transaction_history_model.dart';
import 'package:senticket_front/provider/transaction_history_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

/// Widget principal de la page d'historique
class HistoricBody extends StatefulWidget {
  const HistoricBody({super.key});

  @override
  State<HistoricBody> createState() => _HistoricBodyState();
}

class _HistoricBodyState extends State<HistoricBody> {
  // Contrôleurs pour les dates
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Type de transaction sélectionné
  String _selectedTransactionType = 'ALL';

  // Options pour le dropdown selon le rôle de l'utilisateur
  List<Map<String, String>> _filterOptions = [];

  // Scroll controller pour le chargement infini
  final ScrollController _scrollController = ScrollController();

  // Stocker l'ID de l'utilisateur connecté pour les filtres backend
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _setupFilterOptions();
    _setupScrollListener();
    _loadInitialTransactions();
  }

  /// Configure les options de filtre selon le rôle de l'utilisateur
  void _setupFilterOptions() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    final userRole = userProvider.currentUser?.role.name.toUpperCase() ?? '';

    // Stocker l'ID de l'utilisateur connecté
    _currentUserId = currentUser?.userId;

    // Réinitialiser les options
    _filterOptions = [];

    // Configurer les options selon le rôle
    if (userRole == 'ETUDIANT') {
      // Étudiant: voit toutes les options (Toutes, Achats, Débits, Transferts)
      // Les transactions sont filtrées automatiquement par le backend avec userId
      _filterOptions = [
        {'value': 'ALL', 'label': 'Toutes les transactions'},
        {'value': 'PURCHASE', 'label': 'Achats de tickets'},
        {'value': 'DEBIT', 'label': 'Débits de compte'},
        {'value': 'TRANSFER', 'label': 'Transferts de tickets'},
      ];
    } else if (userRole == 'PORTIER') {
      // Portier: voit uniquement l'option "Débits de compte"
      // Les transactions sont filtrées par le backend avec l'ID du portier
      _filterOptions = [
        {'value': 'DEBIT', 'label': 'Débits de compte'},
      ];
      // Pour le portier, on force le type à DEBIT
      _selectedTransactionType = 'DEBIT';
    } else if (userRole == 'ADMIN') {
      // Admin: voit toutes les options (Toutes, Achats, Débits, Transferts)
      _filterOptions = [
        {'value': 'ALL', 'label': 'Toutes les transactions'},
        {'value': 'PURCHASE', 'label': 'Achats de tickets'},
        {'value': 'DEBIT', 'label': 'Débits de compte'},
        {'value': 'TRANSFER', 'label': 'Transferts de tickets'},
      ];
    }

    /*     // Options par défaut (pour tous)
    _filterOptions = [
      {'value': 'ALL', 'label': 'Toutes les transactions'},
    ];

    // Ajouter les options selon le rôle
    if (userRole == 'ETUDIANT') {
      // Étudiant: ne voit que ses achats et ses débits
      _filterOptions.addAll([
        {'value': 'PURCHASE', 'label': 'Achats de tickets'},
        {'value': 'DEBIT', 'label': 'Débits de compte'},
      ]);
    } else if (userRole == 'PORTIER') {
      // Portier: ne voit que les débits qu'il a effectués
      _filterOptions.addAll([
        {'value': 'DEBIT', 'label': 'Débits de compte'},
      ]);
    } else if (userRole == 'ADMIN') {
      // Admin: voit tout
      _filterOptions.addAll([
        {'value': 'PURCHASE', 'label': 'Achats de tickets'},
        {'value': 'DEBIT', 'label': 'Débits de compte'},
        {'value': 'TRANSFER', 'label': 'Transferts de tickets'},
      ]);
    } */
  }

  /// Configure l'écouteur de scroll pour le chargement infini
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final provider = Provider.of<TransactionHistoryProvider>(
        context,
        listen: false,
      );

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!provider.isLoading && provider.hasMore) {
          _loadMoreTransactions();
        }
      }
    });
  }

  /// Charge les transactions initiales
  Future<void> _loadInitialTransactions() async {
    final provider = Provider.of<TransactionHistoryProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userRole = userProvider.currentUser?.role.name.toUpperCase() ?? '';

    // Pour le portier, on passe l'ID du portier comme paramètre pour filtrer
    // ses propres débits
    if (userRole == 'PORTIER') {
      await provider.loadTransactionsForUser(
        transactionType: _selectedTransactionType,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        userId: _currentUserId, // Filtrer par l'ID du portier
        reset: true,
      );
    } else {
      // Pour les autres rôles, on charge normalement
      await provider.loadTransactions(
        transactionType: _selectedTransactionType,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        reset: true,
      );
    }
  }

  /* /// Charge les transactions initiales
  Future<void> _loadInitialTransactions() async {
    final provider = Provider.of<TransactionHistoryProvider>(
      context,
      listen: false,
    );

    await provider.loadTransactions(
      transactionType: _selectedTransactionType,
      startDate: _getStartDate(),
      endDate: _getEndDate(),
      reset: true,
    );
  } */

  /// Charge plus de transactions (scroll infini)
  Future<void> _loadMoreTransactions() async {
    final provider = Provider.of<TransactionHistoryProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userRole = userProvider.currentUser?.role.name.toUpperCase() ?? '';

    if (userRole == 'PORTIER') {
      await provider.loadTransactionsForUser(
        transactionType: _selectedTransactionType,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        userId: _currentUserId,
        reset: false,
      );
    } else {
      await provider.loadTransactions(
        transactionType: _selectedTransactionType,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        reset: false,
      );
    }
  }
  /* /// Charge plus de transactions (scroll infini)
  Future<void> _loadMoreTransactions() async {
    final provider = Provider.of<TransactionHistoryProvider>(
      context,
      listen: false,
    );

    await provider.loadTransactions(
      transactionType: _selectedTransactionType,
      startDate: _getStartDate(),
      endDate: _getEndDate(),
      reset: false,
    );
  } */

  /// Récupère la date de début
  DateTime? _getStartDate() {
    if (_startDateController.text.isNotEmpty) {
      return DateTime.parse(_startDateController.text);
    }
    return null;
  }

  /// Récupère la date de fin
  DateTime? _getEndDate() {
    if (_endDateController.text.isNotEmpty) {
      return DateTime.parse(_endDateController.text);
    }
    return null;
  }

  /// Applique les filtres et recharge les transactions
  Future<void> _applyFilters() async {
    final provider = Provider.of<TransactionHistoryProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userRole = userProvider.currentUser?.role.name.toUpperCase() ?? '';

    if (userRole == 'PORTIER') {
      await provider.loadTransactionsForUser(
        transactionType: _selectedTransactionType,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        userId: _currentUserId,
        reset: true,
      );
    } else {
      await provider.loadTransactions(
        transactionType: _selectedTransactionType,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        reset: true,
      );
    }
  }
  /*  /// Applique les filtres et recharge les transactions
  Future<void> _applyFilters() async {
    final provider = Provider.of<TransactionHistoryProvider>(
      context,
      listen: false,
    );

    await provider.loadTransactions(
      transactionType: _selectedTransactionType,
      startDate: _getStartDate(),
      endDate: _getEndDate(),
      reset: true,
    );
  } */

  /// Affiche le sélecteur de date
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionHistoryProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.currentUser?.role.name.toUpperCase() ?? '';
    final transactions = provider.transactions;
    final isLoading = provider.isLoading;
    final error = provider.error;

    return Column(
      children: [
        // ========== FILTRES ==========
        // Pour le portier, on désactive le dropdown car il n'a qu'une seule option
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedTransactionType,
            decoration: const InputDecoration(
              labelText: 'Type de transaction',
              // labelStyle: TextStyle(color: dateColor),
              border: OutlineInputBorder(),
            ),
            items: _filterOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: userRole == 'PORTIER'
                ? null // Pour le portier, le dropdown est désactivé
                : (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTransactionType = newValue;
                      });
                      _applyFilters();
                    }
                  },
            // Si c'est un portier, afficher que c'est désactivé
            hint: userRole == 'portier' ? const Text('Débits de compte') : null,
          ),
        ),

        // ========== SÉLECTEURS DE DATES ==========
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date de début
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(_startDateController),
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
                          child: Icon(
                            Icons.calendar_month,
                            color: dateColor,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _startDateController.text.isEmpty
                                ? 'Date de début'
                                : _startDateController.text,
                            style: TextStyle(
                              color: _startDateController.text.isEmpty
                                  ? dateColor
                                  : kThirdColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Date de fin
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(_endDateController),
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
                          child: Icon(
                            Icons.calendar_month,
                            color: dateColor,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _endDateController.text.isEmpty
                                ? 'Date de fin'
                                : _endDateController.text,
                            style: TextStyle(
                              color: _endDateController.text.isEmpty
                                  ? dateColor
                                  : kThirdColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ========== LISTE DES TRANSACTIONS ==========
        Expanded(
          child: RefreshIndicator(
            onRefresh: _applyFilters,
            child: error.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error,
                          style: const TextStyle(color: redErrorColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                          ),
                          child: const Text(
                            'Réessayer',
                            style: TextStyle(color: kSecondColor),
                          ),
                        ),
                      ],
                    ),
                  )
                : transactions.isEmpty && !isLoading
                ? const Center(
                    child: Text(
                      'Aucune transaction trouvée',
                      style: TextStyle(color: greyBorderColor),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: transactions.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transactions.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CustomCircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildTransactionCard(transactions[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /// Construit la carte d'une transaction
  Widget _buildTransactionCard(TransactionHistoryDTO transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Optionnel: afficher les détails dans un dialogue
          _showTransactionDetails(transaction);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec type et date
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

              // Détails de la transaction
              Text(
                transaction.getTransactionDetails(),
                style: const TextStyle(fontSize: 13, color: kThirdColor),
              ),
              const SizedBox(height: 4),

              // Informations sur les tickets
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
                  const SizedBox(width: 12),
                  const Icon(Icons.label, size: 14, color: greyBorderColor),
                  const SizedBox(width: 4),
                  Text(
                    transaction.ticketTypes.join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: greyBorderColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              // Indicateur d'annulation pour les transferts
              if (transaction.transactionType == TransactionType.transfer &&
                  transaction.transferCanceled == true)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    ' Transfert annulé',
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

  /// Affiche les détails d'une transaction dans une boîte de dialogue
  void _showTransactionDetails(TransactionHistoryDTO transaction) {
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
                'Types des tickets',
                transaction.ticketTypes.join(', '),
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

  /// Construit une ligne de détail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  /// Retourne la couleur associée au type de transaction
  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return blueOfImages;
      case TransactionType.debit:
        return cyanColor;
      case TransactionType.transfer:
        return kPrimaryColor;
    }
  }
}

/*
class HistoricBody extends StatefulWidget {
  const HistoricBody({super.key});

  @override
  State<HistoricBody> createState() => _HistoricBodyState();
}

class _HistoricBodyState extends State<HistoricBody> {
  TextEditingController dateController1 = TextEditingController();
  TextEditingController dateController2 = TextEditingController();
  TextEditingController searchTransactionController = TextEditingController();
  String _selectedItem = 'Toutes les transactions';
  var items = [
    'Toutes les transactions',
    'Achat ticket',
    'Transfert ticket',
    'Débiter compte',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
          child: DropdownButtonFormField<String>(
            value: _selectedItem,
            onChanged: (String? value) {
              setState(() {
                _selectedItem = value!;
                if (_selectedItem == true) {
                  print(_selectedItem);
                  String kw = _selectedItem;
                  context.read<HistoricBloc>().add(
                    SearchHistoricEvent(keyword: kw),
                  );
                }
              });
            },
            decoration: const InputDecoration(
              labelText: 'Selectionner une option',
              border: OutlineInputBorder(),
            ),
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(children: [Text(value)]),
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 160,
                height: 50,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: kSecondColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: greyBorderColor, width: 1),
                ),
                child: TextField(
                  keyboardType: TextInputType.datetime,
                  controller: dateController1,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                    prefixIcon: Icon(
                      Icons.calendar_month,
                      color: dateColor,
                      size: 15,
                    ),
                    hintText: 'Choisir date de début',
                    hintStyle: TextStyle(color: dateColor, fontSize: 10),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1997),
                      lastDate: DateTime(2050),
                    );

                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                      setState(() {
                        dateController1.text = formattedDate.toString();
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ),
              Container(
                width: 160,
                height: 50,
                decoration: BoxDecoration(
                  color: kSecondColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: greyBorderColor, width: 1),
                ),
                child: TextField(
                  keyboardType: TextInputType.datetime,
                  controller: dateController2,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                    prefixIcon: Icon(
                      Icons.calendar_month,
                      color: dateColor,
                      size: 15,
                    ),
                    hintText: 'Choisir date de fin',
                    hintStyle: TextStyle(color: dateColor, fontSize: 10),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1997),
                      lastDate: DateTime(2050),
                    );

                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                      setState(() {
                        dateController2.text = formattedDate.toString();
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        //blocBuilder
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
          child: BlocBuilder<HistoricBloc, HistoricState>(
            builder: (context, state) {
              if (state is SearchHistoricLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SearchHistoricErrorState) {
                return Column(
                  children: [
                    Text(
                      state.errorMessage,
                      style: const TextStyle(color: redErrorColor),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Retry'),
                    ),
                  ],
                );
              } else if (state is SearchHistoricSucessState &&
                  searchTransactionController.selection.isValid
              //contains('services')
              ) {
                return const Expanded(child: ResearchListView());
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
 */
