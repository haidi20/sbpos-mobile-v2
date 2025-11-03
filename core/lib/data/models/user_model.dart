class UserModel {
  final int? id; // mewakili id_petugas
  final String? namaPetugas;
  final String? username;
  final String? password; // biasanya hanya untuk request, tidak disimpan
  final String? token;

  // Field tambahan dari respons
  final int? idKelurahan;
  final String? namaKelurahan;
  final String? namaKecamatan;
  final String? urlFoto;

  UserModel({
    this.id,
    this.namaPetugas,
    this.username,
    this.password,
    this.token,
    this.idKelurahan,
    this.namaKelurahan,
    this.namaKecamatan,
    this.urlFoto,
  });

  UserModel copyWith({
    int? id,
    String? namaPetugas,
    String? username,
    String? password,
    String? token,
    int? idKelurahan,
    String? namaKelurahan,
    String? namaKecamatan,
    String? urlFoto,
  }) {
    return UserModel(
      id: id ?? this.id,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      idKelurahan: idKelurahan ?? this.idKelurahan,
      namaKelurahan: namaKelurahan ?? this.namaKelurahan,
      namaKecamatan: namaKecamatan ?? this.namaKecamatan,
      urlFoto: urlFoto ?? this.urlFoto,
    );
  }

  /// Factory untuk parsing dari respons login
  factory UserModel.fromLoginResponse(Map<String, dynamic> userJson) {
    return UserModel(
      id: _asInt(userJson['id_petugas']),
      username: userJson['username'] as String?,
      namaPetugas: userJson['nama_petugas'] as String?,
      token: userJson['token'] as String?,
      idKelurahan: _asInt(userJson['id_kelurahan']),
      namaKelurahan: userJson['nama_kelurahan'] as String?,
      namaKecamatan: userJson['nama_kecamatan'] as String?,
      urlFoto: userJson['url_foto'] as String?,
      // password tidak ada di respons login → biarkan null
    );
  }

  /// Untuk parsing dari database lokal atau cache
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']),
      namaPetugas: json['nama_petugas'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      idKelurahan: _asInt(json['id_kelurahan']),
      namaKelurahan: json['nama_kelurahan'] as String?,
      namaKecamatan: json['nama_kecamatan'] as String?,
      urlFoto: json['url_foto'] as String?,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) =>
      UserModel.fromJson(map);

  /// Untuk menyimpan ke database lokal (tanpa password)
  Map<String, dynamic> toLocalDbJson() {
    return {
      'id': id,
      'nama_petugas': namaPetugas,
      'username': username,
      'token': token,
      // 'id_kelurahan': idKelurahan,
      // 'nama_kelurahan': namaKelurahan,
      // 'nama_kecamatan': namaKecamatan,
      // 'url_foto': urlFoto,
      // password sengaja dikecualikan
    };
  }

  /// Untuk keperluan request (misal: register, update profil)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_petugas': namaPetugas,
      'username': username,
      'password': password,
      'token': token,
      'id_kelurahan': idKelurahan,
      'nama_kelurahan': namaKelurahan,
      'nama_kecamatan': namaKecamatan,
      'url_foto': urlFoto,
    };
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
