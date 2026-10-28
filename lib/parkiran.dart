import 'dart:async';

abstract class Kendaraan {
  final String plat;
  final DateTime waktuMasuk;

  Kendaraan(this.plat) : waktuMasuk = DateTime.now();

  String get jenis;
  int get tarifPerJam;

  int biaya(DateTime keluar) {
    final durasi = keluar.difference(waktuMasuk);
    final jam = (durasi.inSeconds / 3600).ceil();
    final jamTagihan = jam < 1 ? 1 : jam;

    return jamTagihan * tarifPerJam;
  }
}

class Motor extends Kendaraan {
  Motor(super.plat);

  @override
  String get jenis => 'Motor';

  @override
  int get tarifPerJam => 3000;
}

class Mobil extends Kendaraan {
  Mobil(super.plat);

  @override
  String get jenis => 'Mobil';

  @override
  int get tarifPerJam => 5000;
}

class Truk extends Kendaraan {
  Truk(super.plat);

  @override
  String get jenis => 'Truk';

  @override
  int get tarifPerJam => 8000;
}

mixin Berlangganan on Kendaraan {
  @override
  int biaya(DateTime keluar) {
    return super.biaya(keluar) ~/ 2;
  }
}

class MobilMember extends Mobil with Berlangganan {
  MobilMember(super.plat);
}

class ParkirPenuh implements Exception {
  final String pesan;

  ParkirPenuh(this.pesan);

  @override
  String toString() => pesan;
}

class Parkiran {
  final int kapasitas;
  final Map<String, Kendaraan> _kendaraan = {};
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Parkiran({required this.kapasitas});

  Stream<String> get kejadian => _controller.stream;

  int get sisa => kapasitas - _kendaraan.length;

  int _pendapatan = 0;
  int get pendapatan => _pendapatan;

  Future<void> masuk(Kendaraan kendaraan) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_kendaraan.containsKey(kendaraan.plat)) {
      _controller.add('Ditolak: Kendaraan ${kendaraan.plat} sudah terparkir.');
      return;
    }

    if (sisa <= 0) {
      throw ParkirPenuh('Parkiran penuh (kapasitas $kapasitas)');
    }

    _kendaraan[kendaraan.plat] = kendaraan;

    final member = kendaraan is MobilMember ? ' (member)' : '';

    _controller.add(
      'MASUK ${kendaraan.jenis}$member ${kendaraan.plat} '
      '(sisa $sisa)',
    );
  }

  Future<void> keluar(String plat) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final kendaraan = _kendaraan.remove(plat);

    if (kendaraan == null) {
      _controller.add('Ditolak: Kendaraan $plat tidak ditemukan.');
      return;
    }

    final biaya = kendaraan.biaya(DateTime.now());
    _pendapatan += biaya;

    final member = kendaraan is MobilMember ? ' (member)' : '';

    _controller.add(
      'KELUAR ${kendaraan.jenis}$member ${kendaraan.plat} '
      'bayar ${rupiah(biaya)}',
    );
  }

  Future<void> tutup() async {
    await _controller.close();
  }
}

String rupiah(int angka) {
  final teks = angka.toString();
  final hasil = StringBuffer();

  for (var i = 0; i < teks.length; i++) {
    hasil.write(teks[i]);

    final sisaDigit = teks.length - i - 1;

    if (sisaDigit > 0 && sisaDigit % 3 == 0) {
      hasil.write('.');
    }
  }

  return 'Rp${hasil.toString()}';
}
