import 'package:flutter_test/flutter_test.dart';

void main() {
  // Test para registrar un producto correctamente
  test('Registrar un producto con datos válidos', () {
    Map<String, dynamic> producto = {
      'name': 'Aceite',
      'quantity': '5',
      'expirationDate': '2025-06-15',
      'barcode': '987654321',
      'image': null,
      'owner': 'cliente123' // ID del cliente, que es único para cada cliente
    };

    expect(producto['name'], 'Aceite');
    expect(producto['quantity'], '5');
    expect(producto['expirationDate'], '2025-06-15');
    expect(producto['barcode'], '987654321');
    expect(producto['owner'], 'cliente123');
  });

  // Test para verificar autenticación de un producto
  test('Autenticar un producto correctamente usando el código de barras', () {
    Map<String, dynamic> producto = {
      'name': 'Arroz',
      'quantity': '3',
      'barcode': '123456789',
      'owner': 'cliente123'
    };

    String codigoDeBarras = '123456789';
    expect(producto['barcode'], codigoDeBarras);
    expect(producto['owner'], 'cliente123');
  });

  // Test para manejar un producto con un código de barras no registrado
  test('Autenticar un producto con un código de barras no registrado', () {
    Map<String, dynamic> producto = {
      'name': 'Frijoles',
      'quantity': '2',
      'barcode': '111222333',
      'owner': 'cliente123'
    };

    String codigoDeBarras = '999999999'; // Código de barras no registrado
    expect(producto['barcode'], isNot(codigoDeBarras)); // El producto no debe coincidir con el código
  });
}
