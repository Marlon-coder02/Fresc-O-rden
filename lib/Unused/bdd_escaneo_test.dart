import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Historia de Usuario: Como cliente, necesito escanear el código de barras', () {
    test('Escenario: Código escaneado coincide con producto en el sistema', () {
      List<Map<String, dynamic>> baseProductos = [
        {'barcode': '789123', 'name': 'Arroz', 'quantity': '4'}
      ];

      String escaneado = '789123';

      var resultado = baseProductos.firstWhere(
        (p) => p['barcode'] == escaneado,
        orElse: () => {},
      );

      expect(resultado.isNotEmpty, true);
      expect(resultado['name'], 'Arroz');
    });

    test('Escenario: Código escaneado no existe, se carga como nombre', () {
      String escaneado = '000111';

      Map<String, dynamic> nuevoProducto = {
        'barcode': escaneado,
        'name': escaneado,
        'quantity': '1'
      };

      expect(nuevoProducto['name'], escaneado);
      expect(nuevoProducto['barcode'], '000111');
    });
  });
}
