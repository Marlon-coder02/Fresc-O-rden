import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frescorden/screens/recetas_screen.dart';
import 'productos_screen.dart';
import 'add_product_screen.dart';
import '../widgets/button_plus.dart';
import 'login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}


class _InicioScreenState extends State<InicioScreen> {  
        @override
      void initState() {
        super.initState();
        cargarProductos();
        _cargarProductosDesdeFirestore();
      }
      void _cargarProductosDesdeFirestore() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('El usuario no está autenticado');
          return;
        }

        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('productos')
              .get();

          // Ahora estamos usando el ID del documento de Firestore directamente
          productos = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Añadimos el ID del documento directamente a los datos
            return data;
          }).toList();

          setState(() {});
        } catch (e) {
          print('Error al cargar productos: $e');
        }
      }

        Future<void> cargarProductos() async {
          try {
            final snapshot = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('productos')
                .get();

            // Mapear los productos con el ID
            List<Map<String, dynamic>> productos = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;  // Asignar el ID del documento a cada producto
              return data;
            }).toList();

            // Actualizar la lista de productos filtrados
            setState(() {
              productosFiltrados = productos;
            });
          } catch (e) {
            print('Error al cargar los productos: $e');
          }
        }


  final GoogleSignIn _googleSignIn = GoogleSignIn();
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> productosFiltrados = [];

  void agregarOActualizarProducto(Map<String, dynamic> nuevoProducto) async {
    String nuevoBarcode = nuevoProducto['barcode'] ?? '';
    bool encontrado = false;

    for (int i = 0; i < productos.length; i++) {
      if (nuevoBarcode.isNotEmpty &&
          productos[i]['barcode'] == nuevoBarcode) {
        int cantidadActual = int.tryParse(productos[i]['quantity'] ?? '0') ?? 0;
        int cantidadNueva = int.tryParse(nuevoProducto['quantity'] ?? '0') ?? 0;
        productos[i]['quantity'] = (cantidadActual + cantidadNueva).toString();
        encontrado = true;
        break;
      }
    }

    if (!encontrado) {
      productos.add(nuevoProducto);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('productos')
            .add({
          'name': nuevoProducto['name'],
          'barcode': nuevoProducto['barcode'],
          'quantity': nuevoProducto['quantity'],
          'unit': nuevoProducto['unit'],
          'imagePath': nuevoProducto['imagePath'],
          'expiryDate': nuevoProducto['expiryDate'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error guardando producto en Firestore: $e');
      }
    }

    setState(() {});
  }
  void editarProducto(int index, Map<String, dynamic> productoEditado) {
    setState(() {
      productos[index] = productoEditado;
    });
  }

void eliminarProductoConConfirmacion(int index) async {
  final producto = productos[index];
  final user = FirebaseAuth.instance.currentUser;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cierra el diálogo primero

              try {
                // Elimina el producto de Firestore usando el ID del documento directamente
                if (user != null && producto.containsKey('id')) {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.uid)
                      .collection('productos')
                      .doc(producto['id']) // Usamos el ID del producto
                      .delete();

                  setState(() {
                    productos.removeAt(index); // También lo quitamos de la lista local
                  });
                } else {
                  print('Producto sin ID válido o usuario no autenticado');
                }
              } catch (e) {
                print('Error al eliminar producto: $e');
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresc(o)rden'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 175, 186, 245),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresc(o)rden',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: Text('Productos (${productos.length})'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductosScreen(
                      productos: productos,
                      onEdit: (index) async {
                        Map<String, dynamic> productoAEditar = productos[index];
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductScreen(
                              initialProduct: productoAEditar,
                              existingProducts: productos,
                              onSave: (editedProduct) {
                                editarProducto(index, editedProduct);
                              },
                            ),
                          ),
                        );
                      },
                      onDelete: (index) {
                        eliminarProductoConConfirmacion(index);
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Recetas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecetasScreen(productosInventario: productos),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Lista de Compras'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Contacto'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: cerrarSesion,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(150.0),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset("assets/verduras.png"),
              ),
            ),
          ),
          const Center(
            child: Text(
              '¡Bienvenido a Fresc(o)rden!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Textos(),
        ],
      ),
      floatingActionButton: ButtonPlus(
        onScanComplete: (scannedCode) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(
                scannedCode: scannedCode,
                existingProducts: productos,
                onSave: agregarOActualizarProducto,
              ),
            ),
          );
        },
        onManualAdd: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(
                scannedCode: null,
                existingProducts: productos,
                onSave: agregarOActualizarProducto,
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
  const Textos({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Da en la  "),
        Image.asset(
          "assets/manzana.png",
          width: 25.0,
          height: 25.0,
        ),
        const SizedBox(width: 3.0),
        const Text(" para agregar un producto"),
      ],
    );
  }
}

