import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Escanear código válido carga producto existente', () {
    List<Map<String, dynamic>> productos = [
      {'barcode': '123456', 'name': 'Leche', 'quantity': '2'}
    ];

    String codigoEscaneado = '123456';

    var productoEncontrado = productos.firstWhere(
      (p) => p['barcode'] == codigoEscaneado,
      orElse: () => {},
    );

    expect(productoEncontrado.isNotEmpty, true);
    expect(productoEncontrado['name'], 'Leche');
  });

  test('Escanear código nuevo carga nombre temporal', () {
    String codigoEscaneado = '999999';

    Map<String, dynamic> nuevoProducto = {
      'barcode': codigoEscaneado,
      'name': codigoEscaneado,
      'quantity': '1'
    };

    expect(nuevoProducto['name'], codigoEscaneado);
    expect(nuevoProducto['barcode'], '999999');
  });
}
