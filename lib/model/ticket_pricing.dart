class TicketPricing {
  static const double priceA = 50;
  static const double priceB = 100;
  static const int maxPerType = 20; // plafond par commande

  static double total(int countA, int countB) =>
      countA * priceA + countB * priceB;
}