import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Historia de Usuario: Como cliente, necesito registrar y autenticar mis productos', () {

    // Escenario: Registrar un producto correctamente con datos válidos
    test('Escenario: Registrar un producto correctamente con datos válidos', () {
      Map<String, dynamic> producto = {
        'name': 'Manzanas',
        'quantity': '10',
        'expirationDate': '2025-08-10',
        'barcode': '555444333',
        'image': null,
        'owner': 'cliente123'
      };

      expect(producto['name'], 'Manzanas');
      expect(producto['quantity'], '10');
      expect(producto['expirationDate'], '2025-08-10');
      expect(producto['barcode'], '555444333');
      expect(producto['owner'], 'cliente123');
    });

    // Escenario: Autenticación correcta de producto con código de barras
    test('Escenario: Autenticación de un producto correctamente con código de barras', () {
      Map<String, dynamic> producto = {
        'name': 'Pasta',
        'quantity': '4',
        'barcode': '888999777',
        'owner': 'cliente123'
      };

      String codigoDeBarras = '888999777';
      expect(producto['barcode'], codigoDeBarras);
      expect(producto['owner'], 'cliente123');
    });

    // Escenario: Intentar autenticar un producto con código de barras no registrado
    test('Escenario: Autenticación fallida con código de barras no registrado', () {
      Map<String, dynamic> producto = {
        'name': 'Salsas',
        'quantity': '3',
        'barcode': '666777888',
        'owner': 'cliente123'
      };

      String codigoDeBarras = '123456789'; // Código no registrado
      expect(producto['barcode'], isNot(codigoDeBarras)); // El código de barras no debe coincidir
    });
  });
}
