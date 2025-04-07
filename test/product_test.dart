// test/product_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:frescorden/utils/product_utils.dart'; // Cambia esto por la ruta correcta de tu archivo

void main() {
  group('agregarOActualizarProducto', () {
    test('Agrega un nuevo producto', () {
      final productos = <Map<String, dynamic>>[];

      final nuevoProducto = {
        'name': 'Leche',
        'quantity': '2',
        'barcode': '123456',
        'expirationDate': '',
        'image': null,
      };

      final resultado = agregarOActualizarProducto(productos, nuevoProducto);

      expect(productos.length, 1);
      expect(resultado['name'], 'Leche');
      expect(resultado['quantity'], '2');
    });

    test('Actualiza cantidad si el producto ya existe', () {
      final productos = [
        {
          'name': 'Leche',
          'quantity': '2',
          'barcode': '123456',
        }
      ];

      final nuevoProducto = {
        'name': 'Leche',
        'quantity': '3',
        'barcode': '123456',
      };

      final resultado = agregarOActualizarProducto(productos, nuevoProducto);

      expect(productos.length, 1);
      expect(resultado['quantity'], '5');
    });

    test('No lanza error si la cantidad no es numérica', () {
      final productos = <Map<String, dynamic>>[];

      final nuevoProducto = {
        'name': 'Huevos',
        'quantity': 'abc',
        'barcode': '789012',
      };

      final resultado = agregarOActualizarProducto(productos, nuevoProducto);

      expect(productos.length, 1);
      expect(resultado['quantity'], '0');
    });
  });
}
