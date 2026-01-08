import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:yunusco_accessories/helper_class/api_service_class.dart';
import 'package:yunusco_accessories/helper_class/helper_class.dart';
import 'package:yunusco_accessories/widgets/custom_alerts.dart';
import 'package:image/image.dart' as img;

class ChalanPreviewScreen extends StatefulWidget {
  final String qrData;
  final Map<String, dynamic> parsedData;
  final File? imageFile;

  const ChalanPreviewScreen({
    super.key,
    required this.qrData,
    required this.parsedData,
    required this.imageFile,
  });

  @override
  State<ChalanPreviewScreen> createState() => _ChalanPreviewScreenState();
}

class _ChalanPreviewScreenState extends State<ChalanPreviewScreen> {
  bool _isSubmitting = false;
  bool _isProcessingImage = true;
  String? _dcFromImage;
  double _matchingPercentage = 0.0;
  String _matchingStatus = 'Processing...';
  Color _matchingColor = Colors.grey;
  List<String> _extractedTextLines = [];
  String _fullExtractedText = '';
  Map<String, String> _extractedPatterns = {};
  bool _isSignAttached=false;

  // Normalized parsed data for easy access
  late final Map<String, dynamic> _normalizedData = Map.fromEntries(
    widget.parsedData.entries.map(
      (entry) => MapEntry(entry.key.toLowerCase(), entry.value),
    ),
  );

  @override
  void initState() {
    super.initState();
    _processImageAndCalculateMatch();
  }

  Future<void> _processImageAndCalculateMatch() async {
    setState(() => _isProcessingImage = true);
    _extractedTextLines.clear();
    _extractedPatterns.clear();

    try {
      // Extract text from image
      if (widget.imageFile != null) {
        final extractionResult = await _extractTextFromCroppedImage();
        _fullExtractedText = extractionResult['fullText'] ?? '';
        _extractedTextLines = extractionResult['lines'] ?? [];
        _extractedPatterns = extractionResult['patterns'] ?? {};

        // Extract DC specifically
        _dcFromImage = await _detectDCFromImage();
        final challanNo = _getChallanNo();

        if (challanNo != null &&
            _dcFromImage != null &&
            _dcFromImage != 'None') {
          _matchingPercentage = _calculateMatching(challanNo, _dcFromImage!);
          _updateMatchingStatus();
        } else {
          _matchingPercentage = 0.0;
          _matchingStatus = _extractedTextLines.isNotEmpty
              ? 'No DC detected'
              : 'No text found';
          _matchingColor = Colors.grey;
        }
      }
    } catch (e) {
      _matchingPercentage = 0.0;
      _matchingStatus = 'Processing error';
      _matchingColor = Colors.grey;
      debugPrint('Image processing error: $e');
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  Future<Map<String, dynamic>> _extractTextFromCroppedImage() async {
    try {
      // First, crop the image to focus on DC area
      final croppedImage = await _cropTopRight(widget.imageFile!);

      // Extract text from cropped image
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(croppedImage);
      final result = await recognizer.processImage(inputImage);
      recognizer.close();

      final fullText = result.text;
      final lines = result.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      // Clean up cropped file
      try {
        await croppedImage.delete();
      } catch (_) {}

      // Extract common patterns
      final patterns = <String, String>{};

      // Look for DC patterns
      final dcRegex = RegExp(r'DC[A-Z0-9]*\/[0-9]+', caseSensitive: false);
      final dcMatch = dcRegex.firstMatch(fullText);
      if (dcMatch != null) {
        patterns['DC Number'] = dcMatch.group(0)!;
      }

      // Look for numbers (potential challan numbers)
      final numberRegex = RegExp(r'\b\d{4,}\b');
      final numbers = numberRegex.allMatches(fullText);
      if (numbers.isNotEmpty) {
        patterns['Numbers'] = numbers.map((m) => m.group(0)).join(', ');
      }

      return {'fullText': fullText, 'lines': lines, 'patterns': patterns};
    } catch (e) {
      debugPrint('Text extraction error: $e');
      return {
        'fullText': '',
        'lines': [],
        'patterns': {},
        'error': e.toString(),
      };
    }
  }

  void _updateMatchingStatus() {
    if (_matchingPercentage == 100) {
      _matchingStatus = 'Perfect Match ✓';
      _matchingColor = Colors.green;
    } else if (_matchingPercentage >= 95) {
      _matchingStatus = 'Good Match ✓';
      _matchingColor = Colors.green;
    } else if (_matchingPercentage >= 85) {
      _matchingStatus = 'Acceptable Match';
      _matchingColor = Colors.orange;
    } else {
      _matchingStatus = 'Poor Match ✗';
      _matchingColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Preview & Submit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isProcessingImage && _matchingPercentage > 0)
            IconButton(
              onPressed: _showMatchingInfo,
              icon: Icon(
                _matchingPercentage >= 95 ? Icons.verified : Icons.warning,
                color: Colors.white,
              ),
              tooltip: 'Matching Details',
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matching Status Card - SHOWS IMMEDIATELY
                _buildMatchingCard(),
                const SizedBox(height: 20),

                // Photo Preview Card
                _buildPhotoCard(),
                const SizedBox(height: 20),

                // QR Details Card
                //_buildDetailsCard(),
                const SizedBox(height: 30),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading Overlay
          if (_isSubmitting) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMatchingCard() {
    final challanNo = _getChallanNo();

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _matchingColor.withOpacity(0.1),
              _matchingColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _matchingColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: _isProcessingImage
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : Icon(
                            _matchingPercentage >= 95
                                ? Icons.verified
                                : Icons.warning,
                            color: _matchingColor,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isProcessingImage
                              ? 'Analyzing Image...'
                              : 'DC Number Match',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _matchingColor,
                            fontSize: 16,
                          ),
                        ),
                        if (!_isProcessingImage)
                          Text(
                            _matchingStatus,
                            style: TextStyle(
                              color: _matchingColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              LinearProgressIndicator(
                value: _matchingPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_matchingColor),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // QR Data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR Chalan No',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challanNo ?? 'Not found',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Percentage
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _matchingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _matchingColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _isProcessingImage
                          ? '...'
                          : '${_matchingPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _matchingColor,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Image Data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Image DC No',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_extractDCNo()),
                      ],
                    ),
                  ),
                ],
              ),

              // Warning Message for low match
              if (!_isProcessingImage && _matchingPercentage < 95)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Match below 95%. Submission not recommended.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractDCNo() {
    // Clean extraction - try to get just DC/1234 pattern
    final dcRegex = RegExp(r'DC[A-Z0-9]*\/[0-9]+', caseSensitive: false);

    // Check patterns first
    for (final entry in _extractedPatterns.entries) {
      final match = dcRegex.firstMatch(entry.value);
      if (match != null) return match.group(0)!;
    }

    // Check text lines
    for (final line in _extractedTextLines) {
      final match = dcRegex.firstMatch(line);
      if (match != null) return match.group(0)!;
    }

    // If no exact pattern, return first line containing DC
    for (final line in _extractedTextLines) {
      if (line.contains(RegExp(r'DC', caseSensitive: false))) {
        return line;
      }
    }

    return 'No DC found';
  }

  Widget _buildPhotoCard() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with zoom button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_normalizedData['jobbagno']}-${_normalizedData['portal']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                if (widget.imageFile != null)
                  IconButton(
                    onPressed: () => _viewFullScreenImage(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    tooltip: 'View Full Screen',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Image Container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.imageFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImageErrorState();
                        },
                      ),
                    )
                  : _buildImageErrorState(),
            ),

            // Image Info
            if (widget.imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to zoom • ${_getFileSize()}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    final details = _buildDetailItems();
    if (details.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'QR Code Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details Grid
            ...details,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailItems() {
    final displayNames = {
      'challanid': 'Chalan ID',
      'challanno': 'Chalan No',
      'challannumber': 'Chalan No',
      'jobbagno': 'Job Bag No',
      'jobbag': 'Job Bag',
      'portal': 'Portal',
      'buyer': 'Buyer Name',
      'date': 'Date',
      'product': 'Product',
      'quantity': 'Quantity',
      'amount': 'Amount',
    };

    final priorityKeys = ['challanid', 'challanno', 'jobbagno', 'portal'];
    final otherKeys =
        _normalizedData.keys
            .where(
              (key) =>
                  !priorityKeys.contains(key) &&
                  !['scan_time', 'error', 'scanned_at', 'raw'].contains(key),
            )
            .toList()
          ..sort();

    final allKeys = [
      ...priorityKeys.where((k) => _normalizedData.containsKey(k)),
      ...otherKeys,
    ];

    return allKeys.map((key) {
      final displayName =
          displayNames[key] ?? key.replaceAll('_', ' ').toTitleCase();
      final value = _normalizedData[key]?.toString() ?? 'N/A';

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    final isLowMatch = _matchingPercentage < 95;

    return Column(
      children: [
        // Warning for low match
        if (!_isProcessingImage && isLowMatch)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'DC match ${_matchingPercentage.toStringAsFixed(0)}% is below 95%. Submission blocked.',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                  backgroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Scan Again',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting || _isProcessingImage
                    ? null
                    : _submitChalan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Submit',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Help text
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            isLowMatch
                ? 'Minimum 95% DC match required for submission'
                : 'Ready to submit with ${_matchingPercentage.toStringAsFixed(0)}% DC match',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Submitting...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageErrorState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, size: 48, color: Colors.grey),
        SizedBox(height: 12),
        Text('No Image Available', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 4),
        Text(
          'Please scan again',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  // Helper Methods
  String? _getChallanNo() {
    return _normalizedData['challanno']?.toString() ??
        _normalizedData['challannumber']?.toString();
  }

  String _getFileSize() {
    if (widget.imageFile == null) return '0 KB';
    final size = widget.imageFile!.lengthSync();
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDateTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Unknown';
    }
  }

  // Image Viewing
  void _viewFullScreenImage() {
    if (widget.imageFile == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(widget.imageFile!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DC Match: ${_matchingPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMatchingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DC Number Matching Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchingInfoRow(
              'QR Code Chalan No:',
              _getChallanNo() ?? 'Not found',
            ),
            _buildMatchingInfoRow(
              'Image DC No:',
              _dcFromImage ?? 'Not detected',
            ),
            _buildMatchingInfoRow(
              'Match Percentage:',
              '${_matchingPercentage.toStringAsFixed(1)}%',
            ),
            _buildMatchingInfoRow('Match Status:', _matchingStatus),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'System compares Chalan No from QR code with DC number detected in image.\n\nMinimum 95% match required for submission.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullExtractedText() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Extracted Text'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_fullExtractedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SelectableText(
                      _fullExtractedText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )
                else
                  const Text('No text extracted'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Submission Logic
  Future<void> _submitChalan() async {
    // Check if match is below 95%
    // if (_matchingPercentage < 95) {
    //   await _showLowMatchAlert();
    //   return;
    // }
    File file=await _cropReceivedByArea(widget.imageFile!);
    _isSignAttached=await DashboardHelper.hasAnyColorInFile(file);

    await _performSubmission();
  }

  Future<File> _cropReceivedByArea(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    // Bottom-right area (adjust after testing)
    final cropWidth = (image.width * 0.35).toInt();
    final cropHeight = (image.height * 0.25).toInt();

    final cropped = img.copyCrop(
      image,
      x: image.width - cropWidth,
      y: image.height - cropHeight,
      width: cropWidth,
      height: cropHeight,
    );

    final croppedFile = File('${file.path}_received.jpg');
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    return croppedFile;
  }


  Future<void> _showLowMatchAlert() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Low Match Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DC match is only ${_matchingPercentage.toStringAsFixed(0)}% (minimum 95% required).',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Possible issues:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Wrong chalan photo'),
            _buildBulletPoint('Poor image quality'),
            _buildBulletPoint('QR code mismatch'),
            const SizedBox(height: 16),
            const Text(
              'Please scan again with correct chalan.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _performSubmission() async {
    setState(() => _isSubmitting = true);

    try {
      final apiData = await _prepareApiData();

      debugPrint(
        '🚀 Submitting challan with ${_matchingPercentage.toStringAsFixed(0)}% DC match',
      );

      // Compress image before upload
      File? compressedImage;
      try {
        compressedImage = await DashboardHelper.compressImage(
          widget.imageFile!,
          quality: 50, // Adjust quality (1-100), 85 is good balance
        );
        if (compressedImage != null) {
          final originalSize = await widget.imageFile!.length();
          final compressedSize = await compressedImage.length();
          final reduction = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(0);
          debugPrint('📊 Image compressed: ${originalSize ~/ 1024}KB → ${compressedSize ~/ 1024}KB (${reduction}% reduction)');
        }
      } catch (e) {
        debugPrint('⚠️ Compression failed, using original: $e');
        compressedImage = widget.imageFile;
      }

      final response = await ApiService.uploadChallanWithQR(
        userId: apiData['userId'] as int,
        portal: apiData['portal'] as String,
        challanId: apiData['chalanId'] as String,
        imageFile: compressedImage ?? widget.imageFile!, // Use compressed if available
        isIdentified: _isSignAttached,
        qRMatchingPercentage: _matchingPercentage,

      );

      debugPrint('📥 API Response: ${response.toString()}');

      // Handle API response
      if (response['output'] == "true") {
        debugPrint('CURRENT $response');
        await CustomAlerts.showSuccessDialog(response, context, _isSignAttached);
      } else {
        await CustomAlerts.showApiErrorDialog(response, context, _isSignAttached);
      }
    } catch (error) {
      debugPrint('❌ Unexpected error: $error');
      await _showErrorDialog('Upload Failed', 'Unexpected error: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  // Prepare API Data
  Future<Map<String, dynamic>> _prepareApiData() async {
    return {
      'userId': 443,
      'portal': _normalizedData['portal']?.toString() ?? 'Unknown',
      'chalanId': _normalizedData['challanid']?.toString() ?? 'Unknown',
    };
  }

  Future<void> _showErrorDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Text Recognition
  Future<String?> _detectDCFromImage() async {
    try {
      final croppedImage = await _cropTopRight(widget.imageFile!);
      final dcNumber = await _extractDCNumber(croppedImage);

      // Clean up cropped file
      try {
        await croppedImage.delete();
      } catch (_) {}

      return dcNumber;
    } catch (e) {
      debugPrint('DC Detection Error: $e');
      return 'Detection Failed';
    }
  }

  Future<File> _cropTopRight(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final cropWidth = (image.width * 0.4).toInt();
    final cropHeight = (image.height * 0.3).toInt();

    final cropped = img.copyCrop(
      image,
      x: image.width - cropWidth,
      y: 0,
      width: cropWidth,
      height: cropHeight,
    );

    final croppedFile = File(
      '${file.path}_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    return croppedFile;
  }

  Future<String?> _extractDCNumber(File imageFile) async {
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(imageFile);

      final result = await recognizer.processImage(inputImage);
      recognizer.close();

      final text = result.text.replaceAll('\n', ' ');
      debugPrint('Extracted text from cropped image: $text');

      /// Matches: DC/1234, DC/AB-234, DC/2023/56
      final regex = RegExp(r'DC[A-Z0-9]*\/[0-9]+', caseSensitive: false);
      final match = regex.firstMatch(text);

      return match?.group(0) ?? (text.isNotEmpty ? text : 'No text detected');
    } catch (e) {
      return 'Error: $e';
    }
  }

  double _calculateMatching(String qrText, String imageText) {
    if (qrText.isEmpty || imageText.isEmpty) return 0.0;

    // Clean strings - remove spaces and convert to lowercase
    final cleanQr = qrText.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final cleanImage = imageText.toLowerCase().replaceAll(RegExp(r'\s+'), '');

    // Direct match
    if (cleanImage == cleanQr) return 100.0;

    // Check if image contains QR text
    if (cleanImage.contains(cleanQr)) return 100.0;

    // Check if QR text contains image text
    if (cleanQr.contains(cleanImage)) {
      return (cleanImage.length / cleanQr.length) * 100;
    }

    // Use Levenshtein distance for fuzzy matching
    final distance = _levenshteinDistance(cleanQr, cleanImage);
    final maxLength = cleanQr.length > cleanImage.length
        ? cleanQr.length
        : cleanImage.length;

    if (maxLength == 0) return 0.0;

    final similarity = (1 - distance / maxLength) * 100;
    return similarity > 0 ? similarity : 0.0;
  }

  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((value, element) => value < element ? value : element);
      }
    }

    return matrix[a.length][b.length];
  }







}

// Extension for string formatting
extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
