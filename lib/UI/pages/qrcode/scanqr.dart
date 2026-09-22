import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/qr_code_model.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

/// Page de scan QR code générique.
/// Redirige automatiquement vers l'opération adaptée selon :
///   - le rôle de l'utilisateur connecté (PORTIER → débit, ETUDIANT → transfert)
///   - le contenu du QR code scanné
///
/// Peut aussi être appelée avec un [operationType] explicite pour forcer
/// l'opération depuis un bouton dédié.
class ScanQR extends StatefulWidget {
  final ScanOperationType? operationType;
  final bool expectTicketQr; // ← nouveau

  const ScanQR({super.key, this.operationType, this.expectTicketQr = false});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

enum ScanOperationType { debit, transfer }

class _ScanQRState extends State<ScanQR> {
  bool _hasScanned = false;
  String? _errorMessage;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    // Éviter les scans multiples
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _hasScanned = true);
    await _controller.stop();

    final qrString = barcode!.rawValue!;
    print('[ScanQR] QR scanné: $qrString');

    // Parser les données du QR code
    final qrData = QrCodeData.fromQrString(qrString);

    if (!mounted) return;

    if (qrData == null) {
      _showError('QR code non reconnu. Assurez-vous de scanner un QR Senticket.');
      return;
    }

    // Déterminer l'opération à effectuer
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      _showError('Vous devez être connecté pour effectuer cette opération.');
      return;
    }

    _handleScannedData(qrData, currentUser);
  }

  /*void _handleScannedData(QrCodeData qrData, User currentUser) {
    final currentRole = currentUser.role.name.toUpperCase();
    final scannedRole = qrData.role.toUpperCase();

    // Déterminer l'opération selon les rôles
    ScanOperationType? operation = widget.operationType;

    if (operation == null) {
      if (currentRole == 'PORTIER' && scannedRole == 'ETUDIANT') {
        operation = ScanOperationType.debit;
      } else if (currentRole == 'ETUDIANT' && scannedRole == 'ETUDIANT') {
        operation = ScanOperationType.transfer;
      } else {
        _showError(
          'Opération non autorisée. '
              'Un $currentRole ne peut pas scanner un $scannedRole.',
        );
        return;
      }
    }

    // Retourner les données scannées et l'opération à l'écran appelant
    Navigator.of(context).pop(ScanResult(
      qrData: qrData,
      operation: operation,
    ));
  }*/

  void _handleScannedData(QrCodeData qrData, User currentUser) {
    final currentRole = currentUser.role.name.toUpperCase();
    final scannedRole = qrData.role.toUpperCase();

    // Déterminer l'opération selon les rôles
    ScanOperationType? operation = widget.operationType;

    if (operation == null) {
      if (currentRole == 'PORTIER' && scannedRole == 'ETUDIANT') {
        operation = ScanOperationType.debit;
      } else if (currentRole == 'ETUDIANT' && scannedRole == 'ETUDIANT') {
        operation = ScanOperationType.transfer;
      } else {
        _showError('Opération non autorisée entre $currentRole et ${qrData.role}.');
        return;
      }
    }

    // Retourner les données scannées et l'opération à l'écran appelant
    Navigator.of(context).pop(ScanResult(qrData: qrData, operation: operation));
  }

  void _showError(String message) {
    setState(() {
      _hasScanned = false;
      _errorMessage = message;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR code'),
        backgroundColor: kPrimaryColor,
        actions: [
          // Bouton torche
          IconButton(
            icon: const Icon(Icons.flash_on, color: kSecondColor),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Vue caméra
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay avec viseur
          _buildScanOverlay(),

          // Message d'erreur
          if (_errorMessage != null)
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: _buildErrorBanner(),
            ),

          // Instructions en bas
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _buildInstructions(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: redErrorColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  // Dans _buildInstructions() de ScanQR

  Widget _buildInstructions() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.currentUser?.role.name.toUpperCase() ?? '';

    // Déterminer le message selon le contexte
    String instruction;

    if (widget.operationType == ScanOperationType.debit) {
      // Distinguer QR étudiant vs QR ticket selon l'appelant
      // On passe un paramètre supplémentaire pour le distinguer
      instruction = widget.expectTicketQr
          ? 'Scannez le QR code du ticket pour le débiter directement'
          : 'Scannez le QR code de l\'étudiant pour débiter son compte';
    } else if (widget.operationType == ScanOperationType.transfer) {
      instruction = 'Scannez le QR code pour transférer les tickets';
    } else {
      instruction = 'Pointez la caméra vers un QR code Senticket';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        instruction,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),
    );
  }

/*  Widget _buildInstructions() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.currentUser?.role.name.toUpperCase() ?? '';

    String instruction = 'Pointez la caméra vers un QR code Senticket';
    if (role == 'PORTIER') {
      instruction = 'Scannez le QR code de l\'étudiant pour débiter ses tickets';
    } else if (role == 'ETUDIANT') {
      instruction = 'Scannez le QR code du destinataire pour lui transférer des tickets';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        instruction,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }*/
}

/// Résultat retourné par ScanQR à l'écran appelant via Navigator.pop()
class ScanResult {
  final QrCodeData qrData;
  final ScanOperationType operation;

  // true si le QR scanné est un QR ticket (débit direct sans sélection)
  bool get isDirectTicket => qrData.isTicketQr;

  const ScanResult({required this.qrData, required this.operation});
}

/// Peintre personnalisé pour l'overlay de scan (viseur centré)
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.65;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Fond semi-transparent en dehors du viseur
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12))),
      ),
      backgroundPaint,
    );

    // Bordure du viseur
    final borderPaint = Paint()
      ..color = kPrimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
      borderPaint,
    );

    // Coins accentués
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    final corners = [
      [Offset(left, top + cornerLength), Offset(left, top), Offset(left + cornerLength, top)],
      [Offset(left + scanAreaSize - cornerLength, top), Offset(left + scanAreaSize, top), Offset(left + scanAreaSize, top + cornerLength)],
      [Offset(left + scanAreaSize, top + scanAreaSize - cornerLength), Offset(left + scanAreaSize, top + scanAreaSize), Offset(left + scanAreaSize - cornerLength, top + scanAreaSize)],
      [Offset(left + cornerLength, top + scanAreaSize), Offset(left, top + scanAreaSize), Offset(left, top + scanAreaSize - cornerLength)],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/*import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class ScanQR extends StatefulWidget {
  final Function(String)? onScanned;

  const ScanQR({super.key, this.onScanned});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width / 1.15,
      height: 95,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ElevatedButton(
        onPressed: () {
          // Simulation du scan QR - vous pouvez intégrer un scanner QR réel ici
          // Pour l'instant, nous allons simuler avec une boîte de dialogue
          _showQRInputDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text(
          'Scanner code QR',
          style: TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showQRInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrer le nom d\'utilisateur'),
        content: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Nom d\'utilisateur',
            hintText: 'Entrez le nom d\'utilisateur de l\'étudiant',
          ),
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onScanned?.call(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final username = 'etudiant123'; // Exemple
              widget.onScanned?.call(username);
              Navigator.pop(context);
            },
            child: const Text('Simuler'),
          ),
        ],
      ),
    );
  }
}*/
