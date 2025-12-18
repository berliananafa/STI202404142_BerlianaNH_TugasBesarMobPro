class Destinasi {
  int? id;
  String nama;
  String lokasi;
  String deskripsi;
  String? fotoPath;
  String jamBuka;
  double latitude;
  double longitude;

  Destinasi({
    this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    this.fotoPath,
    required this.jamBuka,
    required this.latitude,
    required this.longitude,
  });

  factory Destinasi.fromMap(Map<String, dynamic> m) => Destinasi(
    id: m['id'] as int?,
    nama: m['nama'] as String,
    lokasi: m['lokasi'] as String,
    deskripsi: m['deskripsi'] as String,
    fotoPath: m['fotoPath'] as String?,
    jamBuka: m['jamBuka'] as String,
    latitude: (m['lat'] as num).toDouble(),
    longitude: (m['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'lokasi': lokasi,
    'deskripsi': deskripsi,
    'fotoPath': fotoPath,
    'jamBuka': jamBuka,
    'lat': latitude,
    'lng': longitude,
  };
}
