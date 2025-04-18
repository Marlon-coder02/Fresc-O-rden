// lib/screens/productos_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productos;
  final Function(int) onEdit;
  final Function(int) onDelete;

  // ignore: use_super_parameters
  const ProductosScreen({
    Key? key,
    required this.productos,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> productosFiltrados = [];
  bool mostrarComoGrid = false;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    productosFiltrados = [...widget.productos];
  }

  void _actualizarFiltro() {
    setState(() {
      productosFiltrados = widget.productos.where((producto) {
        final nombre = producto['name']?.toLowerCase() ?? '';
        return nombre.contains(_busqueda.toLowerCase());
      }).toList();
    });
  }

  void _mostrarDialogoFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ordenar por:', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Fecha de expiración (más cercana)'),
                onTap: () {
                  setState(() {
                    productosFiltrados.sort((a, b) => (DateTime.parse(a['expirationDate'] ?? DateTime.now().toString())).compareTo(DateTime.parse(b['expirationDate'] ?? DateTime.now().toString())));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Cantidad (mayor a menor)'),
                onTap: () {
                  setState(() {
                    productosFiltrados.sort((a, b) => (b['quantity'] ?? 0).compareTo(a['quantity'] ?? 0));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Cantidad (menor a mayor)'),
                onTap: () {
                  setState(() {
                    productosFiltrados.sort((a, b) => (a['quantity'] ?? 0).compareTo(b['quantity'] ?? 0));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

void eliminarProductoConConfirmacion(int index) {
  final producto = productosFiltrados[index];
  final productoId = producto['id'];

  // Depuración del producto y el ID
  print('Producto a eliminar: $producto');
  print('ID del producto a eliminar: $productoId');

  if (productoId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto no tiene un ID válido')),
    );
    return;
  }

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
              try {
                if (user != null) {
                  // Depuración de la ruta
                  print('Ruta de eliminación: usuarios/${user!.uid}/productos/$productoId');

                  // Eliminar de Firestore
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user!.uid)
                      .collection('productos')
                      .doc(productoId)
                      .delete();

                  print('Producto eliminado correctamente de Firestore');

                  if (mounted) {
                    Navigator.of(context).pop(); // Cerrar el diálogo de confirmación

                    // Buscar el índice real del producto usando el ID
                    final indexEnOriginal = widget.productos.indexWhere((p) => p['id'] == productoId);
                    if (indexEnOriginal != -1) {
                      setState(() {
                        widget.productos.removeAt(indexEnOriginal);
                        productosFiltrados.removeAt(index);
                      });
                    }

                    // Mostrar mensaje de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Producto eliminado correctamente')),
                    );
                  }
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo encontrar el ID del producto')),
                  );
                }
              } catch (e) {
                print('Error al eliminar producto de Firestore: $e');
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el producto')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}



Future<void> _actualizarProductos() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .collection('productos')
        .get();

    final productosActualizados = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Añadir el ID del documento
      return data;
    }).toList();

    setState(() {
      widget.productos.clear();
      widget.productos.addAll(productosActualizados);
      _actualizarFiltro();
    });
  } catch (e) {
    print('Error al actualizar productos: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al actualizar los productos')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos Agregados'),
        actions: [
          IconButton(
            icon: Icon(mostrarComoGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                mostrarComoGrid = !mostrarComoGrid;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarDialogoFiltros,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                  _actualizarFiltro();
                });
              },
            ),
          ),
          Expanded(
            child: productosFiltrados.isEmpty
                ? const Center(child: Text('No hay productos agregados'))
                : RefreshIndicator(
                    onRefresh: _actualizarProductos,
                    child: mostrarComoGrid
                        ? GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: productosFiltrados.length,
                            itemBuilder: (context, index) => _buildProductoCard(index),
                          )
                        : ListView.builder(
                            itemCount: productosFiltrados.length,
                            itemBuilder: (context, index) => _buildProductoCard(index),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(int index) {
    final producto = productosFiltrados[index];
    final String dateStr = producto['expirationDate'] ?? '';
    DateTime expDate;
    int daysRemaining = 0;

    try {
      if (dateStr.isNotEmpty) {
        expDate = DateTime.parse(dateStr);
        daysRemaining = expDate.difference(DateTime.now()).inDays;
      } else {
        expDate = DateTime.now();
      }
    } catch (e) {
      expDate = DateTime.now();
      daysRemaining = 0;
    }

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
        title: Text(
          producto['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cantidad: ${producto['quantity']}'),
            Text(
              'Expira en: $daysRemaining días',
              style: TextStyle(color: _getExpirationColor(daysRemaining)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                widget.onEdit(widget.productos.indexOf(producto));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                eliminarProductoConConfirmacion(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getExpirationColor(int daysRemaining) {
    if (daysRemaining < 0) {
      return Colors.red;
    } else if (daysRemaining <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
