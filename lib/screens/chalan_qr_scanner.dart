import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'chalan_preview.dart';

class ChalanScanScreen extends StatefulWidget {
  const ChalanScanScreen({super.key});

  @override
  State<ChalanScanScreen> createState() => _ChalanScanScreenState();
}

class _ChalanScanScreenState extends State<ChalanScanScreen> {
  String? qrData;
  List<File> _selectedImages = [];
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  Map<String, dynamic>? _parsedData;

  // Parse QR code data
  Map<String, dynamic> _parseQRData(String rawData) {
    final Map<String, dynamic> data = {};

    try {
      String cleanData = rawData.replaceAll('[', '').replaceAll(']', '');

      final parts = cleanData.split('|');
      for (var part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length >= 2) {
          final key = keyValue[0].trim();
          final value = keyValue.sublist(1).join(':').trim();
          data[key.toLowerCase()] = value;
        }
      }

      if (data.isEmpty) {
        data['chalan'] = cleanData;
      }

      data['scan_time'] = DateTime.now().toIso8601String();
    } catch (e) {
      data['raw'] = rawData;
      data['error'] = 'Failed to parse QR data';
    }

    return data;
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (images != null && images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          _selectedImages.add(File(image.path));
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _viewImageFullScreen(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(
                image,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPreview() {
    if (qrData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChalanPreviewScreen(
            qrData: qrData!,
            parsedData: _parsedData!,
            imageFiles: _selectedImages,
          ),
        ),
      ).then((_) {
        setState(() {
          qrData = null;
          _selectedImages.clear();
          _parsedData = null;
          _isScanning = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chalan QR Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_selectedImages.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () {},
                  tooltip: 'View Images',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _selectedImages.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Scan'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Position the QR code within the frame'),
                      Text('2. Wait for automatic detection'),
                      Text('3. Add photos from camera or gallery'),
                      Text('4. Tap Preview to review'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
            IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => ChalanPreviewScreen(
              //       qrData: 'Hello..',
              //       parsedData: {},
              //       imageFiles: [File('assets/images/doc.jpg')],
              //     ),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected Images Preview Section
          if (_selectedImages.isNotEmpty)
            _buildImagePreviewSection(),

          // QR Scanner Section
          if (_selectedImages.isEmpty) Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (barcode) {
                    if (!_isScanning || barcode.barcodes.isEmpty) return;

                    final rawData = barcode.barcodes.first.rawValue;
                    if (rawData != null && rawData != qrData) {
                      setState(() {
                        qrData = rawData;
                        _parsedData = _parseQRData(rawData);
                        _isScanning = false;
                      });
                    }
                  },
                ),

                if (_isScanning) _buildScannerOverlay(),

                if (!_isScanning && qrData != null)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 80,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'QR Code Scanned!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImages.isEmpty
                                ? 'Add photos (optional)'
                                : 'Ready to preview',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info/Controls Section - MADE SCROLLABLE
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: qrData != null
                  ? _buildScannedInfo()
                  : _buildWaitingForScan(),
            ),
          ),
        ],
      ),
      // Floating Action Button for adding photos
      floatingActionButton: qrData != null
          ? FloatingActionButton.extended(
        onPressed: _showImageSourceDialog,
        icon: const Icon(Icons.add_photo_alternate),
        label: Text(
          'Add Photo (${_selectedImages.length})',
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }

  Widget _buildImagePreviewSection() {
    return Container(
      height: 120,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Chalan Photos (${_selectedImages.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showImageSourceDialog,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add More'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return _buildImageThumbnail(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _viewImageFullScreen(_selectedImages[index]),
            child: Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_selectedImages[index]),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _removeImage(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
          border: Border.all(
            color: Colors.green,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 60,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Align QR code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForScan() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan Chalan QR Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Position the QR code within the frame',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScannedInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'QR Code Scanned!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    qrData = null;
                    _selectedImages.clear();
                    _parsedData = null;
                    _isScanning = true;
                  });
                },
                tooltip: 'Scan Again',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Image Count Indicator
          if (_selectedImages.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedImages.length} photo${_selectedImages.length > 1 ? 's' : ''} added',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Parsed Data Display
          if (_parsedData != null && _parsedData!.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildParsedDataRows(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_photo_alternate, size: 22),
                  label: const Text(
                    'Add Photos',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.visibility, size: 22),
                  label: const Text(
                    'Preview',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Instructions Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedImages.isEmpty
                      ? '1. Add photos of the physical chalan (optional)\n2. Tap Preview to review and submit'
                      : '1. Tap Preview to review all details\n2. Submit the chalan with ${_selectedImages.length} photo${_selectedImages.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildParsedDataRows() {
    List<Widget> rows = [];

    final Map<String, String> displayNames = {
      'chalan': 'Chalan Number',
      'chalan_no': 'Chalan Number',
      'chalan_number': 'Chalan Number',
      'buyer': 'Buyer Name',
      'buyer_name': 'Buyer Name',
      'date': 'Chalan Date',
      'chalan_date': 'Chalan Date',
      'product': 'Product',
      'product_name': 'Product',
      'quantity': 'Quantity',
      'amount': 'Amount',
      'raw': 'QR Code Data',
    };

    _parsedData!.forEach((key, value) {
      if (key == 'scan_time' || key == 'error') return;

      final displayName = displayNames[key] ?? key.toUpperCase();

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '$displayName:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });

    return rows;
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

