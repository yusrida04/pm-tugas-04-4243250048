import 'dart:async';

import 'package:pm_pertemuan_04/parkiran.dart';

Future<void> main() async {
  final parkiran = Parkiran(kapasitas: 3);

  // Listener menampilkan semua kejadian dari Stream.
  final StreamSubscription<String> listener = parkiran.kejadian.listen((
    kejadian,
  ) {
    print(kejadian);
  });

  // Polimorfisme: satu List berisi beberapa subclass Kendaraan.
  final List<Kendaraan> kendaraanMasuk = [
    Motor('BK 1234 AB'),
    Mobil('BK 88 UN'),
    MobilMember('BK 7 MIPA'),
    Truk('BK 9999 TR'),
  ];

  for (final kendaraan in kendaraanMasuk) {
    try {
      await parkiran.masuk(kendaraan);
    } on ParkirPenuh catch (e) {
      print('Ditolak: $e');
    }
  }

  // Semua kendaraan yang berhasil masuk dikeluarkan.
  await parkiran.keluar('BK 1234 AB');
  await parkiran.keluar('BK 88 UN');
  await parkiran.keluar('BK 7 MIPA');

  print('Pendapatan: ${rupiah(parkiran.pendapatan)}');

  await listener.cancel();
  await parkiran.tutup();
}
