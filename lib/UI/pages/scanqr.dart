// UI/widgets/debitAccount/scan_qr.dart
import 'package:flutter/material.dart';
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
}

/* import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

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
        onPressed: () => print('scan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          textStyle: const TextStyle(
            color: kThirdColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Scanner code QR'),
      ),
    );
  }
} */

/* old
// UI/widgets/debitAccount/scan_qr.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  final Function(String)? onScanComplete;
  
  const ScanQR({super.key, this.onScanComplete});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (_isScanning || widget.onScanComplete == null) return;
    
    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null) {
      setState(() => _isScanning = true);
      
      // Extract username from QR code
      final username = _extractUsername(barcode.rawValue!);
      
      // Delay to show success
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isScanning = false);
          widget.onScanComplete!(username);
          Navigator.pop(context); // Close scanner
        }
      });
    }
  }

  String _extractUsername(String qrData) {
    // Implement your QR code format parsing here
    // For example, if QR contains JSON: {"username": "student123"}
    try {
      final data = jsonDecode(qrData);
      return data['username'] ?? qrData;
    } catch (e) {
      return qrData; // Assume QR contains username directly
    }
  }

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: const Text('Scan QR Code'),
              actions: [
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.torchState,
                    builder: (context, state, child) {
                      switch (state) {
                        case TorchState.off:
                          return const Icon(Icons.flash_off, color: Colors.grey);
                        case TorchState.on:
                          return const Icon(Icons.flash_on, color: Colors.yellow);
                      }
                    },
                  ),
                  onPressed: () => cameraController.toggleTorch(),
                ),
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.cameraFacingState,
                    builder: (context, state, child) {
                      switch (state) {
                        case CameraFacing.front:
                          return const Icon(Icons.camera_front);
                        case CameraFacing.back:
                          return const Icon(Icons.camera_rear);
                      }
                    },
                  ),
                  onPressed: () => cameraController.switchCamera(),
                ),
              ],
            ),
            Expanded(
              child: MobileScanner(
                controller: cameraController,
                onDetect: _handleBarcode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: _openScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanner code QR'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}*/

/*
dependencies:
  provider: ^6.1.1
  mobile_scanner: ^3.3.0
  http: ^1.1.0
*/
