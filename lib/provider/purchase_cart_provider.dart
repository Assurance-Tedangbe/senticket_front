import 'package:flutter/foundation.dart';
import '../model/ticket_pricing.dart';

class PurchaseCartProvider extends ChangeNotifier {
  int _countA = 0;  // Nombre de tickets Type A à acheter
  int _countB = 0;

  int get countA => _countA;
  int get countB => _countB;
  int get totalTickets => _countA + _countB;
  double get totalAmount => TicketPricing.total(_countA, _countB);
  bool get isEmpty => totalTickets == 0;

  bool get canIncrementA => _countA < TicketPricing.maxPerType;
  bool get canIncrementB => _countB < TicketPricing.maxPerType;

  void incrementA() {
    if (!canIncrementA) return;
    _countA++;
    notifyListeners();
  }

  void decrementA() {
    if (_countA == 0) return;
    _countA--;
    notifyListeners();
  }

  void incrementB() {
    if (!canIncrementB) return;
    _countB++;
    notifyListeners();
  }

  void decrementB() {
    if (_countB == 0) return;
    _countB--;
    notifyListeners();
  }

  void clear() {
    _countA = 0;
    _countB = 0;
    notifyListeners();
  }
}