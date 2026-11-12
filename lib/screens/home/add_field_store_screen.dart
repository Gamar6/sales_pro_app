import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/field_store_model.dart';
import '../../models/visit_report_model.dart';
import '../../services/field_store_service.dart';
import '../../services/visit_service.dart';

class AddFieldStoreScreen extends StatefulWidget {
  const AddFieldStoreScreen({super.key});

  @override
  State<AddFieldStoreScreen> createState() => _AddFieldStoreScreenState();
}

class _AddFieldStoreScreenState extends State<AddFieldStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _picController = TextEditingController();
  final _stockPercentageController = TextEditingController();
  final _stockPcsController = TextEditingController();
  final _notesController = TextEditingController();
  final _otherActivityController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _fieldStoreService = FieldStoreService();
  final _visitService = VisitService();

  XFile? _photo;
  Uint8List? _photoBytes;
  FieldStoreModel? _createdStore;
  Position? _position;
  String? _locationError;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _isCheckSelected = false;
  bool _isVisitSelected = true;
  bool _isStickerSelected = false;
  bool _isOrderSelected = false;
  bool _isOtherSelected = false;

  bool get _hasCreatedStore => _createdStore != null;

  List<String> get _selectedActivities => [
    if (_isCheckSelected) 'Cek',
    if (_isVisitSelected) 'Visit',
    if (_isStickerSelected) 'Pemasangan Stiker',
    if (_isOrderSelected) 'Order',
    if (_isOtherSelected) 'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _picController.dispose();
    _stockPercentageController.dispose();
    _stockPcsController.dispose();
    _notesController.dispose();
    _otherActivityController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Aktifkan layanan GPS pada perangkat.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen. Aktifkan di pengaturan aplikasi.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() => _position = position);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _position = null;
        _locationError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _showPhotoSourcePicker() async {
    if (_isSubmitting || _hasCreatedStore) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil foto dengan kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri / file handphone'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;
    await _pickPhoto(source);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _photo = photo;
            _photoBytes = bytes;
          });
        }
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal memilih foto: $error');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photo == null) {
      _showMessage('Ambil atau pilih foto toko terlebih dahulu.');
      return;
    }
    if (_position == null) {
      _showMessage(
        'Lokasi GPS belum tersedia. Perbarui lokasi terlebih dahulu.',
      );
      return;
    }
    if (_picController.text.trim().isEmpty) {
      _showMessage('Nama PIC penanggung jawab wajib diisi.');
      return;
    }
    if (_selectedActivities.isEmpty) {
      _showMessage('Pilih minimal satu aktivitas kunjungan.');
      return;
    }
    if (_isOtherSelected && _otherActivityController.text.trim().isEmpty) {
      _showMessage('Jelaskan aktivitas lain-lain.');
      return;
    }
    final stockPercentage = _stockPercentageController.text.trim();
    if (stockPercentage.isNotEmpty) {
      final value = int.tryParse(stockPercentage);
      if (value == null || value < 0 || value > 100) {
        _showMessage('Sisa stok persen harus berupa angka 0 sampai 100.');
        return;
      }
    }
    final stockPcs = _stockPcsController.text.trim();
    if (stockPcs.isNotEmpty) {
      final value = int.tryParse(stockPcs);
      if (value == null || value < 0) {
        _showMessage('Sisa stok pcs harus berupa angka 0 atau lebih.');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      var store = _createdStore;
      if (store == null) {
        final newStore = FieldStoreModel(
          storeName: _storeNameController.text.trim(),
          ownerName: _ownerNameController.text.trim().isEmpty
              ? null
              : _ownerNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _position!.latitude,
          longitude: _position!.longitude,
        );
        store = await _fieldStoreService.createFieldStore(
          store: newStore,
          photo: _photo!,
        );
        if (mounted) setState(() => _createdStore = store);
      }

      if (store.id == null) {
        throw StateError(
          'Toko berhasil disimpan, tetapi respons API tidak menyertakan ID toko. '
          'Pastikan endpoint field-stores mengembalikan ID record.',
        );
      }

      final report = VisitReportModel(
        storeType: 'field',
        storeId: store.id!,
        picName: _picController.text.trim(),
        activities: _selectedActivities,
        stockPercentage: int.tryParse(_stockPercentageController.text.trim()),
        stockPcs: int.tryParse(_stockPcsController.text.trim()),
        notes: _buildReportNotes(),
        photos: [_photo!],
        checkInPhoto: _photo,
        checkInLatitude: _position!.latitude,
        checkInLongitude: _position!.longitude,
        salesAccuracy: _position!.accuracy,
      );
      await _visitService.submitVisit(report);
      if (mounted) Navigator.pop(context, store);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        _hasCreatedStore
            ? 'Toko sudah tersimpan, tetapi laporan kunjungan gagal. Periksa koneksi lalu kirim ulang laporan: '
                  '${error.toString().replaceFirst('Exception: ', '')}'
            : 'Gagal menyimpan toko: ${error.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _buildReportNotes() {
    final notes = _notesController.text.trim();
    final otherActivity = _isOtherSelected
        ? _otherActivityController.text.trim()
        : '';
    if (notes.isEmpty && otherActivity.isEmpty) return null;
    if (notes.isEmpty) return 'Lain-lain: $otherActivity';
    if (otherActivity.isEmpty) return notes;
    return '$notes\nLain-lain: $otherActivity';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        title: const Text('Tambah Toko Baru'),
        backgroundColor: const Color(0xFFF6FAFF),
        foregroundColor: const Color(0xFF003F87),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Isi data toko dan laporan kunjungan sekaligus. Toko akan disimpan '
              'lalu laporan check-in langsung dikirim.',
              style: TextStyle(color: Colors.black54),
            ),
            if (_hasCreatedStore) ...[
              const SizedBox(height: 12),
              const Card(
                color: Color(0xFFFFF4E5),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Toko sudah tersimpan. Kirim ulang untuk mencoba menyimpan '
                    'laporan kunjungan tanpa membuat duplikat toko.',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildTextField(
              controller: _storeNameController,
              label: 'Nama Toko',
              icon: Icons.storefront_outlined,
              enabled: !_hasCreatedStore,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _ownerNameController,
              label: 'Nama Pemilik',
              icon: Icons.person_outline,
              isRequired: false,
              enabled: !_hasCreatedStore,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              isRequired: false,
              enabled: !_hasCreatedStore,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _addressController,
              label: 'Alamat',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              enabled: !_hasCreatedStore,
            ),
            const SizedBox(height: 20),
            _buildVisitReportFields(),
            const SizedBox(height: 20),
            _buildPhotoPicker(),
            const SizedBox(height: 20),
            _buildLocationCard(),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF003F87),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSubmitting
                      ? 'Menyimpan toko & laporan...'
                      : _hasCreatedStore
                      ? 'Kirim Ulang Laporan Kunjungan'
                      : 'Simpan Toko & Laporan Kunjungan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = true,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) =>
          isRequired && (value == null || value.trim().isEmpty)
          ? '$label wajib diisi.'
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Toko', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSubmitting || _hasCreatedStore
              ? null
              : _showPhotoSourcePicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFC2C6D4)),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: _photo == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 36,
                        color: Color(0xFF003F87),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ketuk untuk mengambil foto atau memilih file dari handphone',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_photoBytes!, fit: BoxFit.cover),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton.filled(
                          onPressed: _hasCreatedStore || _isSubmitting
                              ? null
                              : _showPhotoSourcePicker,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Ganti foto',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitReportFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Kunjungan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003F87),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _picController,
          label: 'Nama PIC',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        const Text('Aktivitas', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: [
            _buildActivityChip('Cek', _isCheckSelected, (value) {
              setState(() => _isCheckSelected = value);
            }),
            _buildActivityChip('Visit', _isVisitSelected, (value) {
              setState(() => _isVisitSelected = value);
            }),
            _buildActivityChip(
              'Pemasangan Stiker',
              _isStickerSelected,
              (value) => setState(() => _isStickerSelected = value),
            ),
            _buildActivityChip('Order', _isOrderSelected, (value) {
              setState(() => _isOrderSelected = value);
            }),
            _buildActivityChip('Lain-lain', _isOtherSelected, (value) {
              setState(() => _isOtherSelected = value);
            }),
          ],
        ),
        if (_isOtherSelected) ...[
          const SizedBox(height: 8),
          _buildTextField(
            controller: _otherActivityController,
            label: 'Detail aktivitas lain-lain',
            icon: Icons.edit_note,
            maxLines: 2,
          ),
        ],
        const SizedBox(height: 14),
        _buildTextField(
          controller: _stockPercentageController,
          label: 'Sisa Stok (%)',
          icon: Icons.percent,
          keyboardType: TextInputType.number,
          isRequired: false,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _stockPcsController,
          label: 'Sisa Stok (Pcs)',
          icon: Icons.inventory_2_outlined,
          keyboardType: TextInputType.number,
          isRequired: false,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _notesController,
          label: 'Catatan Kunjungan',
          icon: Icons.notes_outlined,
          maxLines: 3,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildActivityChip(
    String label,
    bool selected,
    ValueChanged<bool> onSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: _isSubmitting ? null : onSelected,
      selectedColor: const Color(0xFFD9E4EF),
      checkmarkColor: const Color(0xFF003F87),
    );
  }

  Widget _buildLocationCard() {
    final position = _position;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed, color: Color(0xFF003F87)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi GPS Sales',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (_isLoadingLocation)
                  const Text('Mengambil lokasi...')
                else if (position != null)
                  Text(
                    '${position.latitude.toStringAsFixed(6)}, '
                    '${position.longitude.toStringAsFixed(6)}',
                  )
                else
                  Text(
                    _locationError ?? 'Lokasi belum tersedia.',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoadingLocation || _isSubmitting || _hasCreatedStore
                ? null
                : _captureLocation,
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Perbarui lokasi',
          ),
        ],
      ),
    );
  }
}
