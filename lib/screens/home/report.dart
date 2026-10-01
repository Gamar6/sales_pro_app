import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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
  static const Color _primaryColor = Color(0xFF003F87);
  static const Color _backgroundColor = Color(0xFFF6FAFF);
  static const Color _textColor = Color(0xFF141D23);
  static const Color _secondaryTextColor = Color(0xFF727784);
  static const Color _borderColor = Color(0xFFC2C6D4);

  final VisitService _visitService = VisitService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _outletController;
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _stokPersenController = TextEditingController();
  final TextEditingController _stokPcsController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _lainLainController = TextEditingController();

  String? _currentVisitId;

  bool _isFetchingVisitId = false;
  bool _isLoading = false;

  bool _isCheckChecked = false;
  bool _isVisitChecked = false;
  bool _isStikerChecked = false;
  bool _isOrderChecked = false;
  bool _isLainLainChecked = false;

  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();

    _outletController = TextEditingController(text: widget.outletName);
    _currentVisitId = widget.visitId;

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
    _lainLainController.dispose();
    super.dispose();
  }

  // GETTERS

  List<String> get _selectedAktivitas {
    final aktivitas = <String>[];

    if (_isCheckChecked) {
      aktivitas.add('Cek');
    }

    if (_isVisitChecked) {
      aktivitas.add('Visit');
    }

    if (_isStikerChecked) {
      aktivitas.add('Pemasangan Stiker');
    }

    if (_isOrderChecked) {
      aktivitas.add('Order');
    }

    if (_isLainLainChecked) {
      aktivitas.add('Lain-lain');
    }

    return aktivitas;
  }

  bool get _hasVisitId =>
      _currentVisitId != null && _currentVisitId!.isNotEmpty;

  bool get _isBusy => _isLoading || _isFetchingVisitId;

  // VISIT ID

  Future<void> _fetchActiveVisitId() async {
    setState(() {
      _isFetchingVisitId = true;
    });

    try {
      final activeId = await _visitService.getActiveVisit();

      if (!mounted) return;

      setState(() {
        _currentVisitId = activeId;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal mengambil ID Kunjungan aktif: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _isFetchingVisitId = false;
      });
    }
  }

  // IMAGE

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 4) {
      _showMessage('Maksimal 4 foto dokumentasi!');
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null || !mounted) return;

      setState(() {
        _selectedImages.add(pickedFile);
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal mengambil foto: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: _primaryColor),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: _primaryColor),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Geolocator
  Future<Position> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Layanan lokasi/GPS belum diaktifkan.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan aplikasi.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // FORM VALIDATION

  String? _validateForm() {
    if (!_hasVisitId) {
      return 'ID Kunjungan tidak ditemukan.';
    }

    if (_picController.text.trim().isEmpty) {
      return 'Nama PIC penanggung jawab wajib diisi.';
    }

    if (_selectedAktivitas.isEmpty) {
      return 'Pilih minimal satu aktivitas kunjungan.';
    }

    if (_isLainLainChecked && _lainLainController.text.trim().isEmpty) {
      return 'Jelaskan aktivitas lain-lain.';
    }

    final stokPersen = _stokPersenController.text.trim();
    final stokPcs = _stokPcsController.text.trim();

    if (stokPersen.isEmpty && stokPcs.isEmpty) {
      return 'Isi sisa stok dalam persen atau pcs.';
    }

    if (stokPersen.isNotEmpty) {
      final percentage = int.tryParse(stokPersen);

      if (percentage == null || percentage < 0 || percentage > 100) {
        return 'Sisa stok persen harus berupa angka 0 sampai 100.';
      }
    }

    if (stokPcs.isNotEmpty) {
      final pieces = int.tryParse(stokPcs);

      if (pieces == null || pieces < 0) {
        return 'Sisa stok pcs harus berupa angka 0 atau lebih.';
      }
    }

    if (_selectedImages.isEmpty) {
      return 'Lampirkan minimal satu foto dokumentasi.';
    }

    return null;
  }

  Future<void> _submitForm() async {
    final validationMessage = _validateForm();

    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _showMessage('Mengambil lokasi GPS...');

      final position = await _getCurrentLocation();

      if (!mounted) return;

      final requestModel = VisitRequestModel(
        outletName: widget.outletName,
        visitId: _currentVisitId,
        pic: _picController.text.trim(),
        sisaStokPersen: _stokPersenController.text.trim(),
        sisaStokPcs: _stokPcsController.text.trim(),
        catatan: _buildCatatan(),
        aktivitas: _selectedAktivitas,
        photos: _selectedImages,

        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      await _visitService.submitVisit(requestModel);

      if (!mounted) return;

      _showMessage('Data kunjungan berhasil disimpan!');

      Navigator.pop(context, VisitFormResult.completed);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      _showMessage('Gagal mengirim laporan: $message');
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildCatatan() {
    final catatan = _catatanController.text.trim();
    final lainLain = _lainLainController.text.trim();

    if (!_isLainLainChecked || lainLain.isEmpty) {
      return catatan;
    }

    if (catatan.isEmpty) {
      return 'Lain-lain: $lainLain';
    }

    return '$catatan\nLain-lain: $lainLain';
  }

  // CANCEL

  Future<void> _cancelVisit() async {
    if (!_hasVisitId || _isLoading) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan kunjungan?'),
          content: const Text(
            'Laporan yang belum dikirim tidak akan disimpan '
            'dan toko dapat dikunjungi kembali.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Kembali'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Batalkan Kunjungan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _visitService.cancelVisit(_currentVisitId!);

      if (!mounted) return;

      Navigator.pop(context, VisitFormResult.cancelled);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      _showMessage('Gagal membatalkan kunjungan: $message');
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // UI HELPERS

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: _textColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextAlign textAlign = TextAlign.start,
    bool readOnly = false,
    Color? fillColor,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: textAlign,
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        filled: fillColor != null,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (checked) {
                  onChanged(checked ?? false);
                },
                activeColor: _primaryColor,
                tristate: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: _textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FORM SECTION

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel('Outlet Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _outletController,
            readOnly: true,
            fillColor: const Color(0xFFECF5FE),
          ),

          const SizedBox(height: 16),

          _buildTextFieldLabel('PIC'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _picController,
            hintText: 'Nama penanggung jawab',
          ),

          const SizedBox(height: 16),

          _buildTextFieldLabel('Aktivitas'),
          const SizedBox(height: 8),

          _buildAktivitasSection(),

          const SizedBox(height: 16),

          _buildTextFieldLabel('Sisa Stok (%)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _stokPersenController,
            hintText: '0',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            suffixText: '% ',
          ),

          const SizedBox(height: 16),

          _buildTextFieldLabel('Sisa Stok (Pcs)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _stokPcsController,
            hintText: '0',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            suffixText: 'Pcs ',
          ),

          const SizedBox(height: 16),

          _buildTextFieldLabel('Catatan'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _catatanController,
            hintText: 'Masukkan catatan kunjungan...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildCheckboxItem(
              label: 'Cek',
              value: _isCheckChecked,
              onChanged: (value) {
                setState(() {
                  _isCheckChecked = value;
                });
              },
            ),
            _buildCheckboxItem(
              label: 'Visit',
              value: _isVisitChecked,
              onChanged: (value) {
                setState(() {
                  _isVisitChecked = value;
                });
              },
            ),
            _buildCheckboxItem(
              label: 'Pemasangan Stiker',
              value: _isStikerChecked,
              onChanged: (value) {
                setState(() {
                  _isStikerChecked = value;
                });
              },
            ),
            _buildCheckboxItem(
              label: 'Order',
              value: _isOrderChecked,
              onChanged: (value) {
                setState(() {
                  _isOrderChecked = value;
                });
              },
            ),
            _buildCheckboxItem(
              label: 'Lain-lain',
              value: _isLainLainChecked,
              onChanged: (value) {
                setState(() {
                  _isLainLainChecked = value;

                  if (!_isLainLainChecked) {
                    _lainLainController.clear();
                  }
                });
              },
            ),
          ],
        ),

        if (_isLainLainChecked) ...[
          const SizedBox(height: 12),
          _buildTextFieldLabel('Detail Lain-lain'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _lainLainController,
            hintText: 'Contoh: Display produk, pengecekan freezer, dll.',
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  // PHOTO SECTION

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTextFieldLabel('Dokumentasi Foto'),
            Text(
              '${_selectedImages.length}/4 Foto',
              style: const TextStyle(fontSize: 12, color: _secondaryTextColor),
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
            final isAddButton =
                index == _selectedImages.length && _selectedImages.length < 4;

            if (isAddButton) {
              return _buildAddPhotoButton();
            }

            return _buildSelectedPhoto(index);
          },
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: _primaryColor, size: 20),
            SizedBox(height: 4),
            Text(
              'TAMBAH',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPhoto(int index) {
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
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // SUBMIT BUTTON

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isBusy ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isBusy
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

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
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
            color: _primaryColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Catat aktivitas operasional lapangan.',
                  style: TextStyle(fontSize: 12, color: _secondaryTextColor),
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
}

// IMAGE PREVIEW

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
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _SelectedImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image.path != widget.image.path) {
      _loadImage();
    }
  }

  void _loadImage() {
    _bytesFuture = widget.image.readAsBytes();
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
