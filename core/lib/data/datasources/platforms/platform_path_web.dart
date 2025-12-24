// Stub web untuk path_provider. Mengembalikan null di web; pemanggil harus
// menangani nilai null tersebut.
import 'dart:async';

Future<dynamic> getApplicationDocumentsDirectory() async {
  // Web tidak memiliki path filesystem persistent. Kembalikan null.
  return null;
}
