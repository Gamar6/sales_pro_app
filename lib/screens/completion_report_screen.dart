import 'package:flutter/material.dart';

class CompletionReportScreen extends StatefulWidget {
  final String storeName;

  const CompletionReportScreen({Key? key, required this.storeName})
    : super(key: key);

  @override
  State<CompletionReportScreen> createState() => _CompletionReportScreenState();
}

class _CompletionReportScreenState extends State<CompletionReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF444748)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Laporan Penyelesaian (${widget.storeName})',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D5F5F),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFFC4C7C8)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama Penerima',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. John Doe',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Jumlah Barang Dibeli',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Foto dengan Penerima',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFC4C7C8),
                      width: 2,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        color: Color(0xFF395F99),
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to capture or upload photo',
                        style: TextStyle(color: Color(0xFF444748)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF395F99),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan berhasil diselesaikan!'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Selesaikan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
