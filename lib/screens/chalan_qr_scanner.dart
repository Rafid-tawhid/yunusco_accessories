import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'chalan_preview.dart';

enum ScanState { scanning, scanned, processing, takingPhoto, photoTaken }

class ChalanScanScreen extends StatefulWidget {
  const ChalanScanScreen({super.key});

  @override
  State<ChalanScanScreen> createState() => _ChalanScanScreenState();
}

class _ChalanScanScreenState extends State<ChalanScanScreen> {
  // States
  final MobileScannerController _cameraController = MobileScannerController();
  ScanState _scanState = ScanState.scanning;
  File? _capturedImage;
  String? _scannedData;
  Map<String, dynamic>? _parsedData;

  @override
  void initState() {
    super.initState();
    _cameraController.start();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // Parse QR data
  Map<String, dynamic> _parseQRData(String rawData) {
    try {
      if (rawData.startsWith('{') && rawData.endsWith('}')) {
        return jsonDecode(rawData);
      }

      // Try pipe-separated format
      final result = <String, dynamic>{};
      final cleanData = rawData.replaceAll('[', '').replaceAll(']', '');
      final parts = cleanData.split('|');

      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length >= 2) {
          final key = keyValue[0].trim().toLowerCase();
          final value = keyValue.sublist(1).join(':').trim();
          result[key] = value;
        }
      }

      if (result.isNotEmpty) {
        result['scan_time'] = DateTime.now().toIso8601String();
        return result;
      }
    } catch (_) {}

    return {'raw': rawData, 'scan_time': DateTime.now().toIso8601String()};
  }

  // Handle QR detection
  Future<void> _onQRDetect(BarcodeCapture barcode) async {
    if (_scanState != ScanState.scanning || barcode.barcodes.isEmpty) return;

    final rawData = barcode.barcodes.first.rawValue;
    if (rawData == null || rawData == _scannedData) return;

    setState(() {
      _scannedData = rawData;
      _parsedData = _parseQRData(rawData);
      _scanState = ScanState.scanned;
    });

    // Auto-open camera after 1 second
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await _openCamera();
  }

  // Open camera to take photo
  Future<void> _openCamera() async {
    if (_scanState == ScanState.processing) return;

    setState(() => _scanState = ScanState.processing);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null && mounted) {
        setState(() {
          _capturedImage = File(image.path);
          _scanState = ScanState.photoTaken;
        });

        // Navigate to preview after short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _navigateToPreview();
      } else if (mounted) {
        // User cancelled, reset
        _resetScan();
      }
    } catch (_) {
      if (mounted) _resetScan();
    }
  }

  // Navigate to preview screen
  void _navigateToPreview() {
    if (_scannedData == null || _capturedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChalanPreviewScreen(
          qrData: _scannedData!,
          parsedData: _parsedData!,
          imageFile: _capturedImage!,
        ),
      ),
    ).then((_) {
      if (mounted) _resetScan();
    });
  }

  // Reset scanner
  void _resetScan() {
    if (!mounted) return;

    setState(() {
      _scanState = ScanState.scanning;
      _scannedData = null;
      _capturedImage = null;
      _parsedData = null;
    });
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chalan QR Scanner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Scanner Section
        Expanded(flex: 3, child: _buildScannerSection()),

        // Info Section
        Expanded(flex: 1, child: _buildInfoSection()),
      ],
    );
  }

  Widget _buildScannerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          MobileScanner(
            controller: _cameraController,
            onDetect: _onQRDetect,
            fit: BoxFit.cover,
          ),

          // Scanner Overlay
          if (_scanState == ScanState.scanning) _buildScannerOverlay(),

          // Status Overlay
          if (_scanState != ScanState.scanning) _buildStatusOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 60, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              'Align QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scanning...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverlay() {
    final statusConfig = _getStatusConfig();

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Icon(statusConfig.icon, size: 80, color: statusConfig.color),

            const SizedBox(height: 16),

            // Status Text
            Text(
              statusConfig.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              statusConfig.subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            // Progress Indicator (for processing states)
            if (statusConfig.showProgress)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(color: statusConfig.color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status Header
          _buildStatusHeader(),

          const SizedBox(height: 12),

          // Status Details
          _buildStatusDetails(),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final statusConfig = _getStatusConfig();

    return Row(
      children: [
        Icon(statusConfig.icon, color: statusConfig.color, size: 24),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            statusConfig.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: statusConfig.color,
            ),
          ),
        ),

        if (_scanState != ScanState.scanning)
          IconButton(
            onPressed: _resetScan,
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Scan Again',
            color: Colors.grey[600],
          ),
      ],
    );
  }

  Widget _buildStatusDetails() {
    switch (_scanState) {
      case ScanState.scanning:
        return Column(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[400], size: 36),
            const SizedBox(height: 8),
            const Text(
              'Scan Chalan QR Code',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Position the QR code within the frame',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case ScanState.scanned:
        return _buildStatusCard(
          'QR Code Scanned Successfully',
          'Preparing camera...',
          Colors.green[50]!,
          Colors.green[800]!,
        );

      case ScanState.processing:
        return _buildStatusCard(
          'Opening Camera',
          'Please wait...',
          Colors.orange[50]!,
          Colors.orange[800]!,
        );

      case ScanState.takingPhoto:
        return _buildStatusCard(
          'Camera Ready',
          'Take photo of the chalan',
          Colors.blue[50]!,
          Colors.blue[800]!,
        );

      case ScanState.photoTaken:
        return _buildStatusCard(
          'Photo Captured',
          'Navigating to preview...',
          Colors.green[50]!,
          Colors.green[800]!,
        );
    }
  }

  Widget _buildStatusCard(
    String title,
    String subtitle,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
          ),

          // QR Data Preview
          if (_scannedData != null && _scannedData!.length < 50)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Data: ${_scannedData!.substring(0, min(_scannedData!.length, 40))}...',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // Status configuration helper
  ({
    IconData icon,
    Color color,
    String title,
    String subtitle,
    bool showProgress,
  })
  _getStatusConfig() {
    switch (_scanState) {
      case ScanState.scanning:
        return (
          icon: Icons.qr_code_scanner,
          color: Colors.green,
          title: 'Scanning',
          subtitle: 'Point camera at QR code',
          showProgress: false,
        );

      case ScanState.scanned:
        return (
          icon: Icons.check_circle,
          color: Colors.green,
          title: 'Scanned!',
          subtitle: 'QR code detected successfully',
          showProgress: false,
        );

      case ScanState.processing:
        return (
          icon: Icons.camera_alt,
          color: Colors.orange,
          title: 'Processing',
          subtitle: 'Opening camera...',
          showProgress: true,
        );

      case ScanState.takingPhoto:
        return (
          icon: Icons.photo_camera,
          color: Colors.blue,
          title: 'Take Photo',
          subtitle: 'Capture chalan image',
          showProgress: false,
        );

      case ScanState.photoTaken:
        return (
          icon: Icons.check_circle,
          color: Colors.green,
          title: 'Success!',
          subtitle: 'Photo captured',
          showProgress: false,
        );
    }
  }
}
