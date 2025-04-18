import 'package:flutter_test/flutter_test.dart';

/// Simula el método de agregar o actualizar producto como en tu lógica real.
void agregarOActualizarProducto(List<Map<String, dynamic>> inventario, Map<String, dynamic> nuevoProducto) {
  String? codigo = nuevoProducto['barcode'];
  int cantidadNueva = int.tryParse(nuevoProducto['quantity'].toString()) ?? 0;

  // ⚠️ Corrige el campo del producto para garantizar que siempre sea texto numérico
  nuevoProducto['quantity'] = cantidadNueva.toString();

  bool productoExiste = false;
  for (var producto in inventario) {
    if (producto['barcode'] == codigo) {
      int cantidadActual = int.tryParse(producto['quantity'].toString()) ?? 0;
      producto['quantity'] = (cantidadActual + cantidadNueva).toString();
      productoExiste = true;
      break;
    }
  }

  if (!productoExiste) {
    inventario.add(nuevoProducto);
  }
}


void main() {
  group('Historia de Usuario: Como cliente, necesito agregar productos al inventario', () {
    
    test('Escenario: Agregar un producto nuevo', () {
      // Given el inventario está vacío
      final inventario = <Map<String, dynamic>>[];

      // When agrego un producto con nombre y cantidad
      final nuevoProducto = {
        'name': 'Leche',
        'quantity': '2',
        'barcode': '12345',
        'expirationDate': '',
        'image': null,
      };
      agregarOActualizarProducto(inventario, nuevoProducto);

      // Then el inventario debe tener 1 producto con nombre y cantidad correctos
      expect(inventario.length, 1);
      expect(inventario.first['name'], 'Leche');
      expect(inventario.first['quantity'], '2');
    });

    test('Escenario: Agregar un producto ya existente suma cantidad', () {
      // Given un producto ya está en el inventario
      final inventario = [
        {'name': 'Arroz', 'quantity': '3', 'barcode': 'ABC123'}
      ];

      // When agrego el mismo producto con 2 unidades más
      final nuevoProducto = {
        'name': 'Arroz',
        'quantity': '2',
        'barcode': 'ABC123'
      };
      agregarOActualizarProducto(inventario, nuevoProducto);

      // Then la cantidad total debe ser 5
      expect(inventario.length, 1);
      expect(inventario.first['quantity'], '5');
    });

    test('Escenario: Producto con cantidad inválida se guarda como 0', () {
      // Given inventario vacío
      final inventario = <Map<String, dynamic>>[];

      // When agrego un producto con texto en vez de número
      final nuevoProducto = {
        'name': 'Huevos',
        'quantity': 'abc',
        'barcode': 'X123'
      };
      agregarOActualizarProducto(inventario, nuevoProducto);

      // Then debe agregarse con cantidad 0
      expect(inventario.first['quantity'], '0');
    });
  });
}
