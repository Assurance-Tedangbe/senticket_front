// ÉTATS DU PROCESSUS DE PAIEMENT
//
// Chaque état correspond à une étape du flux de paiement PayDunya.
// L'UI (RequestSection) adapte son affichage selon cet état.
enum PaymentState {
  idle, // État initial : pas de paiement en cours, bouton "Payer" actif
  loading, // Appel HTTP en cours vers le backend (POST /initiate)
  webViewOpen, // URL PayDunya disponible → l'UI doit ouvrir le WebView
  polling, // WebView fermé → vérification périodique du statut
  success, // Paiement confirmé → tickets attribués, afficher le succès
  cancelled, // Annulé par l'utilisateur sur la page PayDunya
  failed, // Erreur technique ou paiement refusé
}
