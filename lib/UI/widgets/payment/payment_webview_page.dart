import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/provider/payment_provider.dart';

//**************** PAGE WEBVIEW PAYDUNYA *****************
//
// Affiche la page de paiement PayDunya dans un WebView intégré.
// L'utilisateur paie avec Wave ou Orange Money sans quitter l'app.
//
// Responsabilités :
//   1. Charger l'URL PayDunya dans le WebView
//   2. Détecter les redirections vers /return ou /cancel
//   3. Fermer le WebView et notifier PaymentProvider
//   4. Permettre la fermeture manuelle (bouton ×)
//
// Navigation :
//   RequestSection → push → PaymentWebViewPage → pop
//   PaymentWebViewPage appelle provider.onWebViewClosed()
//   RequestSection → push → PaymentResultPage
class PaymentWebViewPage extends StatefulWidget {
  // URL de la page de paiement reçue du backend PayDunya
  final String paymentUrl;

  const PaymentWebViewPage({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // Affiche un indicateur de chargement initial
  bool _hasNavigated = false; // Évite les navigations doubles (détection URL)

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  // Initialise le WebViewController avec toute la configuration nécessaire
  void _initWebViewController() {
    _controller = WebViewController()
      // Active JavaScript (nécessaire pour la page PayDunya)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Configure le délégué de navigation pour intercepter les URLs
      ..setNavigationDelegate(
        NavigationDelegate(
          // Appelé quand le WebView commence à charger une nouvelle page
          onPageStarted: (String url) {
            print('[WebView] Page démarrée: $url');
            if (mounted) setState(() => _isLoading = true);
            // Vérifier l'URL au début du chargement
            _detectPayDunyaRedirection(url);
          },
          // Appelé quand la page est complètement chargée
          onPageFinished: (String url) {
            print('[WebView] Page chargée: $url');
            if (mounted) setState(() => _isLoading = false);
          },
          // Appelé en cas d'erreur de chargement d'une ressource
          onWebResourceError: (WebResourceError error) {
            // Les erreurs de ressources sont normales lors des redirections PayDunya
            // Ne pas fermer le WebView pour ces erreurs (souvent bénignes)
            print(
              '[WebView] Erreur ressource: ${error.description} (${error.errorCode})',
            );
          },
          // Appelé AVANT le chargement d'une URL → point d'interception principal
          onNavigationRequest: (NavigationRequest request) {
            print('[WebView] Navigation vers: ${request.url}');
            _detectPayDunyaRedirection(request.url);
            // Toujours autoriser la navigation (PayDunya redirige souvent)
            return NavigationDecision.navigate;
          },
        ),
      )
      // Chargement de l'URL PayDunya reçue du backend
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // DÉTECTION DES REDIRECTIONS PAYDUNYA
  // PayDunya redirige le navigateur vers return_url ou cancel_url
  // après que l'utilisateur a terminé (succès ou annulation).
  //
  // Les URLs à détecter correspondent à celles configurées dans
  // application.properties du backend :
  //   paydunya.return-url=http://{IP}:8080/api/payments/return
  //   paydunya.cancel-url=http://{IP}:8080/api/payments/cancel
  void _detectPayDunyaRedirection(String url) {
    // Éviter de traiter la même URL plusieurs fois
    if (_hasNavigated) return;

    // Construire les patterns à détecter
    // Utilise NetworkConfig.baseUrl pour être cohérent avec payment_service.dart
    final baseUrl = NetworkConfig.baseUrl;

    // URL de retour après paiement réussi ou terminé
    // Pattern : http://{IP}:8080/api/payments/return?token=xxx
    if (url.contains('/api/payments/return')) {
      _hasNavigated = true;
      print('[WebView] URL de RETOUR détectée: $url');
      _closeWebView(cancelled: false);
      return;
    }

    // URL d'annulation si l'utilisateur clique "Annuler" sur PayDunya
    // Pattern : http://{IP}:8080/api/payments/cancel
    if (url.contains('/api/payments/cancel')) {
      _hasNavigated = true;
      print('[WebView] URL d\'ANNULATION détectée: $url');
      _closeWebView(cancelled: true);
      return;
    }
  }

  // Ferme le WebView et notifie le PaymentProvider du résultat
  // @param cancelled  true si /cancel détecté, false si /return détecté
  void _closeWebView({required bool cancelled}) {
    if (!mounted) return;

    // Notifier le provider AVANT de pop pour éviter les race conditions
    // onWebViewClosed() déclenche le polling ou passe en état cancelled
    context.read<PaymentProvider>().onWebViewClosed(cancelled: cancelled);

    // Retourner à RequestSection (pop de la stack de navigation)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paiement Senticket',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: kSecondColor,
        // Bouton × pour fermeture manuelle (équivalent à annuler)
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Fermer le paiement',
          onPressed: () {
            print('[WebView] Fermeture manuelle par l\'utilisateur');
            _closeWebView(cancelled: true);
          },
        ),
        // Barre de progression linéaire pendant le chargement des pages
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  backgroundColor: kPrimaryColor.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(kSecondColor),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          // WebView principal (toujours présent)
          WebViewWidget(controller: _controller),

          // Overlay de chargement initial (premier chargement de la page PayDunya)
          if (_isLoading)
            Container(
              color: kSecondColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: kPrimaryColor),
                    SizedBox(height: 20),
                    Text(
                      'Chargement de la page de paiement...',
                      style: TextStyle(
                        fontSize: 14,
                        color: greyBorderColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connexion sécurisée PayDunya',
                      style: TextStyle(fontSize: 12, color: greyBorderColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
