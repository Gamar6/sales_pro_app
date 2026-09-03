import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/visit_model.dart';
import '../../services/visit_service.dart';

enum VisitFormResult { completed, cancelled }

class VisitFormPage extends StatefulWidget {
  final String outletName;
  final String? visitId;

  const VisitFormPage({super.key, required this.outletName, this.visitId});

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> {
  final VisitService _visitService = VisitService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _outletController;
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _stokPersenController = TextEditingController();
  final TextEditingController _stokPcsController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String? _currentVisitId;
  bool _isFetchingVisitId = false;
  bool _isLoading = false;

  bool _isCheckChecked = false;
  bool _isVisitChecked = false;
  bool _isStikerChecked = false;
  bool _isLainLainChecked = false;

  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _outletController = TextEditingController(text: widget.outletName);
    _currentVisitId = widget.visitId;

    // Fetch ID otomatis jika tidak di-pass dari widget parent
    if (_currentVisitId == null || _currentVisitId!.isEmpty) {
      _fetchActiveVisitId();
    }
  }

  @override
  void dispose() {
    _outletController.dispose();
    _picController.dispose();
    _stokPersenController.dispose();
    _stokPcsController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  List<String> get _selectedAktivitas {
    final list = <String>[];
    if (_isCheckChecked) list.add('Cek');
    if (_isVisitChecked) list.add('Visit');
    if (_isStikerChecked) list.add('Pemasangan Stiker');
    if (_isLainLainChecked) list.add('Lain-lain');
    return list;
  }

  Future<void> _fetchActiveVisitId() async {
    setState(() => _isFetchingVisitId = true);
    try {
      final activeId = await _visitService.getActiveVisit();
      if (mounted) {
        setState(() => _currentVisitId = activeId);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal mengambil ID Kunjungan aktif: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingVisitId = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 4) {
      _showMessage('Maksimal 4 foto dokumentasi!');
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _selectedImages.add(pickedFile));
    }
  }

  Future<void> _submitForm() async {
    if (_currentVisitId == null || _currentVisitId!.isEmpty) {
      _showMessage('Gagal menyimpan: ID Kunjungan tidak ditemukan!');
      return;
    }

    final validationMessage = _validateForm();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    setState(() => _isLoading = true);

    final requestModel = VisitRequestModel(
      outletName: widget.outletName,
      visitId:
          _currentVisitId, // FIX: Gunakan variabel internal _currentVisitId
      pic: _picController.text.trim(),
      sisaStokPersen: _stokPersenController.text.trim(),
      sisaStokPcs: _stokPcsController.text.trim(),
      catatan: _catatanController.text.trim(),
      aktivitas: _selectedAktivitas,
      photos: _selectedImages,
    );

    try {
      await _visitService.submitVisit(requestModel);

      if (mounted) {
        _showMessage('Data kunjungan berhasil disimpan!');
        Navigator.pop(context, VisitFormResult.completed);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        _showMessage('Gagal mengirim laporan: $message');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateForm() {
    if (_picController.text.trim().isEmpty) {
      return 'Nama PIC penanggung jawab wajib diisi.';
    }
    if (_selectedAktivitas.isEmpty) {
      return 'Pilih minimal satu aktivitas kunjungan.';
    }
    if (_stokPersenController.text.trim().isEmpty &&
        _stokPcsController.text.trim().isEmpty) {
      return 'Isi sisa stok dalam persen atau pcs.';
    }

    final percentageText = _stokPersenController.text.trim();
    if (percentageText.isNotEmpty) {
      final percentage = int.tryParse(percentageText);
      if (percentage == null || percentage < 0 || percentage > 100) {
        return 'Sisa stok persen harus berupa angka 0 sampai 100.';
      }
    }

    final piecesText = _stokPcsController.text.trim();
    if (piecesText.isNotEmpty) {
      final pieces = int.tryParse(piecesText);
      if (pieces == null || pieces < 0) {
        return 'Sisa stok pcs harus berupa angka 0 atau lebih.';
      }
    }

    if (_selectedImages.isEmpty) {
      return 'Lampirkan minimal satu foto dokumentasi.';
    }

    return null;
  }

  Future<void> _cancelVisit() async {
    final visitId = _currentVisitId;
    if (visitId == null || visitId.isEmpty || _isLoading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan kunjungan?'),
        content: const Text(
          'Laporan yang belum dikirim tidak akan disimpan dan toko dapat dikunjungi kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Batalkan Kunjungan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _visitService.cancelVisit(visitId);
      if (mounted) {
        Navigator.pop(context, VisitFormResult.cancelled);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        _showMessage('Gagal membatalkan kunjungan: $message');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF003F87)),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF003F87),
              ),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF424752)),
          tooltip: 'Kembali — kunjungan tetap aktif',
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Fiva Food',
          style: TextStyle(
            color: Color(0xFF003F87),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _cancelVisit,
            tooltip: 'Batalkan kunjungan',
            icon: const Icon(Icons.cancel_outlined, color: Color(0xFFBA1A1A)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Input Kunjungan Harian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141D23),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Catat aktivitas operasional lapangan.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF727784)),
                ),
                const SizedBox(height: 20),
                _buildFormSection(),
                const SizedBox(height: 20),
                _buildPhotoSection(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel('Outlet Name'),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            controller: _outletController,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFECF5FE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('PIC'),
          const SizedBox(height: 8),
          TextField(
            controller: _picController,
            decoration: InputDecoration(
              hintText: 'Nama penanggung jawab',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Aktivitas'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildCheckboxItem(
                'Cek',
                _isCheckChecked,
                (v) => setState(() => _isCheckChecked = v ?? false),
              ),
              _buildCheckboxItem(
                'Visit',
                _isVisitChecked,
                (v) => setState(() => _isVisitChecked = v ?? false),
              ),
              _buildCheckboxItem(
                'Pemasangan Stiker',
                _isStikerChecked,
                (v) => setState(() => _isStikerChecked = v ?? false),
              ),
              _buildCheckboxItem(
                'Lain-lain',
                _isLainLainChecked,
                (v) => setState(() => _isLainLainChecked = v ?? false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Sisa Stok (%)'),
          const SizedBox(height: 8),
          TextField(
            controller: _stokPersenController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: '0',
              suffixText: '% ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Sisa Stok (Pcs)'),
          const SizedBox(height: 8),
          TextField(
            controller: _stokPcsController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'Pcs ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Catatan'),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Masukkan catatan kunjungan...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTextFieldLabel('Dokumentasi Foto'),
            Text(
              '${_selectedImages.length}/4 Foto',
              style: const TextStyle(fontSize: 12, color: Color(0xFF727784)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length < 4
              ? _selectedImages.length + 1
              : 4,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length && _selectedImages.length < 4) {
              return InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC2C6D4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Color(0xFF003F87),
                        size: 20,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'TAMBAH',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003F87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _SelectedImagePreview(image: _selectedImages[index]),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedImages.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    // Tombol mati otomatis jika sedang kirim data ATAU sedang mengambil ID
    final bool isButtonDisabled = _isLoading || _isFetchingVisitId;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003F87),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading || _isFetchingVisitId
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Simpan Kunjungan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCheckboxItem(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFC2C6D4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF003F87),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF141D23)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedImagePreview extends StatefulWidget {
  final XFile image;

  const _SelectedImagePreview({required this.image});

  @override
  State<_SelectedImagePreview> createState() => _SelectedImagePreviewState();
}

class _SelectedImagePreviewState extends State<_SelectedImagePreview> {
  late Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = widget.image.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant _SelectedImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.path != widget.image.path) {
      _bytesFuture = widget.image.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }

        if (snapshot.hasError) {
          return const ColoredBox(
            color: Color(0xFFF1F3F5),
            child: Center(child: Icon(Icons.broken_image_outlined)),
          );
        }

        return const ColoredBox(
          color: Color(0xFFF1F3F5),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
