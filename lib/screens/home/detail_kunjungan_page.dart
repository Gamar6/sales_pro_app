import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/visit_correction_history_model.dart';
import '../../services/api_config.dart';
import '../../services/visit_service.dart';
import '../../widgets/async_state_widgets.dart';

class DetailKunjunganPage extends StatefulWidget {
  final Map<String, dynamic> visit;

  const DetailKunjunganPage({super.key, required this.visit});

  @override
  State<DetailKunjunganPage> createState() => _DetailKunjunganPageState();
}

class _DetailKunjunganPageState extends State<DetailKunjunganPage> {
  final VisitService _visitService = VisitService();
  late final Map<String, dynamic> _visit;

  VisitCorrectionHistoryModel? _correctionHistory;
  Map<String, dynamic>? _latestCorrection;
  Map<String, dynamic>? _latestEffectiveData;
  String? _correctionHistoryError;
  String? _pendingPayloadFingerprint;
  String? _pendingIdempotencyKey;
  bool _isLoadingCorrectionHistory = true;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _visit = Map<String, dynamic>.from(widget.visit);
    _loadCorrectionHistory();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCorrectionHistory() async {
    final visitId =
        _visit['id'] ?? _visit['visit_id'] ?? _visit['store_visit_id'];
    if (visitId == null || visitId.toString().isEmpty) {
      setState(() {
        _isLoadingCorrectionHistory = false;
        _correctionHistoryError = 'ID kunjungan tidak tersedia.';
      });
      return;
    }

    setState(() {
      _isLoadingCorrectionHistory = true;
      _correctionHistoryError = null;
    });

    try {
      final history = await _visitService.getVisitCorrectionHistory(
        visitId.toString(),
      );
      if (!mounted) return;
      _countdownTimer?.cancel();
      setState(() {
        _correctionHistory = history;
        _latestEffectiveData = history.effectiveData;
      });
      if (history.deadlineAt != null) {
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted ||
              DateTime.now().isAfter(history.deadlineAt!) ||
              DateTime.now().isAtSameMomentAs(history.deadlineAt!)) {
            if (mounted) setState(() {});
            timer.cancel();
          } else {
            setState(() {});
          }
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _correctionHistoryError = _errorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCorrectionHistory = false;
        });
      }
    }
  }

  Future<void> _openCorrectionForm() async {
    final history = _correctionHistory;
    if (history == null || !history.canCorrect) return;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _VisitCorrectionForm(
        initialData: history.effectiveData,
        onSubmit: _submitCorrection,
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koreksi berhasil diproses.')),
      );
    }
  }

  Future<String?> _submitCorrection(
    Map<String, dynamic> changes,
    String reason,
  ) async {
    final history = _correctionHistory;
    if (history == null) return 'Data kunjungan belum tersedia.';

    final fingerprint = jsonEncode({...changes, 'reason': reason});
    if (_pendingPayloadFingerprint != fingerprint ||
        _pendingIdempotencyKey == null) {
      _pendingPayloadFingerprint = fingerprint;
      _pendingIdempotencyKey = _newIdempotencyKey();
    }

    try {
      final result = await _visitService.submitVisitCorrection(
        visitId: history.visitId,
        changes: changes,
        reason: reason,
        idempotencyKey: _pendingIdempotencyKey!,
      );
      if (!mounted) return null;

      final correction = _asMap(result['correction']);
      final effectiveData = _asMap(result['effective_data']);
      setState(() {
        _latestCorrection = correction;
        _latestEffectiveData = effectiveData;
      });
      _pendingPayloadFingerprint = null;
      _pendingIdempotencyKey = null;
      await _loadCorrectionHistory();
      return null;
    } catch (error) {
      return _errorMessage(error);
    }
  }

  String _newIdempotencyKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  String _formatDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return value.toString();
    return '${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year} '
        '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }

  String _formatRemainingTime(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) return '00:00:00';
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _errorMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String? _resolvePhotoUrl(dynamic value) {
    final photoValue = value is Map
        ? value['url'] ?? value['secure_url'] ?? value['path']
        : value;
    final photoPath = photoValue?.toString().trim();
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('//')) return 'https:$photoPath';

    final parsed = Uri.tryParse(photoPath);
    if (parsed != null && parsed.hasScheme) return parsed.toString();

    final apiUri = Uri.parse(ApiConfig.baseUrl);
    final apiRootPath = apiUri.path.replaceFirst(RegExp(r'/api/?$'), '');
    final relativePath = photoPath.startsWith('/') ? photoPath : '/$photoPath';
    return apiUri.replace(path: '$apiRootPath$relativePath').toString();
  }

  String _formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    if (value is List) {
      if (value.isEmpty) return '-';
      return value.map((item) => item.toString()).join(', ');
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final partner = _asMap(_visit['partner']);
    final report = _asMap(_visit['report']);
    final originalReport = _asMap(_visit['report_original']) ?? report;
    final effectiveReport =
        _latestEffectiveData ??
        _correctionHistory?.effectiveData ??
        _asMap(_visit['report_effective']) ??
        originalReport;
    final storeName = partner?['name'] ?? 'Toko Tanpa Nama';
    final address = partner?['street'] ?? 'Alamat tidak tersedia';
    final checkIn = _formatDateTime(_visit['check_in_at']);
    final checkOut = _formatDateTime(_visit['check_out_at']);
    final rawPhotos = report?['photos'] ?? originalReport?['photos'];
    final photos = rawPhotos is List ? rawPhotos : const <dynamic>[];
    final stockPcs = effectiveReport?['stock_pcs'];
    final stockPercentage = effectiveReport?['stock_percentage'];
    final activities = effectiveReport?['activities'] is List
        ? effectiveReport!['activities'] as List<dynamic>
        : const <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF424752)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Kunjungan',
          style: TextStyle(
            color: Color(0xFF003F87),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFC2C6D4)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003F87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF424752),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeInfo('Check-in', checkIn),
                      _buildTimeInfo('Check-out', checkOut),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Laporan Hasil Kunjungan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141D23),
              ),
            ),
            const SizedBox(height: 8),
            if (effectiveReport == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC2C6D4)),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada laporan yang disubmit untuk kunjungan ini.',
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFC2C6D4)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(
                      'Nama PIC',
                      _formatValue(effectiveReport['pic_name']),
                    ),
                    _buildRow(
                      'Stok (Pcs)',
                      stockPcs == null ? '-' : '$stockPcs Pcs',
                    ),
                    _buildRow(
                      'Persentase Stok',
                      stockPercentage == null ? '-' : '$stockPercentage%',
                    ),
                    _buildRow(
                      'Catatan',
                      _formatValue(effectiveReport['notes']),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aktivitas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (activities.isNotEmpty)
                      ...activities.map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                          child: Text(
                            '• $activity',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                    else
                      const Text('-', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 16),
                    const Text(
                      'Foto Kunjungan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (photos.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          final photoUrl = _resolvePhotoUrl(photos[index]);
                          if (photoUrl == null) {
                            return _buildPhotoPlaceholder();
                          }

                          return GestureDetector(
                            onTap: () => _showPhotoViewer(photoUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPhotoPlaceholder(),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      const Text(
                        'Tidak ada foto.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildCorrectionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  void _showPhotoViewer(String photoUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      final expectedBytes = progress.expectedTotalBytes;
                      return Center(
                        child: CircularProgressIndicator(
                          value: expectedBytes == null
                              ? null
                              : progress.cumulativeBytesLoaded / expectedBytes,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  tooltip: 'Tutup foto',
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectionSection() {
    final history = _correctionHistory;
    final canCorrect =
        history != null &&
        history.status.toUpperCase() == 'COMPLETED' &&
        history.canCorrect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koreksi Kunjungan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF141D23),
          ),
        ),
        const SizedBox(height: 8),
        if (_latestCorrection != null) _buildLatestCorrectionCard(),
        if (_isLoadingCorrectionHistory)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_correctionHistoryError != null)
          AppErrorState(
            title: 'Gagal memuat riwayat koreksi',
            message: _correctionHistoryError!,
            onRetry: _loadCorrectionHistory,
          )
        else if (history != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFC2C6D4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (history.deadlineAt != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: Color(0xFF003F87),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sisa waktu (perkiraan): ${_formatRemainingTime(history.deadlineAt!)}',
                          style: const TextStyle(
                            color: Color(0xFF003F87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Batas waktu: ${_formatDateTime(history.deadlineAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF424752),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (canCorrect)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openCorrectionForm,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Ajukan Koreksi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003F87),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else
                  Text(
                    history.status.toUpperCase() != 'COMPLETED'
                        ? 'Koreksi hanya tersedia untuk kunjungan berstatus Completed.'
                        : 'Pengajuan koreksi tidak tersedia menurut status server.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF424752),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Riwayat Koreksi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF141D23),
            ),
          ),
          const SizedBox(height: 8),
          if (history.corrections.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFC2C6D4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Belum ada koreksi untuk kunjungan ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF424752)),
              ),
            )
          else
            ...history.corrections.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCorrectionHistoryCard(entry.key + 1, entry.value),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildLatestCorrectionCard() {
    final correction = _latestCorrection!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        border: Border.all(color: const Color(0xFF71B88B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengajuan koreksi berhasil diproses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF006E25),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status dari server: ${_formatValue(correction['status'])}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildComparison(
            _asMap(correction['previous_data']) ?? const {},
            _asMap(correction['correction_data']) ?? const {},
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionHistoryCard(
    int number,
    Map<String, dynamic> correction,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Koreksi $number',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                _formatValue(correction['status']),
                style: const TextStyle(
                  color: Color(0xFF006E25),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Disetujui: ${_formatDateTime(correction['approved_at'] ?? correction['created_at'])}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF424752)),
          ),
          const SizedBox(height: 8),
          _buildComparison(
            _asMap(correction['previous_data']) ?? const {},
            _asMap(correction['correction_data']) ?? const {},
          ),
          const SizedBox(height: 8),
          _buildRow('Alasan', _formatValue(correction['reason'])),
        ],
      ),
    );
  }

  Widget _buildComparison(
    Map<String, dynamic> previousData,
    Map<String, dynamic> correctedData,
  ) {
    const fields = <(String, String)>[
      ('Nama PIC', 'pic_name'),
      ('Aktivitas', 'activities'),
      ('Persentase stok', 'stock_percentage'),
      ('Stok (Pcs)', 'stock_pcs'),
      ('Catatan', 'notes'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(child: Text('Sebelum', style: TextStyle(fontSize: 11))),
            SizedBox(width: 20),
            Expanded(child: Text('Sesudah', style: TextStyle(fontSize: 11))),
          ],
        ),
        const SizedBox(height: 4),
        ...fields.map((field) {
          final label = field.$1;
          final key = field.$2;
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '$label\n${_formatValue(previousData[key])}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF424752),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$label\n${_formatValue(correctedData[key])}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF424752)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF424752), fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF141D23),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitCorrectionForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Future<String?> Function(Map<String, dynamic> changes, String reason)
  onSubmit;

  const _VisitCorrectionForm({
    required this.initialData,
    required this.onSubmit,
  });

  @override
  State<_VisitCorrectionForm> createState() => _VisitCorrectionFormState();
}

class _VisitCorrectionFormState extends State<_VisitCorrectionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _picNameController = TextEditingController();
  final TextEditingController _activitiesController = TextEditingController();
  final TextEditingController _stockPercentageController =
      TextEditingController();
  final TextEditingController _stockPcsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isSubmitting = false;
  String? _submitError;
  String? _changesError;

  @override
  void initState() {
    super.initState();
    _picNameController.text = widget.initialData['pic_name']?.toString() ?? '';
    _activitiesController.text = _activitiesFromValue(
      widget.initialData['activities'],
    ).join('\n');
    _stockPercentageController.text =
        widget.initialData['stock_percentage']?.toString() ?? '';
    _stockPcsController.text =
        widget.initialData['stock_pcs']?.toString() ?? '';
    _notesController.text = widget.initialData['notes']?.toString() ?? '';
  }

  @override
  void dispose() {
    _picNameController.dispose();
    _activitiesController.dispose();
    _stockPercentageController.dispose();
    _stockPcsController.dispose();
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  List<String> _activitiesFromValue(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  int? _nullableInteger(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  Map<String, dynamic> _changedFields() {
    final changes = <String, dynamic>{};
    final picName = _picNameController.text.trim();
    final originalPicName =
        widget.initialData['pic_name']?.toString().trim() ?? '';
    if (picName != originalPicName) {
      changes['pic_name'] = picName.isEmpty ? null : picName;
    }

    final activities = _activitiesController.text
        .split('\n')
        .map((activity) => activity.trim())
        .where((activity) => activity.isNotEmpty)
        .toList();
    final originalActivities = _activitiesFromValue(
      widget.initialData['activities'],
    );
    if (!_sameStringList(activities, originalActivities)) {
      changes['activities'] = activities.isEmpty ? null : activities;
    }

    final stockPercentage = _nullableInteger(_stockPercentageController.text);
    final originalStockPercentage = _nullableInteger(
      widget.initialData['stock_percentage']?.toString() ?? '',
    );
    if (stockPercentage != originalStockPercentage) {
      changes['stock_percentage'] = stockPercentage;
    }

    final stockPcs = _nullableInteger(_stockPcsController.text);
    final originalStockPcs = _nullableInteger(
      widget.initialData['stock_pcs']?.toString() ?? '',
    );
    if (stockPcs != originalStockPcs) {
      changes['stock_pcs'] = stockPcs;
    }

    final notes = _notesController.text;
    final originalNotes = widget.initialData['notes']?.toString() ?? '';
    if (notes != originalNotes) {
      changes['notes'] = notes.trim().isEmpty ? null : notes;
    }

    return changes;
  }

  bool _sameStringList(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final changes = _changedFields();
    if (changes.isEmpty) {
      setState(() {
        _changesError = 'Ubah setidaknya satu nilai laporan sebelum mengirim.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
      _changesError = null;
    });
    final error = await widget.onSubmit(changes, _reasonController.text.trim());
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitError = error;
    });
    if (error == null) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Material(
          color: const Color(0xFFF6FAFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                const Text(
                  'Ajukan Koreksi Kunjungan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003F87),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nilai yang tidak diubah tidak akan dikirim. Backend tetap memvalidasi kelayakan koreksi.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF424752)),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _picNameController,
                  label: 'Nama PIC',
                  maxLength: 255,
                ),
                _buildTextField(
                  controller: _activitiesController,
                  label: 'Aktivitas (satu aktivitas per baris)',
                  maxLines: 3,
                  validator: (value) {
                    for (final activity in (value ?? '').split('\n')) {
                      if (activity.length > 255) {
                        return 'Setiap aktivitas maksimal 255 karakter.';
                      }
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _stockPercentageController,
                  label: 'Persentase stok',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return null;
                    final number = int.tryParse(text);
                    if (number == null || number > 100) {
                      return 'Masukkan angka dari 0 sampai 100.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _stockPcsController,
                  label: 'Stok (Pcs)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildTextField(
                  controller: _notesController,
                  label: 'Catatan',
                  maxLength: 10000,
                  maxLines: 3,
                ),
                _buildTextField(
                  controller: _reasonController,
                  label: 'Alasan koreksi (wajib)',
                  maxLength: 2000,
                  maxLines: 3,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Alasan koreksi wajib diisi.';
                    }
                    return null;
                  },
                ),
                if (_changesError != null || _submitError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _changesError ?? _submitError!,
                    style: const TextStyle(color: Color(0xFFB3261E)),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003F87),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kirim Koreksi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator:
            validator ??
            (value) {
              if (maxLength != null &&
                  value != null &&
                  value.length > maxLength) {
                return 'Teks terlalu panjang.';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
