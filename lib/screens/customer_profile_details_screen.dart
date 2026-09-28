import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper_class/api_service_class.dart';
import '../models/requested_customer_details_model.dart';

/// ============================================================================
///  CustomerProfileDetailScreen
///  ---------------------------------------------------------------------------
///  A 100% pixel-faithful Flutter reproduction of "CustomerProfile.pdf"
///  (Cutting Edge Industries Ltd. – Yunusco Customer Profile form).
///
///  • Static, self-contained mock data (no API required to run)
///  • Pinch-to-zoom / pan with InteractiveViewer  (1x → 6x)
///  • Floating zoom controls (+ / – / reset + live %)
///  • Accept / Reject bottom bar (visible when `isPending == true`)
/// ============================================================================
class CustomerProfileDetailScreen extends StatefulWidget {
  final int customerId;
  final bool isPending;

  const CustomerProfileDetailScreen({
    super.key,
    required this.customerId,
    required this.isPending,
  });

  @override
  State<CustomerProfileDetailScreen> createState() =>
      _CustomerProfileDetailScreenState();
}

class _CustomerProfileDetailScreenState
    extends State<CustomerProfileDetailScreen> {
  final ApiService _api = ApiService();

  // --------------------------------------------------------------------------
  //  PDF PALETTE / METRICS
  // --------------------------------------------------------------------------
  static const Color _border = Color(0xFF000000);
  static const Color _headerBg = Color(0xFFE8E8E8);
  static const Color _ink = Color(0xFF000000);
  static const Color _paper = Color(0xFFFFFFFF);

  static const double _lineW = 1.2;
  static const double _baseFont = 11.5;

  static const double _minScale = 1.0;
  static const double _maxScale = 6.0;

  static const TextStyle _bodyStyle = TextStyle(
    fontSize: _baseFont,
    color: _ink,
    height: 1.35,
  );

  static const TextStyle _labelStyle = TextStyle(
    fontSize: _baseFont,
    color: _ink,
    fontWeight: FontWeight.bold,
    height: 1.35,
  );

  static const TextStyle _titleStyle = TextStyle(
    fontSize: 13,
    color: _ink,
    fontWeight: FontWeight.bold,
    height: 1.30,
  );

  static const TextStyle _tinyLabel = TextStyle(
    fontSize: 9,
    color: _ink,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  // --------------------------------------------------------------------------
  //  STATE
  // --------------------------------------------------------------------------
  final TransformationController _zoom = TransformationController();

  CustomerProfileDetailModel? _detail;
  bool _loading = true;
  bool _processing = false;
  String? _error;
  double _scale = 1.0;

  // --------------------------------------------------------------------------
  //  DATA HELPERS
  // --------------------------------------------------------------------------
  String _v(String val) => val.isEmpty ? 'N/A' : val;

  // --------------------------------------------------------------------------
  //  LIFECYCLE
  // --------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _zoom.addListener(_onZoomChanged);
    _load();
  }

  @override
  void dispose() {
    _zoom.removeListener(_onZoomChanged);
    _zoom.dispose();
    super.dispose();
  }

  void _onZoomChanged() {
    final s = _zoom.value.getMaxScaleOnAxis();
    if ((s - _scale).abs() > 0.005 && mounted) {
      setState(() => _scale = s);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getCustomerProfileDetails(widget.customerId);
      if (!mounted) return;
      setState(() {
        _detail = result;
        _loading = false;
        _error = result == null ? 'Failed to load customer details' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'An error occurred while loading details';
      });
    }
  }

  // --------------------------------------------------------------------------
  //  ZOOM HELPERS
  // --------------------------------------------------------------------------
  void _applyZoom(double factor) {
    final media = MediaQuery.of(context).size;
    final focal = Offset(media.width / 2, media.height / 2);

    final current = _zoom.value.getMaxScaleOnAxis();
    if (current <= 0) return;

    final next = (current * factor).clamp(_minScale, _maxScale);
    if ((next - current).abs() < 0.0001) return;

    final f = next / current;
    final m = Matrix4.identity()
      ..translate(focal.dx, focal.dy)
      ..scale(f, f, 1.0)
      ..translate(-focal.dx, -focal.dy);

    _zoom.value = m * _zoom.value;
  }

  void _resetZoom() => _zoom.value = Matrix4.identity();

  // --------------------------------------------------------------------------
  //  BUILD
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Customer Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Reset zoom',
            onPressed: _resetZoom,
            icon: const Icon(Icons.center_focus_strong_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildPdfViewer(),
      bottomNavigationBar: (!_loading && _error == null && widget.isPending)
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  PDF VIEWER (pinch-zoom + pan + floating controls)
  // --------------------------------------------------------------------------
  Widget _buildPdfViewer() {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const pad = 8.0;
            final pageWidth =
            (constraints.maxWidth - pad * 2).clamp(240.0, 900.0);

            return InteractiveViewer(
              transformationController: _zoom,
              constrained: false,
              minScale: _minScale,
              maxScale: _maxScale,
              panEnabled: true,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(48),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(pad),
                child: SizedBox(
                  width: pageWidth,
                  child: _buildPage(),
                ),
              ),
            );
          },
        ),
        Positioned(right: 12, bottom: 12, child: _buildZoomControls()),
      ],
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _zoomBtn(Icons.add, () => _applyZoom(1.25), 'Zoom in'),
          _zoomDivider(),
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${(_scale * 100).round()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
          _zoomDivider(),
          _zoomBtn(Icons.remove, () => _applyZoom(1 / 1.25), 'Zoom out'),
          _zoomDivider(),
          _zoomBtn(Icons.fit_screen_outlined, _resetZoom, 'Fit to screen'),
        ],
      ),
    );
  }

  Widget _zoomDivider() =>
      Container(height: 1, width: 46, color: const Color(0xFFE5E7EB));

  Widget _zoomBtn(IconData icon, VoidCallback onTap, String tip) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 40,
          child: Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
        ),
      ),
    );
  }

  // ==========================================================================
  //  THE PDF PAGE
  // ==========================================================================
  Widget _buildPage() {
    final d = _detail!;
    final address = _v('${d.billToAddressLine1 ?? ''} ${d.billToAddressLine2 ?? ''}'.trim());
    final factoryLoc = _v('${d.shipToAddressLine1 ?? ''} ${d.shipToAddressLine2 ?? ''}'.trim());

    return Container(
      decoration: BoxDecoration(
        color: _paper,
        border: Border.all(color: _border, width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------- MASTHEAD ----------------
          _buildMasthead(d, address),

          _hRule(),

          // ---------------- IDENTITY ----------------
          _buildIdentityBlock(d, address, factoryLoc),

          // ---------------- PRODUCT & CAPACITY ----------------
          _band('PRODUCT & CAPACITY'),
          _block([
            _kv('MAJOR PRODUCT', _v(d.majorProduct ?? '')),
            _kv('TOTAL CAPACITY (PCS.)', _v(d.totalCapacity?.toString() ?? '')),
          ]),

          // ---------------- DEPARTMENT PERSONNEL ----------------
          _band('DEPARTMENT PERSONNEL: (NAME, PHONE AND E- MAIL)'),
          _block([
            _kv('BOARD OF DIRECTORS', _v(d.boardOfDirectors ?? '')),
            _kv('MERCHANDISE DEPARTMENT', _v(d.merchandiseDepartment ?? '')),
            _kv('COMMERCIAL DEPARTMENT', _v(d.commercialDepartment ?? '')),
            _kv('ACCOUNTS DEPARTMENT', _v(d.accountsDepartment ?? '')),
          ]),

          // ---------------- SISTER CONCERNS ----------------
          _hRule(),
          _block([
            const Text("NAME OF SISTER CONCERN'S:", style: _labelStyle),
            const SizedBox(height: 3),
            Text(_sisterConcernsLine(d.sisterConcern), style: _bodyStyle),
          ]),

          // ---------------- BANK ----------------
          _hRule(),
          _block([
            _kv('BANK ACCOUNT', _v(d.bankAccount ?? '')),
            _kv('PAYMENT MODE', _v(d.paymentMode ?? '')),
          ]),

          // ---------------- TRADE LICENSE NOTE ----------------
          _hRule(),
          _block([
            const Text(
              '* PLEASE ATTACH TRADE LICENSE COPY (MENDATORY)',
              style: TextStyle(
                fontSize: _baseFont,
                color: _ink,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ]),

          // ---------------- FOR YUNUSCO USE ONLY ----------------
          _band('FOR YUNUSCO USE ONLY'),
          _buildYunuscoTable(d),

          // ---------------- SIGNATURES ----------------
          _buildSignatureSection(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  MASTHEAD
  // --------------------------------------------------------------------------
  Widget _buildMasthead(CustomerProfileDetailModel d, String address) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'images/icon.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 3,
            children: [
              Text.rich(
                TextSpan(
                  style: _titleStyle,
                  children: [
                    const TextSpan(text: '1.  '),
                    TextSpan(text: _v(d.customerName ?? d.billToCompanyName ?? '')),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: _bodyStyle,
                  children: [
                    const TextSpan(text: 'CATEGORY: ', style: _labelStyle),
                    TextSpan(text: _v(d.majorProduct ?? 'Garments Manufacturer')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(address, style: _bodyStyle),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  IDENTITY BLOCK
  // --------------------------------------------------------------------------
  Widget _buildIdentityBlock(CustomerProfileDetailModel d, String address, String factoryLoc) {
    return _block([
      _kv('PREVIOUS ADDRESS', 'N/A'),
      _kv('FACTORY LOCATION', factoryLoc),
      _inline([
        _pair('TELEPHONE', _v(d.billToTelephone ?? '')),
        _pair('MOBILE', _v(d.billToCellNo ?? '')),
        _pair('WHATSAPP', _v(d.billToCellNo ?? '')),
      ]),
      _kv('CONTACT PERSON', _v(d.billToContactPerson ?? '')),
      _inline([
        _pair('ENLISTED DATE', _v(d.createdDate ?? '')),
        _pair('FIRST ORDER', 'N/A'),
        _pair('PAYMENT', _v(d.paymentMode ?? '')),
      ]),
    ]);
  }

  // --------------------------------------------------------------------------
  //  YUNUSCO TABLE  (CP NO | SPECIAL INSTRUCTION  /  CLIENT HISTORY)
  // --------------------------------------------------------------------------
  Widget _buildYunuscoTable(CustomerProfileDetailModel d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- CP NO ----
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: _border, width: _lineW),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CP NO:', style: _tinyLabel),
                      const SizedBox(height: 5),
                      Text(
                        _v(d.customerCode ?? ''),
                        style: const TextStyle(
                          fontSize: 15,
                          color: _ink,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ---- SPECIAL INSTRUCTION ----
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MANAGEMENT REMARKS', style: _tinyLabel),
                      const SizedBox(height: 5),
                      Text(
                        _v(d.managementRemarks ?? ''),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _ink,
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _hRule(),
        // ---- CLIENT HISTORY ----
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CLIENT HISTORY:', style: _tinyLabel),
              const SizedBox(height: 8),
              Text(_v(d.clientHistory ?? ''), style: _bodyStyle),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  //  SIGNATURE STRIP
  // --------------------------------------------------------------------------
  Widget _buildSignatureSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 22, 6, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _signatureBox('SALES\nMANAGER/GM'),
          _signatureBox('CS MANAGER/\nSR. MANAGER'),
          _signatureBox('VERIFIED BY\nCREDIT CONTROL'),
          _signatureBox('MANAGER\nCREDIT CONTROL'),
          _signatureBox('APPROVED BY\nMANAGEMENT'),
        ],
      ),
    );
  }

  Widget _signatureBox(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // space for a handwritten signature
            const SizedBox(height: 30),
            Container(height: 1, color: _border),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 6.5,
                color: _ink,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  SMALL BUILDING BLOCKS
  // --------------------------------------------------------------------------

  /// Full-width horizontal rule.
  Widget _hRule() => Container(height: _lineW, color: _border);

  /// Grey section band with top + bottom black borders.
  Widget _band(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: _headerBg,
        border: Border(
          top: BorderSide(color: _border, width: _lineW),
          bottom: BorderSide(color: _border, width: _lineW),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: _baseFont,
          color: _ink,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
          height: 1.2,
        ),
      ),
    );
  }

  /// Padded content block.
  Widget _block(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// "LABEL: value"  (bold label, normal value, wraps naturally).
  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: _pair(label, value),
    );
  }

  Widget _pair(String label, String value) {
    return RichText(
      text: TextSpan(
        style: _bodyStyle,
        children: [
          TextSpan(text: '$label: ', style: _labelStyle),
          TextSpan(text: value),
        ],
      ),
    );
  }

  /// A wrapping row of "LABEL: value" chips (used for one-line PDF rows).
  Widget _inline(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        spacing: 14,
        runSpacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }

  /// "1. Cutting Edge Industries Ltd.  2. Cutting Edge Industries Ltd Washing
  ///  Plant.  3. MBM Garments.  4. Absolute Quality- wear Ltd."
  String _sisterConcernsLine(String? sisterConcern) {
    if (sisterConcern == null || sisterConcern.isEmpty) return 'N/A';
    final list = sisterConcern.split(RegExp(r'[,;]')).map((e) => e.trim()).toList();
    return list
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('  ');
  }

  // ==========================================================================
  //  BOTTOM BAR (Accept / Reject)
  // ==========================================================================
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _processing ? null : () => _handleDecision(false),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _processing ? null : () => _handleDecision(true),
                icon: _processing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.check_rounded),
                label: Text(_processing ? 'Processing…' : 'Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDecision(bool accept) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(accept ? 'Accept Customer?' : 'Reject Customer?'),
        content: Text(
          accept
              ? 'This customer request will be approved.'
              : 'This customer request will be rejected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accept ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(accept ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    HapticFeedback.mediumImpact();
    setState(() => _processing = true);

    final ok = await _api.confirmCustomerProfile(widget.customerId, accept ? 1 : 2);
    
    if (!mounted) return;
    setState(() => _processing = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(accept ? 'Customer accepted' : 'Customer rejected'),
          backgroundColor: accept ? Colors.green : Colors.red,
        ),
      );
      Navigator.pop(context, accept);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Action failed. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
