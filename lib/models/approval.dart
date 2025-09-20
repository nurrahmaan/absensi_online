class Approval {
  final int? id;
  final String? category;
  final String? subcategory;
  final String? keterangan;
  final String? startdate;
  final String? enddate;
  final String? reqdate;
  final String? status;
  final String? reason;
  final String? durasi;
  final String? jadwal;
  final String? absen;

  Approval({
    this.id,
    this.category,
    this.subcategory,
    this.keterangan,
    this.startdate,
    this.enddate,
    this.reqdate,
    this.status,
    this.reason,
    this.durasi,
    this.jadwal,
    this.absen,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'],
      category: json['category'],
      subcategory: json['subcategory'],
      keterangan: json['keterangan'],
      startdate: json['startdate'],
      enddate: json['enddate'],
      reqdate: json['reqdate'],
      status: json['status'],
      reason: json['reason'],
      durasi: json['durasi'],
      jadwal: json['jadwal'],
      absen: json['absen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'keterangan': keterangan,
      'startdate': startdate,
      'enddate': enddate,
      'reqdate': reqdate,
      'status': status,
      'reason': reason,
      'durasi': durasi,
      'jadwal': jadwal,
      'absen': absen,
    };
  }
}
