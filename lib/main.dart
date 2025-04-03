import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

    void editarProducto(int index, Map<String, dynamic> producto) {
    setState(() {
      productos[index] = producto;
    });
  }
  
  void eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
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
              title: Text('Productos (${productos.length})'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductosScreen(
                  productos: productos,
                  onEdit: (index) async {
                    Map<String, dynamic> productToEdit = productos[index];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                          scannedCode: productToEdit['name'],
                          onSave: (editedProduct) {
                            editarProducto(index, editedProduct);
                          },
                        ),
                      ),
                    );
                  },
                  onDelete: (index) {
                    eliminarProducto(index);
                  },
                  ))
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
            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
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
  final String? scannedCode;
  final Map<String, dynamic>? initialProduct;
  final Function(Map<String, dynamic>) onSave;

  const AddProductScreen({
    super.key,
    this.scannedCode,
    this.initialProduct,
    required this.onSave,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  DateTime? expirationDate;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      nameController.text = widget.initialProduct!['name'] ?? '';
      quantityController.text = widget.initialProduct!['quantity'] ?? '';
      expirationDate = widget.initialProduct!['expirationDate'] != null
          ? DateTime.parse(widget.initialProduct!['expirationDate'])
          : null;
      if (widget.initialProduct!['image'] != null) {
        _imageFile = File(widget.initialProduct!['image']);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.initialProduct == null ? 'Agregar Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!,
                        width: 100, height: 100, fit: BoxFit.cover)
                    : Image.asset('assets/camaras.png',
                        width: 100, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              const SizedBox(height: 10),
              Text(expirationDate == null
                  ? 'Seleccionar fecha de expiración'
                  : 'Expira en: ${expirationDate!.difference(DateTime.now()).inDays} días'),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: expirationDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      expirationDate = pickedDate;
                    });
                  }
                },
                child: const Text('Seleccionar Fecha'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> product = {
                    'name': nameController.text,
                    'quantity': quantityController.text,
                    'expirationDate':
                        expirationDate?.toIso8601String() ?? '',
                    'image': _imageFile?.path,
                  };
                  widget.onSave(product);
                  Navigator.pop(context);
                },
                child: Text(widget.initialProduct == null
                    ? 'Guardar Producto'
                    : 'Actualizar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> productos;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const ProductosScreen({
    super.key,
    required this.productos,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos Agregados')),
      body: productos.isEmpty
          ? const Center(child: Text('No hay productos agregados'))
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                DateTime expDate = DateTime.parse(producto['expirationDate']);
                int daysRemaining = expDate.difference(DateTime.now()).inDays;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: producto['image'] != null
                          ? Image.file(
                              File(producto['image']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/camaras.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(producto['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${producto['quantity']}'),
                        Text('Expira en: $daysRemaining días',
                            style: TextStyle(
                                color: _getExpirationColor(daysRemaining))),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            onEdit(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            onDelete(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getExpirationColor(int daysRemaining) {
    if (daysRemaining < 0) {
      return Colors.red; // Caducado
    } else if (daysRemaining <= 3) {
      return Colors.orange; // Próximo a caducar
    } else {
      return Colors.green; // En buen estado
    }
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