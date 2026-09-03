import 'package:image_picker/image_picker.dart';

class VisitRequestModel {
  final String outletName;
  final String? visitId;
  final String pic;
  final String sisaStokPersen;
  final String sisaStokPcs;
  final String catatan;
  final List<String> aktivitas;
  final List<XFile> photos;

  VisitRequestModel({
    required this.outletName,
    this.visitId,
    required this.pic,
    required this.sisaStokPersen,
    required this.sisaStokPcs,
    required this.catatan,
    required this.aktivitas,
    required this.photos,
  });

  Map<String, String> toFieldsMap() {
    final Map<String, String> fields = {
      'pic_name': pic,
      'stock_percentage': sisaStokPersen,
      'stock_pcs': sisaStokPcs,
      'notes': catatan,
    };

    for (var index = 0; index < aktivitas.length; index++) {
      fields['activities[$index]'] = aktivitas[index];
    }

    return fields;
  }
}