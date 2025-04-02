import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'My First App',
    home: Inicio(),
    );
  }
}


class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
List<Map<String, dynamic>> productos = [];

  void agregarProducto(Map<String, String> producto) {
    setState(() {
      productos.add(producto);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresc(o)rden'),
      ),
      drawer: Drawer(
        child:ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 175, 186, 245), // Color de fondo
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresc(o)rden',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), // Color del texto
                      fontSize: 24,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(height: 10.0), // Espacio entre los elementos
                ],
              ) 
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                MaterialPageRoute(builder:(context) => Inicio()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_basket),
              title: const Text('Productos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductosScreen(productos:productos))
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: const Text('Recetas'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: const Text('Lista de Compras'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Contatcto'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        )
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(150.0),
              child: Opacity(
                opacity: 0.5, // Valor entre 0.0 y 1.0
                child: Image.asset("assets/verduras.png"),
              ),
            ),
          ),
          Center(
            child: Text(
              '¡Bienvenido a Fresc(o)rden!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Textos(),
        ],
      ),
      floatingActionButton: ButtonPlus(
        onScanComplete: (scannedCode) {
          // Example: Add a product screen after scanning
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(
                scannedCode: scannedCode,
                onSave: (product) {
                  setState(() {
                    productos.add(product);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Textos extends StatelessWidget {
  const Textos({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Da en la  "), // Texto
        Image.asset("assets/manzana.png",
        width: 25.0,
        height: 25.0,
        ),
        const SizedBox(width: 3.0,), // Espacio entre los elementos
        const Text(" para Agregar un Producto"), // Texto
      ],
    );
  }
}

class ButtonPlus extends StatelessWidget {
  final Function(String) onScanComplete;

  const ButtonPlus({
    super.key,
    required this.onScanComplete,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // Abre la pantalla del escáner
        String? scannedCode = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScannerPage()),
        );
        // Si se obtiene un código, llama a la función onScanComplete
        if (scannedCode != null) {
          onScanComplete(scannedCode);
        }
      },
      backgroundColor: Colors.transparent,
      child: Image.asset(
        'assets/manzana.png',
        width: 75.0,
        height: 75.0,
      ),
    );
  }
}

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear Código')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final String scannedCode;
  final Function(Map<String, dynamic>) onSave;

  const AddProductScreen({super.key, required this.scannedCode, required this.onSave});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  DateTime? expirationDate;

  @override
  void initState() {
    super.initState();
    // Opcional: Puedes prellenar el nombre con el código escaneado, o dejarlo vacío.
    nameController.text = widget.scannedCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre del Producto'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad'),
            ),
            const SizedBox(height: 10),
            Text(expirationDate == null
                ? 'Seleccionar fecha de expiración'
                : 'Expira el: ${expirationDate!.toLocal()}'),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    expirationDate = pickedDate;
                  });
                }
              },
              child: Text('Seleccionar Fecha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave({
                  'name': nameController.text,
                  'quantity': quantityController.text,
                  'expirationDate': expirationDate.toString(),
                });
                Navigator.pop(context);
              },
              child: Text('Guardar Producto'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> productos;

  const ProductosScreen({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos Agregados')),
      body: productos.isEmpty
          ? Center(child: Text('No hay productos agregados'))
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(productos[index]['name']),
                  subtitle: Text(
                      'Cantidad: ${productos[index]['quantity']}\nExpira: ${productos[index]['expirationDate']}'),
                );
              },
            ),
    );
  }
}


/*class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fresc(o)rden'),
      ),
      body: Container(
        padding: EdgeInsets.all(150.0),
        child: Image.asset("assets/verduras.png"),
      ) 
    );
  }
}
*/

/*          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                print('Agregar Producto'); // Acción a realizar
              },
              icon: const Icon(Icons.add), // Icono
              label: const Text(''), // Texto
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54, // Color de fondo
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18), // Color del texto
              ),
            ),
          ),
)
*/