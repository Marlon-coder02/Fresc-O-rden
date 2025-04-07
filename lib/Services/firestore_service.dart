import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> guardarProducto(Map<String, dynamic> producto) async {
    await _db.collection('productos').add({
      'name': producto['name'],
      'quantity': producto['quantity'],
      'expirationDate': producto['expirationDate'],
      'barcode': producto['barcode'],
      'fechaRegistro': Timestamp.now(),
      // Solo si tienes la imagen en la nube o quieres guardarla como texto
      'imagePath': producto['image'] ?? '',
    });
  }
}
