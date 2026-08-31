import 'package:flutter/material.dart';
import '../../services/visit_service.dart';
import './detail_kunjungan_page.dart';

class VisitHistoryPage extends StatefulWidget {
  const VisitHistoryPage({super.key});

  @override
  State<VisitHistoryPage> createState() => _VisitHistoryPageState();
}

class _VisitHistoryPageState extends State<VisitHistoryPage> {
  final VisitService _visitService = VisitService();

  bool _isLoading = true;
  List<dynamic> _visits = [];
  List<dynamic> _filteredVisits = [];
  String _selectedFilter = 'Hari Ini';
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _fetchVisitHistory();
  }

  Future<void> _fetchVisitHistory() async {
    setState(() => _isLoading = true);
    final data = await _visitService.getVisitHistory();
    setState(() {
      _visits = data;
      _isLoading = false;
    });
    _applyFilter();
  }

  DateTime? _parseVisitDate(Map<String, dynamic> visit) {
    final dateStr =
        visit['check_in_at'] ?? visit['visit_date'] ?? visit['created_at'];
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr.toString())?.toLocal();
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    setState(() {
      _filteredVisits = _visits.where((visit) {
        if (visit is! Map<String, dynamic>) return false;
        final visitDate = _parseVisitDate(visit);
        if (visitDate == null) return false;

        final visitDay = DateTime(
          visitDate.year,
          visitDate.month,
          visitDate.day,
        );

        switch (_selectedFilter) {
          case 'Hari Ini':
            return visitDay.isAtSameMomentAs(today);
          case 'Kemarin':
            return visitDay.isAtSameMomentAs(yesterday);
          case 'Minggu Ini':
            return (visitDay.isAtSameMomentAs(startOfWeek) ||
                    visitDay.isAfter(startOfWeek)) &&
                visitDay.isBefore(endOfWeek);
          case 'Kustom':
            if (_customDateRange == null) return true;
            final start = DateTime(
              _customDateRange!.start.year,
              _customDateRange!.start.month,
              _customDateRange!.start.day,
            );
            final end = DateTime(
              _customDateRange!.end.year,
              _customDateRange!.end.month,
              _customDateRange!.end.day,
              23,
              59,
              59,
            );
            return visitDate.isAfter(
                  start.subtract(const Duration(seconds: 1)),
                ) &&
                visitDate.isBefore(end.add(const Duration(seconds: 1)));
          default:
            return true;
        }
      }).toList();
    });
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003F87),
              onPrimary: Colors.white,
              onSurface: Color(0xFF141D23),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedFilter = 'Kustom';
      });
      _applyFilter();
    }
  }

  void _showVisitDetail(Map<String, dynamic> visit) {
    final report = visit['report'] as Map<String, dynamic>?;
    final storeName =
        visit['outlet_name'] ??
        visit['store_name'] ??
        visit['partner_name'] ??
        visit['partner']?['name'] ??
        visit['store']?['name'] ??
        'Toko Tanpa Nama';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  storeName.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003F87),
                  ),
                ),
                Text(
                  'Tanggal: ${visit['visit_date'] ?? visit['check_in_at'] ?? '-'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Divider(height: 24),

                if (report == null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Belum ada laporan detail untuk kunjungan ini.',
                      ),
                    ),
                  ),
                ] else ...[
                  _buildDetailRow('Nama PIC', report['pic_name'] ?? '-'),
                  _buildDetailRow(
                    'Stok (Pcs)',
                    '${report['stock_pcs'] ?? 0} Pcs',
                  ),
                  _buildDetailRow(
                    'Persentase Stok',
                    '${report['stock_percentage'] ?? 0}%',
                  ),
                  _buildDetailRow('Catatan', report['notes'] ?? '-'),
                  const SizedBox(height: 12),
                  const Text(
                    'Aktivitas:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  if (report['activities'] is List)
                    ...((report['activities'] as List).map(
                      (act) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                        child: Text(
                          '• $act',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ))
                  else
                    const Text('-', style: TextStyle(fontSize: 13)),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
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
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali ke Dashboard',
        ),
        title: const Text(
          'Riwayat Kunjungan',
          style: TextStyle(
            color: Color(0xFF003F87),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF003F87)),
            onPressed: _fetchVisitHistory,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFC2C6D4), height: 1.0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchVisitHistory,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Filter Section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('Hari Ini'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Kemarin'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Minggu Ini'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Kustom', hasDropdown: true),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats Summary Dinamis
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFECF5FE),
                border: Border.all(color: const Color(0xFFC2C6D4)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Kunjungan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424752),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isLoading ? '...' : '${_filteredVisits.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF141D23),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        'Status Sync',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424752),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Terhubung',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006E25),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Visit List Dinamis
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredVisits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'Tidak ada riwayat kunjungan untuk filter ini.',
                    style: TextStyle(color: Color(0xFF424752)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredVisits.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = _filteredVisits[index] as Map<String, dynamic>;
                  final partner = item['partner'] as Map<String, dynamic>?;

                  final storeName =
                      partner?['name'] ??
                      item['store_name'] ??
                      'Toko Tanpa Nama';
                  final address =
                      partner?['street'] ??
                      item['address'] ??
                      'Alamat tidak tersedia';

                  String timeStr = '-';
                  if (item['check_in_at'] != null) {
                    final parsed = DateTime.tryParse(
                      item['check_in_at'].toString(),
                    )?.toLocal();
                    if (parsed != null) {
                      timeStr =
                          "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
                    }
                  }

                  final status = item['status'] ?? 'COMPLETED';

                  return VisitCard(
                    storeName: storeName.toString(),
                    address: address.toString(),
                    time: timeStr,
                    status: status.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailKunjunganPage(visit: item),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, {bool hasDropdown = false}) {
    final isSelected = _selectedFilter == label;

    return InkWell(
      onTap: () {
        if (label == 'Kustom') {
          _selectCustomDateRange();
        } else {
          setState(() {
            _selectedFilter = label;
          });
          _applyFilter();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF003F87) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF003F87)
                : const Color(0xFFC2C6D4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label == 'Kustom' && _customDateRange != null
                  ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                  : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF424752),
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF424752),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VisitCard extends StatelessWidget {
  final String storeName;
  final String address;
  final String time;
  final String status;
  final VoidCallback onTap;

  const VisitCard({
    super.key,
    required this.storeName,
    required this.address,
    required this.time,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FAFF),
          border: Border.all(color: const Color(0xFFC2C6D4)),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF0056B3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront,
                color: Color(0xFFBBD0FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF141D23),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF424752),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Color(0xFF424752),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF424752),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF80F98B),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, size: 12, color: Color(0xFF007327)),
                  SizedBox(width: 4),
                  Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007327),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
